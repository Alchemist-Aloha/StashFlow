import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clock/clock.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../providers/video_player_provider.dart';
import '../providers/playback_queue_provider.dart';
import '../../../setup/presentation/providers/main_page_orientation_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import 'transformable_video_surface.dart';

class FullScreenMode extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final fullScreenModeProvider = NotifierProvider<FullScreenMode, bool>(
  FullScreenMode.new,
);

/// A vertical-scrolling "TikTok-style" view for discovering scenes.
///
/// This widget manages its own pool of [VideoPlayerController]s to ensure
/// smooth scrolling and low-latency playback as the user swipes through videos.
///
/// Key responsibilities:
/// - Handling vertical page transitions using [PageView].
/// - Implementing a "windowing" strategy for video controllers (pre-initializing
///   neighboring videos and disposing of distant ones).
/// - Synchronizing with system media controls (MediaSession).
/// - Providing unique interactions like long-press to speed up.
class TiktokScenesView extends ConsumerStatefulWidget {
  const TiktokScenesView({super.key});

  @override
  ConsumerState<TiktokScenesView> createState() => _TiktokScenesViewState();
}

class _TiktokScenesViewState extends ConsumerState<TiktokScenesView> {
  final PageController _pageController = PageController();

  /// The index of the currently visible scene.
  int _currentIndex = 0;

  /// Active video controllers indexed by scene ID.
  final Map<String, VideoPlayerController> _controllers = {};

  /// Initialization futures to prevent redundant setup calls.
  final Map<String, Future<void>> _initFutures = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _manageTimer?.cancel();
    _pageController.removeListener(_onScroll);
    _pageController.dispose();

    final globalController = ref
        .read(playerStateProvider)
        .videoPlayerController;
    for (final controller in _controllers.values) {
      if (controller != globalController) {
        controller.dispose();
      } else {
        AppLogStore.instance.add(
          'TiktokScenesView: skipping dispose of promoted controller in dispose()',
          source: 'TiktokScenesView',
        );
      }
    }
    _controllers.clear();
    WakelockPlus.disable();

    final allowMainPageGravityOrientation = ref.read(
      mainPageGravityOrientationProvider,
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(
      allowMainPageGravityOrientation
          ? [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : [DeviceOrientation.portraitUp],
    );
    super.dispose();
  }

  Timer? _manageTimer;

  void _onScroll() {
    // Determine the most prominent page
    if (!_pageController.hasClients) return;

    final page = _pageController.page;
    if (page == null) return;

    final newIndex = page.round();
    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });

      // Sync with global playback queue
      ref.read(playbackQueueProvider.notifier).setIndex(newIndex);

      // Debounce controller management to wait for the swipe to settle
      _manageTimer?.cancel();
      _manageTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) _manageControllers();
      });
    }
  }

  Future<void> _manageControllers() async {
    final scenesAsync = ref.read(sceneListProvider);
    if (!scenesAsync.hasValue || !mounted) return;

    // Safety check: only manage if we are likely the active view
    final router = GoRouter.of(context);
    final currentPath = router.routeInformationProvider.value.uri.path;
    // We only take over if we are at the root scenes page (TikTok feed)
    if (currentPath != '/scenes') return;

    final scenes = scenesAsync.value!;
    if (scenes.isEmpty) return;

    // Load next page if nearing the end
    if (_currentIndex >= scenes.length - 3) {
      ref.read(sceneListProvider.notifier).fetchNextPage();
    }

    final windowStart = (_currentIndex - 1).clamp(0, scenes.length - 1);
    final windowEnd = (_currentIndex + 2).clamp(0, scenes.length - 1);

    final idsInWindow = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      idsInWindow.add(scenes[i].id);
    }

    // Dispose controllers outside the window
    final idsToRemove = _controllers.keys
        .where((id) => !idsInWindow.contains(id))
        .toList();
    for (final id in idsToRemove) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
      _initFutures.remove(id);
    }

    // Initialize missing controllers inside the window
    for (int i = windowStart; i <= windowEnd; i++) {
      final scene = scenes[i];
      if (!_controllers.containsKey(scene.id) &&
          !_initFutures.containsKey(scene.id)) {
        _initFutures[scene.id] = _initializeController(scene);
      }
    }

    // Handle global player synchronization for the active scene
    final currentSceneId = scenes[_currentIndex].id;
    final activeTikTokController = _controllers[currentSceneId];
    final playerNotifier = ref.read(playerStateProvider.notifier);
    final globalPlayer = ref.read(playerStateProvider);

    // 1. If global player is already playing this scene, it might be returning from DetailsPage.
    // In this case, we don't want to stop it! We want to take its controller into our pool.
    if (globalPlayer.activeScene?.id == currentSceneId &&
        globalPlayer.videoPlayerController != null &&
        globalPlayer.videoPlayerController?.value.isInitialized == true &&
        globalPlayer.videoPlayerController != activeTikTokController) {
      AppLogStore.instance.add(
        'TiktokScenesView: sync global player to tiktok pool for $currentSceneId',
        source: 'TiktokScenesView',
      );

      // Take the global controller into our pool, replacing any preloaded one
      final oldLocal = _controllers[currentSceneId];
      _controllers[currentSceneId] = globalPlayer.videoPlayerController!;
      // Important: don't dispose if it was the same controller, but we checked != above
      if (oldLocal != null && oldLocal != globalPlayer.videoPlayerController) {
        oldLocal.dispose();
      }
    }
    // 2. Otherwise, if global player is idle or playing something else,
    // promote our local active controller to global so DetailsPage/MiniPlayer can use it.
    else if (globalPlayer.activeScene?.id != currentSceneId &&
        activeTikTokController != null &&
        activeTikTokController.value.isInitialized) {
      AppLogStore.instance.add(
        'TiktokScenesView: promoting local controller to global for $currentSceneId',
        source: 'TiktokScenesView',
      );
      unawaited(
        playerNotifier.attachController(
          scenes[_currentIndex],
          activeTikTokController,
          streamSource: 'tiktok-promotion',
        ),
      );
    }

    // Play current, pause others
    for (final entry in _controllers.entries) {
      final id = entry.key;
      final controller = entry.value;
      if (id == currentSceneId) {
        if (!controller.value.isPlaying) {
          controller.play();
        }
      } else {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
  }

  Future<void> _initializeController(Scene scene) async {
    try {
      final resolver = ref.read(streamResolverProvider.notifier);
      final choice = await resolver.resolvePreferredStream(scene);
      if (choice == null) return;

      final headers = ref.read(mediaPlaybackHeadersProvider);
      final allowBackgroundPlayback =
          ref.read(playerStateProvider).enableBackgroundPlayback;
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(choice.url),
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: allowBackgroundPlayback,
          mixWithOthers: true,
        ),
      );

      _controllers[scene.id] = controller;
      await controller.initialize();

      final autoplayNext = ref.read(playerStateProvider).autoplayNext;
      controller.setLooping(!autoplayNext);

      if (mounted) {
        setState(() {}); // Trigger rebuild to show the first frame

        final scenesAsync = ref.read(sceneListProvider);
        if (scenesAsync.hasValue) {
          final scenes = scenesAsync.value!;
          if (_currentIndex < scenes.length &&
              scenes[_currentIndex].id == scene.id) {
            controller.play();
          }
        }
      }
    } catch (e) {
      debugPrint(
        'Error initializing tiktok controller for scene ${scene.id}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(sceneListProvider);
    final playerState = ref.watch(playerStateProvider);

    return scenesAsync.when(
      data: (scenes) {
        if (scenes.isEmpty) {
          return Center(child: Text(context.l10n.common_no_items));
        }

        // Initialize first batch if needed
        if (_controllers.isEmpty && _initFutures.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _manageControllers();
          });
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: scenes.length,
          itemBuilder: (context, index) {
            final scene = scenes[index];
            final isCurrent = index == _currentIndex;

            // Use global controller for the active item to ensure seamless transitions
            // to/from DetailsPage where the global player is used.
            VideoPlayerController? controller;
            if (isCurrent && playerState.activeScene?.id == scene.id) {
              controller = playerState.videoPlayerController;
            } else {
              controller = _controllers[scene.id];
            }

            return TiktokSceneItem(scene: scene, controller: controller);
          },
        );
      },
      loading: () => const Center(child: CircularProgressContext()),
      error: (e, st) =>
          Center(child: Text(context.l10n.common_error(e.toString()))),
    );
  }
}

class CircularProgressContext extends StatelessWidget {
  const CircularProgressContext({super.key});
  @override
  Widget build(BuildContext context) => const CircularProgressIndicator();
}

class TiktokSceneItem extends ConsumerStatefulWidget {
  final Scene scene;
  final VideoPlayerController? controller;

  const TiktokSceneItem({required this.scene, this.controller, super.key});

  @override
  ConsumerState<TiktokSceneItem> createState() => _TiktokSceneItemState();
}

class _TiktokSceneItemState extends ConsumerState<TiktokSceneItem> {
  double _originalSpeed = 1.0;
  double _currentSpeed = 5.0;
  bool _isSpeedingUp = false;
  Timer? _playCountTimer;
  bool _playCountIncremented = false;
  int? _localRating;

  // Activity tracking
  DateTime? _playStartTime;
  double _accumulatedDuration = 0;
  Timer? _periodicSaveTimer;

  @override
  void initState() {
    super.initState();
    _localRating = widget.scene.rating100;
    widget.controller?.addListener(_onControllerChanged);
    if (widget.controller?.value.isPlaying == true) {
      _startActivityTracking();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _stopActivityTracking();
    super.dispose();
  }

  @override
  void didUpdateWidget(TiktokSceneItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.scene.rating100 != widget.scene.rating100) {
      setState(() {
        _localRating = widget.scene.rating100;
      });
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _stopActivityTracking();

      widget.controller?.addListener(_onControllerChanged);
      if (widget.controller?.value.isPlaying == true) {
        _startActivityTracking();
      }
    }
  }

  void _onControllerChanged() {
    if (widget.controller?.value.isPlaying == true) {
      _startActivityTracking();
    } else {
      _stopActivityTracking();
    }
  }

  void _startActivityTracking() {
    if (_playStartTime != null) return; // Already tracking

    _startPlayCountTimer();
    _playStartTime = clock.now();
    
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveActivity();
    });
  }

  void _stopActivityTracking() {
    _playCountTimer?.cancel();
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = null;

    if (_playStartTime != null) {
      final now = clock.now();
      _accumulatedDuration +=
          now.difference(_playStartTime!).inMilliseconds / 1000.0;
      _playStartTime = null;
    }

    if (_accumulatedDuration > 0) {
      _saveActivity();
    }
  }

  Future<void> _saveActivity() async {
    final controller = widget.controller;
    if (controller == null) return;

    double durationToSave = _accumulatedDuration;
    if (_playStartTime != null) {
      final now = clock.now();
      durationToSave += now.difference(_playStartTime!).inMilliseconds / 1000.0;
      _playStartTime = now;
    }

    if (durationToSave < 0.1) return;

    final resumeTime = controller.value.position.inMilliseconds / 1000.0;
    _accumulatedDuration = 0;

    try {
      await ref.read(sceneRepositoryProvider).saveSceneActivity(
        widget.scene.id,
        resumeTime: resumeTime,
        playDuration: durationToSave,
      );
      if (mounted) {
        unawaited(ref.read(sceneDetailsProvider(widget.scene.id).notifier).refresh());
      }
    } catch (e) {
      debugPrint('TikTok failed to save scene activity: $e');
    }
  }

  void _startPlayCountTimer() {
    if (_playCountIncremented) return;
    _playCountTimer?.cancel();
    _playCountTimer = Timer(const Duration(seconds: 5), () async {
      if (!mounted) return;
      try {
        await ref
            .read(sceneRepositoryProvider)
            .incrementScenePlayCount(widget.scene.id);
        _playCountIncremented = true;
        if (mounted) {
          unawaited(ref.read(sceneDetailsProvider(widget.scene.id).notifier).refresh());
        }
      } catch (e) {
        debugPrint('Failed to increment play count: $e');
      }
    });
  }

  void _showRatingPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.common_rate,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final starValue = (index + 1) * 20;
                  final currentRating = _localRating ?? 0;
                  return IconButton(
                    tooltip: 'Star',
                    icon: Icon(
                      currentRating >= starValue
                          ? Icons.star
                          : Icons.star_border,
                      size: 40,
                      color: Colors.amber,
                    ),
                    onPressed: () async {
                      setState(() {
                        _localRating = starValue;
                      });
                      await ref
                          .read(sceneRepositoryProvider)
                          .updateSceneRating(widget.scene.id, starValue);
                      ref.invalidate(sceneListProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _localRating = 0;
                  });
                  await ref
                      .read(sceneRepositoryProvider)
                      .updateSceneRating(widget.scene.id, 0);
                  ref.invalidate(sceneListProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(context.l10n.common_clear_rating),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handoffToGlobalPlayer() async {
    final playerNotifier = ref.read(playerStateProvider.notifier);
    final globalState = ref.read(playerStateProvider);
    final controller = widget.controller;

    if (controller == null || !controller.value.isInitialized) return;

    if (globalState.activeScene?.id != widget.scene.id ||
        globalState.videoPlayerController != controller) {
      AppLogStore.instance.add(
        'TiktokSceneItem: handing off to global player for ${widget.scene.id}',
        source: 'TiktokScenesView',
      );

      final resolver = ref.read(streamResolverProvider.notifier);
      final choice = await resolver.resolvePreferredStream(widget.scene);

      await playerNotifier.attachController(
        widget.scene,
        controller,
        streamMimeType: choice?.mimeType,
        streamLabel: choice?.label,
        streamSource: 'tiktok-handoff',
      );
    }
  }

  Future<void> _toggleFullScreen() async {
    final isFullScreen = ref.read(fullScreenModeProvider);
    if (isFullScreen) {
      if (context.mounted) {
        context.pop();
      }
    } else {
      final router = GoRouter.of(context);
      await _handoffToGlobalPlayer();

      if (mounted) {
        // Navigate to details THEN fullscreen for robust back stack
        router.push('/scenes/scene/${widget.scene.id}');
        router.push('/scenes/scene/${widget.scene.id}/fullscreen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video background
          Container(
            color: Colors.black,
            child: (controller != null && controller.value.isInitialized)
                ? Hero(
                    tag: 'scene_player_${widget.scene.id}',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: Colors.black,
                                child: TransformableVideoSurface(
                                  controller: controller,
                                  aspectRatio: controller.value.aspectRatio,
                                  fit: (controller.value.aspectRatio - 1.0).abs() < 0.01
                                      ? BoxFit.fill
                                      : (controller.value.aspectRatio < 1.0
                                          ? BoxFit.cover
                                          : BoxFit.contain),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          if (controller != null && controller.value.isInitialized)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // TikTok touch area
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      },
                      onLongPressStart: (_) {
                        _originalSpeed = controller.value.playbackSpeed;
                        _currentSpeed = 5.0;
                        controller.setPlaybackSpeed(_currentSpeed);
                        setState(() => _isSpeedingUp = true);
                      },
                      onLongPressMoveUpdate: (details) {
                        final dy = details.localOffsetFromOrigin.dy;
                        if (dy < 0) {
                          // Increase speed up to 20x
                          final extraSpeed = (-dy / 10).clamp(0, 15);
                          final newSpeed = 5.0 + extraSpeed;
                          if (newSpeed != _currentSpeed) {
                            setState(() => _currentSpeed = newSpeed);
                            controller.setPlaybackSpeed(_currentSpeed);
                          }
                        }
                      },
                      onLongPressEnd: (_) {
                        controller.setPlaybackSpeed(_originalSpeed);
                        setState(() => _isSpeedingUp = false);
                      },
                    ),
                  ),

                  if (_isSpeedingUp)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentSpeed.toStringAsFixed(1)}x Speed',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.fast_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 300,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Metadata overlay
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 80, // Space for right buttons
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.scene.displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.scene.studioName != null &&
                            widget.scene.studioName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              if (widget.scene.studioId != null) {
                                context.push(
                                  '/studios/studio/${widget.scene.studioId}',
                                );
                              }
                            },
                            child: Text(
                              widget.scene.studioName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          widget.scene.date.toString().split(' ')[0],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                          elevation: 2,
                          pressedElevation: 4,
                        ),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                        thumbColor: Colors.white,
                        trackShape: const RectangularSliderTrackShape(),
                      ),
                      child: SizedBox(
                        height: 24, // Larger tap target
                        child: ListenableBuilder(
                          listenable: controller,
                          builder: (context, child) {
                            final value = controller.value;
                            final duration = value.duration.inMilliseconds.toDouble();
                            final position = value.position.inMilliseconds.toDouble();
                            return Slider(
                              value: position.clamp(0.0, duration),
                              max: duration > 0 ? duration : 1.0,
                              onChanged: (val) {
                                controller.seekTo(Duration(milliseconds: val.toInt()));
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Right side buttons
                  Positioned(
                    bottom: 20,
                    right: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            _OverlayButton(
                              icon: (widget.scene.rating100 ?? 0) > 0
                                  ? Icons.star
                                  : Icons.star_border,
                              onTap: _showRatingPicker,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (widget.scene.rating100 ?? 0) > 0
                                  ? (widget.scene.rating100! / 20)
                                        .toStringAsFixed(1)
                                  : '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _OverlayButton(
                          icon: Icons.fullscreen,
                          tooltip: context.l10n.common_toggle_fullscreen,
                          onTap: _toggleFullScreen,
                        ),
                        const SizedBox(height: 16),
                        _OverlayButton(
                          icon: Icons.info_outline,
                          tooltip: context.l10n.details_scene,
                          onTap: () async {
                            await _handoffToGlobalPlayer();
                            if (context.mounted) {
                              context.push('/scenes/scene/${widget.scene.id}');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;

  const _OverlayButton({required this.icon, this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
