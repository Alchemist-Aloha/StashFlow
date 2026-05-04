import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clock/clock.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../providers/video_player_provider.dart';
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
/// This widget manages its own pool of [VideoController]s to ensure
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

  /// Active video players indexed by scene ID.
  final Map<String, Player> _players = {};

  /// Active video controllers indexed by scene ID.
  final Map<String, VideoController> _controllers = {};

  /// Initialization futures to prevent redundant setup calls.
  final Map<String, Future<void>> _initFutures = {};

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _manageTimer?.cancel();
    _pageController.dispose();

    final globalController = ref.read(playerStateProvider).videoController;
    for (final id in _controllers.keys) {
      if (_controllers[id] != globalController) {
        _players[id]?.dispose();
      } else {
        AppLogStore.instance.add(
          'TiktokScenesView: skipping dispose of promoted player in dispose()',
          source: 'TiktokScenesView',
        );
      }
    }
    _players.clear();
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
    if (_currentIndex >= scenes.length - 2) {
      ref.read(sceneListProvider.notifier).fetchNextPage();
    }

    // Window size: current-1 to current+1 (reduced from +2 to save CPU/RAM)
    final windowStart = (_currentIndex - 1).clamp(0, scenes.length - 1);
    final windowEnd = (_currentIndex + 1).clamp(0, scenes.length - 1);

    final idsInWindow = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      idsInWindow.add(scenes[i].id);
    }

    // Dispose controllers outside the window
    final idsToRemove = _controllers.keys
        .where((id) => !idsInWindow.contains(id))
        .toList();
    for (final id in idsToRemove) {
      _players[id]?.dispose();
      _players.remove(id);
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
        globalPlayer.videoController != null &&
        globalPlayer.videoController?.player.state.playlist.medias.isNotEmpty ==
            true &&
        globalPlayer.videoController != activeTikTokController) {
      AppLogStore.instance.add(
        'TiktokScenesView: sync global player to tiktok pool for $currentSceneId',
        source: 'TiktokScenesView',
      );

      // Take the global controller into our pool, replacing any preloaded one
      final oldLocal = _controllers[currentSceneId];
      final oldPlayer = _players[currentSceneId];
      _controllers[currentSceneId] = globalPlayer.videoController!;
      _players[currentSceneId] = globalPlayer.videoController!.player;

      // Important: don't dispose if it was the same controller, but we checked != above
      if (oldLocal != null && oldLocal != globalPlayer.videoController) {
        oldPlayer?.dispose();
      }
    }
    // 2. Otherwise, if global player is idle or playing something else,
    // promote our local active controller to global so DetailsPage/MiniPlayer can use it.
    else if (globalPlayer.activeScene?.id != currentSceneId &&
        activeTikTokController != null &&
        activeTikTokController.player.state.playlist.medias.isNotEmpty) {
      AppLogStore.instance.add(
        'TiktokScenesView: promoting local controller to global for $currentSceneId',
        source: 'TiktokScenesView',
      );
      unawaited(
        playerNotifier.attachController(
          scenes[_currentIndex],
          activeTikTokController.player,
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
        final endBehavior = ref.read(playerStateProvider).playEndBehavior;
        final targetMode = endBehavior == VideoEndBehavior.loop
            ? PlaylistMode.loop
            : PlaylistMode.none;
        if (controller.player.state.playlistMode != targetMode) {
          controller.player.setPlaylistMode(targetMode);
        }

        if (!controller.player.state.playing) {
          controller.player.play();
        }
      } else {
        if (controller.player.state.playing) {
          controller.player.pause();
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

      final player = Player();
      final controller = VideoController(player);

      _players[scene.id] = player;
      _controllers[scene.id] = controller;

      await player.open(Media(choice.url, httpHeaders: headers), play: false);

      final endBehavior = ref.read(playerStateProvider).playEndBehavior;
      await player.setPlaylistMode(
        endBehavior == VideoEndBehavior.loop
            ? PlaylistMode.loop
            : PlaylistMode.none,
      );

      player.stream.completed.listen((completed) {
        if (completed && mounted) {
          final behavior = ref.read(playerStateProvider).playEndBehavior;
          if (behavior == VideoEndBehavior.next) {
            final scenesAsync = ref.read(sceneListProvider);
            if (scenesAsync.hasValue) {
              final scenes = scenesAsync.value!;
              if (_currentIndex < scenes.length &&
                  scenes[_currentIndex].id == scene.id) {
                // It's the current one, scroll to next if possible
                if (_currentIndex < scenes.length - 1) {
                  AppLogStore.instance.add(
                    'TiktokScenesView: auto-scrolling to next scene due to end behavior',
                    source: 'TiktokScenesView',
                  );
                  _pageController.animateToPage(
                    _currentIndex + 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              }
            }
          }
        }
      });

      if (mounted) {
        setState(() {}); // Trigger rebuild to show the first frame

        final scenesAsync = ref.read(sceneListProvider);
        if (scenesAsync.hasValue) {
          final scenes = scenesAsync.value!;
          if (_currentIndex < scenes.length &&
              scenes[_currentIndex].id == scene.id) {
            player.play();
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

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              // Only trigger full management when scrolling has completely stopped.
              _manageTimer?.cancel();
              _manageTimer = Timer(const Duration(milliseconds: 50), () {
                if (mounted) _manageControllers();
              });
            }
            return false;
          },
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              // Immediately update current index for UI responsiveness
              if (index != _currentIndex) {
                setState(() {
                  _currentIndex = index;
                });
                
                // Immediately try to play the NEW current if we already have its controller
                final newSceneId = scenes[index].id;
                final existingController = _controllers[newSceneId];
                if (existingController != null) {
                  existingController.player.play();
                  // Pause the previous one immediately
                  final prevSceneId = scenes[index > _currentIndex ? index - 1 : index + 1].id;
                  _controllers[prevSceneId]?.player.pause();
                }
              }
            },
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];
              final isCurrent = index == _currentIndex;

              // Use global controller for the active item to ensure seamless transitions
              // to/from DetailsPage where the global player is used.
              VideoController? controller;
              if (isCurrent && playerState.activeScene?.id == scene.id) {
                controller = playerState.videoController;
              } else {
                controller = _controllers[scene.id];
              }

              final router = GoRouter.of(context);
              final currentPath = router.routeInformationProvider.value.uri.path;
              final isAtRoot = currentPath == '/scenes';

              return TiktokSceneItem(
                scene: scene,
                controller: controller,
                useHero: isAtRoot && !playerState.isFullScreen,
              );
            },
          ),
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
  final VideoController? controller;
  final bool useHero;

  const TiktokSceneItem({
    required this.scene,
    this.controller,
    this.useHero = true,
    super.key,
  });

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
  StreamSubscription<bool>? _playingSub;

  // Scrubbing state
  bool _isScrubbing = false;
  double _scrubMs = 0;
  bool _wasPlayingBeforeScrub = false;

  @override
  void initState() {
    super.initState();
    _localRating = widget.scene.rating100;
    _playingSub = widget.controller?.player.stream.playing.listen(
      _onControllerChanged,
    );
    if (widget.controller?.player.state.playing == true) {
      _startActivityTracking();
    }
  }

  @override
  void dispose() {
    _playingSub?.cancel();
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
      _playingSub?.cancel();
      _stopActivityTracking();

      _playingSub = widget.controller?.player.stream.playing.listen(
        _onControllerChanged,
      );
      if (widget.controller?.player.state.playing == true) {
        _startActivityTracking();
      }
    }
  }

  void _onControllerChanged(bool isPlaying) {
    if (isPlaying) {
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

    final resumeTime = controller.player.state.position.inMilliseconds / 1000.0;
    _accumulatedDuration = 0;

    try {
      await ref
          .read(sceneRepositoryProvider)
          .saveSceneActivity(
            widget.scene.id,
            resumeTime: resumeTime,
            playDuration: durationToSave,
          );
      if (mounted) {
        unawaited(
          ref.read(sceneDetailsProvider(widget.scene.id).notifier).refresh(),
        );
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
          unawaited(
            ref.read(sceneDetailsProvider(widget.scene.id).notifier).refresh(),
          );
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
                    tooltip: context.l10n.common_star,
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

    if (controller == null || controller.player.state.playlist.medias.isEmpty) {
      return;
    }

    if (globalState.activeScene?.id != widget.scene.id ||
        globalState.videoController != controller) {
      AppLogStore.instance.add(
        'TiktokSceneItem: handing off to global player for ${widget.scene.id}',
        source: 'TiktokScenesView',
      );

      final resolver = ref.read(streamResolverProvider.notifier);
      final choice = await resolver.resolvePreferredStream(widget.scene);

      await playerNotifier.attachController(
        widget.scene,
        controller.player,
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
        router.push('/scenes/fullscreen/${widget.scene.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final playerState = ref.watch(playerStateProvider);

    final videoSurface = LayoutBuilder(
      builder: (context, constraints) {
        final w = controller?.player.state.width;
        final h = controller?.player.state.height;
        final r = (w != null && h != null && h > 0) ? w / h : 16 / 9;
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: TransformableVideoSurface(
                  fontSize: playerState.subtitleFontSize,
                  textAlign: _subtitleTextAlign(
                    playerState.subtitleTextAlignment,
                  ),
                  bottomRatio: playerState.subtitlePositionBottomRatio,
                  constraints: constraints,
                  controller: controller!,
                  aspectRatio: r,
                  fit:
                      (r - 1.0).abs() < 0.01
                          ? BoxFit.fill
                          : (r < 1.0 ? BoxFit.cover : BoxFit.contain),
                ),
              ),
            ),
          ],
        );
      },
    );

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video background
          Container(
            color: Colors.black,
            child:
                (controller != null &&
                    controller.player.state.playlist.medias.isNotEmpty)
                ? (widget.useHero
                    ? Hero(
                        tag: 'scene_player_${widget.scene.id}',
                        child: videoSurface,
                      )
                    : videoSurface)
                : const Center(child: CircularProgressIndicator()),
          ),

          if (controller != null &&
              controller.player.state.playlist.medias.isNotEmpty)
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
                        if (controller.player.state.playing) {
                          controller.player.pause();
                        } else {
                          controller.player.play();
                        }
                      },
                      onLongPressStart: (_) {
                        _originalSpeed = controller.player.state.rate;
                        _currentSpeed = 5.0;
                        controller.player.setRate(_currentSpeed);
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
                            controller.player.setRate(_currentSpeed);
                          }
                        }
                      },
                      onLongPressEnd: (_) {
                        controller.player.setRate(_originalSpeed);
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
                                style: context.textTheme.bodyMedium?.copyWith(
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

                  // Metadata and Buttons in a RepaintBoundary
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: Stack(
                        children: [
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
                                  style: context.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: context.fontSizes.xLarge,
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
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontSize: context.fontSizes.body,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  widget.scene.date.toString().split(' ')[0],
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                    fontSize: context.fontSizes.body,
                                  ),
                                ),
                              ],
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
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontSize: context.fontSizes.regular,
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
                  ),

                  // Progress Bar in its own RepaintBoundary to isolate slider updates
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RepaintBoundary(
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
                          child: StreamBuilder<Duration>(
                            stream: controller.player.stream.position,
                            builder: (context, snapshot) {
                              final duration = controller
                                  .player
                                  .state
                                  .duration
                                  .inMilliseconds
                                  .toDouble();
                              final position = _isScrubbing
                                  ? _scrubMs
                                  : (snapshot.data?.inMilliseconds.toDouble() ??
                                      controller
                                          .player
                                          .state
                                          .position
                                          .inMilliseconds
                                          .toDouble());
                              return Slider(
                                value: position.clamp(0.0, duration),
                                max: duration > 0 ? duration : 1.0,
                                onChangeStart: (val) {
                                  _wasPlayingBeforeScrub =
                                      controller.player.state.playing;
                                  setState(() {
                                    _isScrubbing = true;
                                    _scrubMs = val;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {
                                    _scrubMs = val;
                                  });
                                },
                                onChangeEnd: (val) {
                                  controller.player.seek(
                                    Duration(milliseconds: val.toInt()),
                                  );
                                  if (_wasPlayingBeforeScrub &&
                                      !controller.player.state.playing) {
                                    controller.player.play();
                                  }
                                  setState(() {
                                    _isScrubbing = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
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
              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
TextAlign _subtitleTextAlign(String setting) {
  switch (setting) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    case 'center':
    default:
      return TextAlign.center;
  }
}