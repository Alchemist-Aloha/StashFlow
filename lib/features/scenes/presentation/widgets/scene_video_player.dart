import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:window_manager/window_manager.dart';

import '../../domain/entities/scene.dart';
import '../providers/video_player_provider.dart';
import '../../data/repositories/stream_prewarmer.dart';
import '../../../setup/presentation/providers/main_page_orientation_provider.dart';
import '../../../../core/presentation/providers/keybinds_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/web_helpers.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'native_video_controls.dart';
// import 'scene_subtitle_overlay.dart'; // Don't remove. For customizeable subtitle rendering in the future, but currently we rely on native subtitles for performance and compatibility reasons.
import 'transformable_video_surface.dart';

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

// We can add horizontal alignment for subtitle in the future if needed, but for now we'll just use TextAlign for simplicity and rely on padding to achieve the desired horizontal positioning.
// Alignment _subtitleHorizontalAlignment(String setting) {
//   switch (setting) {
//     case 'left':
//       return Alignment.centerLeft;
//     case 'right':
//       return Alignment.centerRight;
//     case 'center':
//     default:
//       return Alignment.center;
//   }
// }

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

  /// Timer to debounce the buffering spinner.
  /// Seeking triggers a brief buffering state that we want to ignore.
  Timer? _bufferingDisplayTimer;
  bool _showBufferingSpinner = false;

  final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(
    Matrix4.identity(),
  );
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

  void _onScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
    _lastRotation = 0.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    final double deltaScale = details.scale / _lastScale;
    final double deltaRotation = details.rotation - _lastRotation;
    final Offset focalPoint = details.localFocalPoint;

    final Matrix4 matrix = Matrix4.identity()
      ..translateByVector3(Vector3(focalPoint.dx, focalPoint.dy, 0))
      ..rotateZ(deltaRotation)
      ..scaleByVector3(Vector3(deltaScale, deltaScale, 1.0))
      ..translateByVector3(Vector3(-focalPoint.dx, -focalPoint.dy, 0))
      ..translateByVector3(
        Vector3(details.focalPointDelta.dx, details.focalPointDelta.dy, 0),
      );

    _transformationNotifier.value = matrix * _transformationNotifier.value;
    _lastScale = details.scale;
    _lastRotation = details.rotation;
  }

  void _onTransformationDelta(Matrix4 delta, Offset focalPoint) {
    _transformationNotifier.value = delta * _transformationNotifier.value;
  }

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
      if (playerState.player != null && !playerState.player!.state.playing) {
        playerState.player!.play();
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
        final mediaHeaders = ref.read(mediaPlaybackHeadersProvider);
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
  double _effectiveAspectRatio(VideoController? controller) {
    if (controller != null &&
        controller.player.state.width != null &&
        controller.player.state.height != null &&
        controller.player.state.height! > 0) {
      final ratio =
          controller.player.state.width! / controller.player.state.height!;
      // Force square videos to 9/16 portrait on mobile to avoid the "fat" look.
      if ((ratio - 1.0).abs() < 0.01 &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        return 9 / 16;
      }
      return ratio;
    }
    // Try using scene file metadata if the controller is still loading.
    if (widget.scene.files.isNotEmpty) {
      final f = widget.scene.files.first;
      if (f.width != null && f.height != null && f.height! > 0) {
        final ratio = f.width! / f.height!;
        if ((ratio - 1.0).abs() < 0.01 &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)) {
          return 9 / 16;
        }
        return ratio;
      }
    }
    return 16 / 9;
  }

  /// Attempts to "warm up" the stream by making a partial GET request
  /// to ensure the URL is valid, the server is responsive, and the connection
  /// pipe is ready for playback.
  Future<_PrewarmResult> _prewarmStream(Scene scene) async {
    if (kIsWeb) {
      return const _PrewarmResult(attempted: false, succeeded: false);
    }

    final stopwatch = Stopwatch()..start();

    try {
      if (!mounted) {
        return const _PrewarmResult(attempted: false, succeeded: false);
      }
      final resolver = ref.read(streamResolverProvider.notifier);
      final prewarmer = ref.read(streamPrewarmerProvider.notifier);
      
      final choice = await resolver.resolvePreferredStream(scene);
      if (choice == null) {
        return const _PrewarmResult(attempted: false, succeeded: false);
      }

      if (!mounted) {
        return const _PrewarmResult(attempted: false, succeeded: false);
      }
      final headers = ref.read(mediaPlaybackHeadersProvider);
      
      // Use the centralized prewarmer which uses Byte-Range GET (0-2048KB)
      // and keeps the connection alive in a pool.
      await prewarmer.prewarm(scene, choice.url, headers: headers);

      stopwatch.stop();
      return _PrewarmResult(
        attempted: true,
        succeeded: true, // We assume success if no exception was thrown during request setup
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (_) {
      stopwatch.stop();
      return _PrewarmResult(
        attempted: true,
        succeeded: false,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
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
    final controller = playerState.videoController;

    final aspectRatio = _effectiveAspectRatio(controller);

    // If this player isn't active, show a placeholder with a play button.
    if (playerState.activeScene?.id != widget.scene.id) {
      final colorScheme = Theme.of(context).colorScheme;
      final keybinds = ref.watch(keybindsProvider);
      final playPauseBind = keybinds.binds[KeybindAction.playPause];

      return AspectRatio(
        aspectRatio: aspectRatio,
        child: CallbackShortcuts(
          bindings: {
            if (playPauseBind != null)
              playPauseBind.toActivator(): () =>
                  _startPlaybackIfNeeded(force: true),
          },
          child: Focus(
            autofocus: true,
            child: Container(
              color: Colors.black,
              child: Center(
                child: _isStarting
                    ? const CircularProgressIndicator()
                    : IconButton.filledTonal(
                        tooltip: context.l10n.common_play,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.92),
                          foregroundColor: colorScheme.onSurface,
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 32),
                        onPressed: () => _startPlaybackIfNeeded(force: true),
                      ),
              ),
            ),
          ),
        ),
      );
    }

    // Show loading indicator while the global controller initializes.
    if (controller == null) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final videoWidth = playerState.videoWidth;
    final videoHeight = playerState.videoHeight;
    final isVideoReady =
        videoWidth != null && videoHeight != null && videoHeight > 0;
    final controllerAspectRatio = isVideoReady
        ? videoWidth / videoHeight
        : aspectRatio;

    // Debounce the buffering spinner to avoid flicker during quick seeks or minor network jitters.
    if (playerState.isBuffering && !_showBufferingSpinner) {
      _bufferingDisplayTimer ??= Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showBufferingSpinner = true);
      });
    } else if (!playerState.isBuffering && _showBufferingSpinner) {
      _bufferingDisplayTimer?.cancel();
      _bufferingDisplayTimer = null;
      // We wrap this in a microtask to avoid setState during build.
      Future.microtask(() {
        if (mounted) setState(() => _showBufferingSpinner = false);
      });
    } else if (!playerState.isBuffering) {
      _bufferingDisplayTimer?.cancel();
      _bufferingDisplayTimer = null;
    }

    // Show loading indicator if buffering (after debounce), or if dimensions aren't ready and not playing.
    final showLoadingIndicator =
        _showBufferingSpinner || (!isVideoReady && !playerState.isPlaying);

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
                    child: TransformableVideoSurface(
                      fontSize: playerState.subtitleFontSize,
                      textAlign: _subtitleTextAlign(
                        playerState.subtitleTextAlignment,
                      ),
                      bottomRatio: playerState.subtitlePositionBottomRatio,
                      constraints: constraints,
                      controller: controller,
                      aspectRatio: controllerAspectRatio,
                      fit: (aspectRatio - controllerAspectRatio).abs() > 0.05
                          ? BoxFit.fill
                          : BoxFit.contain,
                      transformationNotifier: _transformationNotifier,
                    ),
                  ),
                ),
                if (showLoadingIndicator)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                // Don't remove. Customizable subtitle rendering can be implemented here in the future if we want to support advanced features like karaoke or custom fonts. For now, we rely on native subtitles for better performance and compatibility.
                // if (playerState.selectedSubtitleLanguage != null &&
                //     playerState.selectedSubtitleLanguage != 'none')
                //   StreamBuilder<List<String>>(
                //     stream: controller.player.stream.subtitle,
                //     builder: (context, snapshot) {
                //       return SceneSubtitleOverlay(
                //         text: snapshot.data?.join('\n') ?? '',
                //         constraints: constraints,
                //         bottomRatio: playerState.subtitlePositionBottomRatio,
                //         fontSize: playerState.subtitleFontSize,
                //         textAlign: _subtitleTextAlign(
                //           playerState.subtitleTextAlignment,
                //         ),
                //         horizontalAlignment: _subtitleHorizontalAlignment(
                //           playerState.subtitleTextAlignment,
                //         ),
                //         horizontalPadding: 16,
                //       );
                //     },
                //   ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: NativeVideoControls(
                      controller: controller,
                      useDoubleTapSeek: playerState.useDoubleTapSeek,
                      enableNativePip: playerState.enableNativePip,
                      onFullScreenToggle: _toggleFullScreen,
                      scene: widget.scene,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onTransformationDelta: _onTransformationDelta,
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
  bool _wasPlayingBeforeExit = false;
  VideoController? _currentListenedController;
  final List<StreamSubscription> _subscriptions = [];

  // Timer to debounce the buffering spinner.
  Timer? _bufferingDisplayTimer;
  bool _showBufferingSpinner = false;

  final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(
    Matrix4.identity(),
  );
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

  void _onScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
    _lastRotation = 0.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    final double deltaScale = details.scale / _lastScale;
    final double deltaRotation = details.rotation - _lastRotation;
    final Offset focalPoint = details.localFocalPoint;

    final Matrix4 matrix = Matrix4.identity()
      ..translateByVector3(Vector3(focalPoint.dx, focalPoint.dy, 0))
      ..rotateZ(deltaRotation)
      ..scaleByVector3(Vector3(deltaScale, deltaScale, 1.0))
      ..translateByVector3(Vector3(-focalPoint.dx, -focalPoint.dy, 0))
      ..translateByVector3(
        Vector3(details.focalPointDelta.dx, details.focalPointDelta.dy, 0),
      );

    _transformationNotifier.value = matrix * _transformationNotifier.value;
    _lastScale = details.scale;
    _lastRotation = details.rotation;
  }

  void _onTransformationDelta(Matrix4 delta, Offset focalPoint) {
    _transformationNotifier.value = delta * _transformationNotifier.value;
  }

  void _onControllerUpdate() {
    if (!_isPopping && _currentListenedController != null) {
      _wasPlayingBeforeExit = _currentListenedController!.player.state.playing;
    }
  }

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
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> _enterFullScreen() async {
    final playerState = ref.read(playerStateProvider);
    final controller = playerState.videoController;
    final wasPlaying = playerState.player?.state.playing ?? false;

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
          if (controller != null && !controller.player.state.playing) {
            unawaited(controller.player.play());
          }
        }
      } else {
        final playerState = ref.read(playerStateProvider);
        final width = controller?.player.state.width;
        final height = controller?.player.state.height;
        final aspectRatio = (width != null && height != null && height > 0)
            ? width / height
            : 16 / 9;
        final allowGravity = playerState.videoGravityOrientation;

        List<DeviceOrientation> orientations;
        if (aspectRatio > 1.0) {
          // Landscape
          orientations = allowGravity
              ? [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : [DeviceOrientation.landscapeLeft];
        } else {
          // Portrait or Square
          orientations = allowGravity
              ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
              : [DeviceOrientation.portraitUp];
        }

        await SystemChrome.setPreferredOrientations(orientations);

        // On Web, toggling fullscreen and the Hero transition can trigger a pause
        if (wasPlaying && kIsWeb) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (controller != null && !controller.player.state.playing) {
              unawaited(controller.player.play());
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
    final controller = ref.read(playerStateProvider).videoController;
    final wasPlaying = _wasPlayingBeforeExit;

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
        if (wasPlaying &&
            (kIsWeb || defaultTargetPlatform == TargetPlatform.windows)) {
          if (controller != null && !controller.player.state.playing) {
            await controller.player.play();
          }
        }
      }());
    } else {
      final allowMainPageGravityOrientation = ref.read(
        mainPageGravityOrientationProvider,
      );
      unawaited(() async {
        await SystemChrome.setPreferredOrientations(
          allowMainPageGravityOrientation
              ? [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : [DeviceOrientation.portraitUp],
        );

        // On Web, toggling fullscreen and the Hero transition can trigger a pause
        if (wasPlaying && kIsWeb) {
          Future.delayed(const Duration(milliseconds: 350), () {
            // Do not check `mounted` here because FullscreenPlayerPage might be unmounted
            // when returning to the inline player page.
            if (controller != null && !controller.player.state.playing) {
              unawaited(controller.player.play());
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
    final controller = playerState.videoController;

    if (controller != _currentListenedController) {
      if (_currentListenedController != null) {
        for (final sub in _subscriptions) {
          sub.cancel();
        }
        _subscriptions.clear();
      }
      _currentListenedController = controller;
      if (controller != null) {
        _subscriptions.add(
          controller.player.stream.playing.listen((_) => _onControllerUpdate()),
        );
      }
      // Immediately hydrate the initial value.
      if (controller != null && !_isPopping) {
        _wasPlayingBeforeExit = controller.player.state.playing;
      }
    }

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final videoWidth = playerState.videoWidth;
              final videoHeight = playerState.videoHeight;
              final isVideoReady =
                  videoWidth != null && videoHeight != null && videoHeight > 0;
              final aspectRatio = isVideoReady
                  ? videoWidth / videoHeight
                  : 16 / 9;

              // Use the same debouncing logic as the inline player
              if (playerState.isBuffering && !_showBufferingSpinner) {
                _bufferingDisplayTimer ??=
                    Timer(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() => _showBufferingSpinner = true);
                    });
              } else if (!playerState.isBuffering && _showBufferingSpinner) {
                _bufferingDisplayTimer?.cancel();
                _bufferingDisplayTimer = null;
                Future.microtask(() {
                  if (mounted) setState(() => _showBufferingSpinner = false);
                });
              } else if (!playerState.isBuffering) {
                _bufferingDisplayTimer?.cancel();
                _bufferingDisplayTimer = null;
              }

              final showLoadingIndicator =
                  _showBufferingSpinner ||
                  (!isVideoReady && !playerState.isPlaying);

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
                        controller: controller,
                        aspectRatio: aspectRatio,
                        transformationNotifier: _transformationNotifier,
                        fit: (aspectRatio - 1.0).abs() < 0.01
                            ? BoxFit.fill
                                      : (aspectRatio < 1.0
                                            ? BoxFit.cover
                                            : BoxFit.contain),
                      ),
                    ),
                  ),
                  if (showLoadingIndicator)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  // Don't remove. Customizable subtitle rendering can be implemented here in the future if we want to support advanced features like karaoke or custom fonts. For now, we rely on native subtitles for better performance and compatibility.
                  // if (playerState.selectedSubtitleLanguage != null &&
                  //     playerState.selectedSubtitleLanguage != 'none')
                  //   StreamBuilder<List<String>>(
                  //     stream: controller.player.stream.subtitle,
                  //     builder: (context, snapshot) {
                  //       return SceneSubtitleOverlay(
                  //         text: snapshot.data?.join('\n') ?? '',
                  //         constraints: constraints,
                  //         bottomRatio: playerState.subtitlePositionBottomRatio,
                  //         fontSize: playerState.subtitleFontSize + 4,
                  //         textAlign: _subtitleTextAlign(
                  //           playerState.subtitleTextAlignment,
                  //         ),
                  //         horizontalAlignment: _subtitleHorizontalAlignment(
                  //           playerState.subtitleTextAlignment,
                  //         ),
                  //         horizontalPadding: 32,
                  //       );
                  //     },
                  //   ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: NativeVideoControls(
                        controller: controller,
                        useDoubleTapSeek: playerState.useDoubleTapSeek,
                        enableNativePip: playerState.enableNativePip,
                        onFullScreenToggle: _toggleFullScreen,
                        scene: scene,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onTransformationDelta: _onTransformationDelta,
                      ),
                    ),
                  ),
                ],
              );
            },
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
