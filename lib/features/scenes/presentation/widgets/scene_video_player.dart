import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

import '../../domain/entities/scene.dart';
import '../providers/video_player_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/web_helpers.dart';
import 'native_video_controls.dart';
import 'scene_subtitle_overlay.dart';

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

Alignment _subtitleHorizontalAlignment(String setting) {
  switch (setting) {
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    case 'center':
    default:
      return Alignment.center;
  }
}

/// A comprehensive video player for Stash scenes.
///
/// This widget handles both inline and immersive fullscreen playback.
/// It uses the global [PlayerState] to maintain session continuity during
/// navigation.
class SceneVideoPlayer extends ConsumerStatefulWidget {
  const SceneVideoPlayer({required this.scene, super.key});

  /// The scene to be played.
  final Scene scene;

  @override
  ConsumerState<SceneVideoPlayer> createState() => _SceneVideoPlayerState();
}

class _SceneVideoPlayerState extends ConsumerState<SceneVideoPlayer> {
  /// Local state to track initial player startup for UI feedback.
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    // Prewarm the stream if this scene is not yet active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlaybackIfNeeded();
    });
  }

  @override
  void dispose() {
    // Note: We don't dispose the controller here as it is managed by the provider.
    super.dispose();
  }

  /// Automatically start playback if this scene is designated as active,
  /// or if requested by the user.
  Future<void> _startPlaybackIfNeeded({bool force = false}) async {
    final playerState = ref.read(playerStateProvider);

    // If we're already active, just resume or stay as-is.
    if (playerState.activeScene?.id == widget.scene.id) {
      if (playerState.videoPlayerController != null &&
          !playerState.videoPlayerController!.value.isPlaying) {
        playerState.videoPlayerController!.play();
      }
      return;
    }

    // Only auto-play if we are forcing it or if no other video is playing.
    if (!force && playerState.activeScene != null) {
      return;
    }

    setState(() => _isStarting = true);
    try {
      if (!mounted) return;
      final resolver = ref.read(streamResolverProvider.notifier);

      // Perform a background "prewarm" to test connectivity.
      // We don't await this here to avoid blocking player initialization.
      unawaited(
        _prewarmStream(widget.scene).then((prewarmResult) {
          if (mounted) {
            ref
                .read(playerStateProvider.notifier)
                .setPrewarmResult(
                  attempted: prewarmResult.attempted,
                  succeeded: prewarmResult.succeeded,
                  latencyMs: prewarmResult.latencyMs,
                );
          }
        }),
      );

      final choice = await resolver.resolvePreferredStream(widget.scene);
      if (choice != null && mounted) {
        final mediaHeaders = ref.read(mediaHeadersProvider);
        await ref
            .read(playerStateProvider.notifier)
            .playScene(
              widget.scene,
              choice.url,
              mimeType: choice.mimeType,
              streamLabel: choice.label,
              streamSource: force ? 'manual-start' : 'auto-start',
              httpHeaders: mediaHeaders,
            );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  /// Returns the intended aspect ratio for the video container.
  /// Falls back to 16/9 if metadata is unavailable.
  double _effectiveAspectRatio(VideoPlayerController? controller) {
    if (controller != null && controller.value.isInitialized) {
      return controller.value.aspectRatio;
    }
    // Try using scene file metadata if the controller is still loading.
    if (widget.scene.files.isNotEmpty) {
      final f = widget.scene.files.first;
      if (f.width != null && f.height != null && f.height! > 0) {
        return f.width! / f.height!;
      }
    }
    return 16 / 9;
  }

  /// Attempts to "warm up" the stream by making a lightweight HEAD or GET
  /// request to ensure the URL is valid and the server is responsive.
  Future<_PrewarmResult> _prewarmStream(Scene scene) async {
    if (kIsWeb) {
      return const _PrewarmResult(attempted: false, succeeded: false);
    }

    final stopwatch = Stopwatch()..start();
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      if (!mounted) {
        return const _PrewarmResult(attempted: false, succeeded: false);
      }
      final resolver = ref.read(streamResolverProvider.notifier);
      final choice = await resolver.resolvePreferredStream(scene);
      if (choice == null) {
        return const _PrewarmResult(attempted: false, succeeded: false);
      }

      final uri = Uri.parse(choice.url);
      // Use HEAD request instead of GET for lightweight connection prewarm.
      final request = await client.headUrl(uri);

      if (!mounted) {
        return const _PrewarmResult(attempted: false, succeeded: false);
      }
      final headers = ref.read(mediaHeadersProvider);
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      // No longer need to drain as HEAD response body is empty.
      stopwatch.stop();
      return _PrewarmResult(
        attempted: true,
        succeeded: response.statusCode < 400,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (_) {
      stopwatch.stop();
      return _PrewarmResult(
        attempted: true,
        succeeded: false,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Toggles between inline and immersive fullscreen mode.
  Future<void> _toggleFullScreen() async {
    if (!mounted) return;

    final playerState = ref.read(playerStateProvider);
    final router = GoRouter.maybeOf(context);

    // We check both state and path for maximum robustness.
    // If we are in fullscreen state OR on the fullscreen path, we want to exit.
    final currentPath = router?.routeInformationProvider.value.uri.path ?? '';
    final isInFullscreenPath = currentPath.endsWith('/fullscreen');

    if (kIsWeb) {
      if (playerState.isFullScreen || isInFullscreenPath) {
        unawaited(exitWebFullScreen());
      } else {
        unawaited(enterWebFullScreen());
      }
    }

    if (playerState.isFullScreen || isInFullscreenPath) {
      router?.pop();
    } else {
      context.push('/scenes/scene/${widget.scene.id}/fullscreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final controller = playerState.videoPlayerController;

    final aspectRatio = _effectiveAspectRatio(controller);

    // If this player isn't active, show a placeholder with a play button.
    if (playerState.activeScene?.id != widget.scene.id) {
      final colorScheme = Theme.of(context).colorScheme;
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: Colors.black,
          child: Center(
            child: _isStarting
                ? const CircularProgressIndicator()
                : FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.92),
                      foregroundColor: colorScheme.onSurface,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text('Play'),
                    onPressed: () => _startPlaybackIfNeeded(force: true),
                  ),
          ),
        ),
      );
    }

    // Show loading indicator while the global controller initializes.
    if (controller == null || !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Main playback surface.
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Hero(
        tag: 'scene_player_${widget.scene.id}',
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                ),
                if (playerState.selectedSubtitleLanguage != null &&
                    playerState.selectedSubtitleLanguage != 'none')
                  ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      return SceneSubtitleOverlay(
                        text: value.caption.text,
                        constraints: constraints,
                        bottomRatio: playerState.subtitlePositionBottomRatio,
                        fontSize: playerState.subtitleFontSize,
                        textAlign: _subtitleTextAlign(
                          playerState.subtitleTextAlignment,
                        ),
                        horizontalAlignment: _subtitleHorizontalAlignment(
                          playerState.subtitleTextAlignment,
                        ),
                        horizontalPadding: 16,
                      );
                    },
                  ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: NativeVideoControls(
                      controller: controller,
                      useDoubleTapSeek: playerState.useDoubleTapSeek,
                      enableNativePip: playerState.enableNativePip,
                      onFullScreenToggle: _toggleFullScreen,
                      scene: widget.scene,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// An immersive fullscreen page for the active video player.
///
/// This page locks the orientation to landscape and hides system bars.
/// It uses a [Hero] transition to seamlessly hand off the video surface
/// from the inline [SceneVideoPlayer].
class FullscreenPlayerPage extends ConsumerStatefulWidget {
  const FullscreenPlayerPage({required this.sceneId, super.key});

  /// The ID of the scene currently being played.
  final String sceneId;

  @override
  ConsumerState<FullscreenPlayerPage> createState() =>
      _FullscreenPlayerPageState();
}

class _FullscreenPlayerPageState extends ConsumerState<FullscreenPlayerPage> {
  bool _isPopping = false;
  bool _wasMaximizedBeforeFullscreen = false;

  @override
  void initState() {
    super.initState();
    // Request landscape and hide system UI immediately upon entering fullscreen.
    _enterFullScreen();
  }

  @override
  void deactivate() {
    // Reset orientation and show system UI upon leaving fullscreen.
    // We use deactivate instead of dispose because ref access is still safe here.
    _exitFullScreen();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _enterFullScreen() async {
    final controller = ref.read(playerStateProvider).videoPlayerController;
    final wasPlaying = controller?.value.isPlaying ?? false;

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        _wasMaximizedBeforeFullscreen = await windowManager.isMaximized();

        // Some desktop window managers can keep title bar chrome visible when
        // entering fullscreen directly from a maximized state.
        if (_wasMaximizedBeforeFullscreen) {
          await windowManager.unmaximize();
        }

        await windowManager.setFullScreen(true);

        // Retry once if the first transition did not stick.
        if (!await windowManager.isFullScreen()) {
          await windowManager.setFullScreen(true);
        }

        // On Windows, toggling fullscreen can sometimes trigger a pause in the native player
        // due to window state changes or focus loss during the transition.
        if (wasPlaying && defaultTargetPlatform == TargetPlatform.windows) {
          if (controller != null && !controller.value.isPlaying) {
            unawaited(controller.play());
          }
        }
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        // On Web, toggling fullscreen and the Hero transition can trigger a pause
        if (wasPlaying && kIsWeb) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted && controller != null && !controller.value.isPlaying) {
              unawaited(controller.play());
            }
          });
        }
      }
    } catch (e) {
      AppLogStore.instance.add(
        'FullscreenPlayerPage [${widget.sceneId}] error entering fullscreen: $e',
        source: 'FullscreenPlayerPage',
      );
    } finally {
      if (mounted) {
        ref.read(playerStateProvider.notifier).setFullScreen(true);
      }
    }
  }

  void _exitFullScreen() {
    final controller = ref.read(playerStateProvider).videoPlayerController;
    final wasPlaying = controller?.value.isPlaying ?? false;

    // Reset state early so parent pages (like ShellPage) rebuild correctly.
    // We use a post-frame callback to avoid "Tried to modify a provider while
    // the widget tree was building" errors during route transitions.
    final notifier = ref.read(playerStateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.setFullScreen(false);
    });

    // Reset orientation and show system UI.
    // These are async but don't need to be awaited for the state change.
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      unawaited(() async {
        await windowManager.setFullScreen(false);

        // Restore maximized state when leaving fullscreen if we started there.
        if (_wasMaximizedBeforeFullscreen) {
          await windowManager.maximize();
          _wasMaximizedBeforeFullscreen = false;
        }

        // On Windows and Web, toggling fullscreen can sometimes trigger a pause in the native player
        // due to window state changes or focus loss during the transition.
        if (wasPlaying && (kIsWeb || defaultTargetPlatform == TargetPlatform.windows)) {
          if (controller != null && !controller.value.isPlaying) {
            await controller.play();
          }
        }
      }());
    } else {
      unawaited(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        // On Web, toggling fullscreen and the Hero transition can trigger a pause
        if (wasPlaying && kIsWeb) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted && controller != null && !controller.value.isPlaying) {
              unawaited(controller.play());
            }
          });
        }
      }());
    }
  }

  /// Toggles between inline and immersive fullscreen mode.
  Future<void> _toggleFullScreen() async {
    if (!mounted || _isPopping) return;

    if (kIsWeb) {
      unawaited(exitWebFullScreen());
    }

    final router = GoRouter.maybeOf(context);

    // If we are in FullscreenPlayerPage, the toggle button always exits.
    _isPopping = true;
    // Update state immediately before popping.
    // _exitFullScreen will also be called via deactivate() for extra safety.
    ref.read(playerStateProvider.notifier).setFullScreen(false);
    router?.pop();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    final currentPath = router?.routeInformationProvider.value.uri.path ?? '';
    final isInFullscreenPath = currentPath.endsWith('/fullscreen');

    final playerState = ref.watch(playerStateProvider);

    // Automatically exit fullscreen if the global player state indicates it's no longer fullscreen
    // This handles scenarios like the video ending and the player state reset.
    // By listening here instead of the parent page, we avoid race conditions
    // where the parent page might pop twice if the user manually popped first.
    ref.listen(playerStateProvider, (previous, next) {
      if (previous?.isFullScreen == true && next.isFullScreen == false) {
        // Only trigger a pop if we are not already in the process of popping
        // and we are actually on the fullscreen path.
        if (context.mounted && !_isPopping && isInFullscreenPath) {
          AppLogStore.instance.add(
            'FullscreenPlayerPage [${widget.sceneId}] auto-exiting fullscreen',
            source: 'FullscreenPlayerPage',
          );
          _isPopping = true;
          router?.pop();
        }
      }
    });

    final sceneId = widget.sceneId;

    // We must have an active scene that matches the one we're trying to show.
    final scene = playerState.activeScene;
    final controller = playerState.videoPlayerController;

    if (scene == null || scene.id != sceneId || controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Initializing player...',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _isPopping = true;
          // Ensure state is updated immediately on back-swipe
          ref.read(playerStateProvider.notifier).setFullScreen(false);
        }
      },
      child: Material(
        color: Colors.black,
        child: Hero(
          tag: 'scene_player_${widget.sceneId}',
          child: SizedBox.expand(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    ),
                    if (playerState.selectedSubtitleLanguage != null &&
                        playerState.selectedSubtitleLanguage != 'none')
                      ValueListenableBuilder(
                        valueListenable: controller,
                        builder: (context, value, child) {
                          return SceneSubtitleOverlay(
                            text: value.caption.text,
                            constraints: constraints,
                            bottomRatio:
                                playerState.subtitlePositionBottomRatio,
                            fontSize: playerState.subtitleFontSize + 4,
                            textAlign: _subtitleTextAlign(
                              playerState.subtitleTextAlignment,
                            ),
                            horizontalAlignment: _subtitleHorizontalAlignment(
                              playerState.subtitleTextAlignment,
                            ),
                            horizontalPadding: 32,
                          );
                        },
                      ),
                    NativeVideoControls(
                      controller: controller,
                      useDoubleTapSeek: playerState.useDoubleTapSeek,
                      enableNativePip: playerState.enableNativePip,
                      onFullScreenToggle: _toggleFullScreen,
                      scene: scene,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal class tracking the result of a prewarm request.
class _PrewarmResult {
  const _PrewarmResult({
    required this.attempted,
    required this.succeeded,
    this.latencyMs,
  });

  final bool attempted;
  final bool succeeded;
  final int? latencyMs;
}
