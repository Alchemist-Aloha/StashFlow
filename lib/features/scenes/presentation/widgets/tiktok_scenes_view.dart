import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/entities/scene.dart';
import '../providers/scene_list_provider.dart';
import '../providers/video_player_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import 'native_video_controls.dart';

class FullScreenMode extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final fullScreenModeProvider = NotifierProvider<FullScreenMode, bool>(
  FullScreenMode.new,
);

class TiktokScenesView extends ConsumerStatefulWidget {
  const TiktokScenesView({super.key});

  @override
  ConsumerState<TiktokScenesView> createState() => _TiktokScenesViewState();
}

class _TiktokScenesViewState extends ConsumerState<TiktokScenesView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Map of scene ID to controller
  final Map<String, VideoPlayerController> _controllers = {};
  
  // Future that tracks initialization
  final Map<String, Future<void>> _initFutures = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

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
      _manageControllers();
    }
  }

  Future<void> _manageControllers() async {
    final scenesAsync = ref.read(sceneListProvider);
    if (!scenesAsync.hasValue) return;
    
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
    final idsToRemove = _controllers.keys.where((id) => !idsInWindow.contains(id)).toList();
    for (final id in idsToRemove) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
      _initFutures.remove(id);
    }

    // Initialize missing controllers inside the window
    for (int i = windowStart; i <= windowEnd; i++) {
      final scene = scenes[i];
      if (!_controllers.containsKey(scene.id) && !_initFutures.containsKey(scene.id)) {
        _initFutures[scene.id] = _initializeController(scene);
      }
    }

    // Play current, pause others
    for (final entry in _controllers.entries) {
      final id = entry.key;
      final controller = entry.value;
      if (id == scenes[_currentIndex].id) {
        if (!controller.value.isPlaying) {
          // Stop global player if it's playing to avoid audio overlap
          final globalPlayer = ref.read(playerStateProvider);
          if (globalPlayer.activeScene != null) {
            ref.read(playerStateProvider.notifier).stop();
          }
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

      final headers = ref.read(mediaHeadersProvider);
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(choice.url),
        httpHeaders: headers,
      );

      _controllers[scene.id] = controller;
      await controller.initialize();
      controller.setLooping(true);

      if (mounted) {
        setState(() {}); // Trigger rebuild to show the first frame
        
        final scenesAsync = ref.read(sceneListProvider);
        if (scenesAsync.hasValue) {
            final scenes = scenesAsync.value!;
            if (_currentIndex < scenes.length && scenes[_currentIndex].id == scene.id) {
                controller.play();
            }
        }
      }
    } catch (e) {
      debugPrint('Error initializing tiktok controller for scene ${scene.id}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(sceneListProvider);
    final isFullScreen = ref.watch(fullScreenModeProvider);

    return PopScope(
      canPop: !isFullScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isFullScreen) {
          ref.read(fullScreenModeProvider.notifier).set(false);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      },
      child: scenesAsync.when(
        data: (scenes) {
          if (scenes.isEmpty) {
            return const Center(child: Text('No scenes found'));
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
              return TiktokSceneItem(
                scene: scenes[index],
                controller: _controllers[scenes[index].id],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressContext()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
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

  const TiktokSceneItem({
    required this.scene,
    this.controller,
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

  @override
  void initState() {
    super.initState();
    _localRating = widget.scene.rating100;
    widget.controller?.addListener(_onControllerChanged);
    if (widget.controller?.value.isPlaying == true) {
      _startPlayCountTimer();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _playCountTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TiktokSceneItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id || oldWidget.scene.rating100 != widget.scene.rating100) {
      setState(() {
        _localRating = widget.scene.rating100;
      });
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      if (widget.controller?.value.isPlaying == true) {
        _startPlayCountTimer();
      }
    }
  }

  void _onControllerChanged() {
    if (widget.controller?.value.isPlaying == true) {
      _startPlayCountTimer();
    } else {
      _playCountTimer?.cancel();
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
        // Invalidate list to keep play counts accurate in other views, 
        // but we don't necessarily need to trigger a full refresh of the current TikTok view 
        // as it might be disruptive. For now, let's just invalidate.
        ref.invalidate(sceneListProvider);
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
              Text('Rate Scene', style: context.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final starValue = (index + 1) * 20;
                  final currentRating = _localRating ?? 0;
                  return IconButton(
                    icon: Icon(
                      currentRating >= starValue ? Icons.star : Icons.star_border,
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
                      if (context.mounted) Navigator.pop(context);
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
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Clear Rating'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
            ],
          ),
        );
      },
    );
  }

  void _toggleFullScreen() {
    final isFullScreen = ref.read(fullScreenModeProvider);
    if (isFullScreen) {
      if (context.mounted) {
        context.pop();
      }
    } else {
      context.push('/scenes/fullscreen/${widget.scene.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFullScreen = ref.watch(fullScreenModeProvider);
    final playerState = ref.watch(playerStateProvider);
    final controller = widget.controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video background
        Container(
          color: Colors.black,
          child: controller != null && controller.value.isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),

        if (controller != null && controller.value.isInitialized)
          if (isFullScreen)
            NativeVideoControls(
              controller: controller,
              useDoubleTapSeek: playerState.useDoubleTapSeek,
              enableNativePip: playerState.enableNativePip,
              onFullScreenToggle: _toggleFullScreen,
              scene: widget.scene,
            )
          else ...[
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        const Icon(Icons.fast_forward,
                            color: Colors.white, size: 20),
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
                        Colors.black.withOpacity(0.8),
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
                    widget.scene.title.isNotEmpty ? widget.scene.title : 'Scene ${widget.scene.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.scene.studioName != null && widget.scene.studioName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        if (widget.scene.studioId != null) {
                          context.push('/studios/studio/${widget.scene.studioId}');
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
                  if (widget.scene.date != null)
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

            // Minimum Progress Bar
            if (controller != null && controller.value.isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 2,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: EdgeInsets.zero,
                    colors: VideoProgressColors(
                      playedColor: Colors.white.withValues(alpha: 0.8),
                      bufferedColor: Colors.white.withValues(alpha: 0.2),
                      backgroundColor: Colors.transparent,
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
                            ? (widget.scene.rating100! / 20).toStringAsFixed(1)
                            : '-',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _OverlayButton(
                    icon: Icons.fullscreen,
                    tooltip: 'Toggle Fullscreen',
                    onTap: _toggleFullScreen,
                  ),
                  const SizedBox(height: 16),
                  _OverlayButton(
                    icon: Icons.info_outline,
                    tooltip: 'Scene Details',
                    onTap: () {
                      context.push('/scenes/scene/${widget.scene.id}');
                    },
                  ),
                ],
              ),
            ),
          ],
      ],
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
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
