import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../domain/entities/scene.dart';
import '../providers/video_player_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../data/repositories/stream_prewarmer.dart';
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

import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/services/cast_service.dart';

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

bool _isSceneFullscreenPath(String path, {String? sceneId}) {
  final segments = Uri.parse(path).pathSegments;
  if (segments.length < 3) return false;
  if (segments[0] != 'scenes' || segments[1] != 'fullscreen') return false;
  if (sceneId != null && segments[2] != sceneId) return false;
  return true;
}

bool _isSceneDetailsPath(String path, {String? sceneId}) {
  final segments = Uri.parse(path).pathSegments;
  if (segments.length < 3) return false;
  if (segments[0] != 'scenes' || segments[1] != 'scene') return false;
  if (sceneId != null && segments[2] != sceneId) return false;
  return true;
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
  const SceneVideoPlayer({
    required this.scene,
    this.autoPlayOnMount = false,
    this.maxHeight,
    super.key,
  });

  /// The scene to be played.
  final Scene scene;

  /// Whether this mount should force playback even if another scene is active.
  final bool autoPlayOnMount;

  /// Optional maximum height for the video player container.
  final double? maxHeight;

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
      _startPlaybackIfNeeded(force: widget.autoPlayOnMount);
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
    final router = GoRouter.maybeOf(context);
    final currentPath = router?.routeInformationProvider.value.uri.path ?? '';
    final isInFullscreenRoute = _isSceneFullscreenPath(currentPath);
    final isOwningSceneRoute =
        _isSceneDetailsPath(currentPath, sceneId: widget.scene.id) ||
        _isSceneFullscreenPath(currentPath, sceneId: widget.scene.id);

    AppLogStore.instance.add(
      'SceneVideoPlayer._startPlaybackIfNeeded: scene=${widget.scene.id}, force=$force, autoPlayOnMount=${widget.autoPlayOnMount}, activeScene=${playerState.activeScene?.id}, currentPath=$currentPath, isOwningSceneRoute=$isOwningSceneRoute',
      source: 'scene_video_player',
    );

    // If we're already active, just resume or stay as-is.
    if (playerState.activeScene?.id == widget.scene.id) {
      AppLogStore.instance.add(
        'SceneVideoPlayer: Scene ${widget.scene.id} already active, resuming if paused',
        source: 'scene_video_player',
      );
      if (playerState.player != null && !playerState.player!.state.playing) {
        playerState.player!.play();
      }
      return;
    }

    if (!force && playerState.viewMode != PlayerViewMode.inline) {
      AppLogStore.instance.add(
        'SceneVideoPlayer: Skipping playback - viewMode is ${playerState.viewMode}',
        source: 'scene_video_player',
      );
      return;
    }

    if (!force && !isOwningSceneRoute) {
      return;
    }

    // Do not let a background scene claim the shared player while fullscreen
    // is active for another scene. That would replace the active scene under
    // the fullscreen route and break fullscreen lifecycle validation.
    if (!force && (playerState.isFullScreen || isInFullscreenRoute)) {
      AppLogStore.instance.add(
        'SceneVideoPlayer: Skipping playback - fullscreen=${playerState.isFullScreen}, isInFullscreenRoute=$isInFullscreenRoute',
        source: 'scene_video_player',
      );
      return;
    }

    // Only auto-play if we are forcing it or if no other video is playing.
    // Users can opt into "direct-play on navigation" which allows a scene
    // details page to start playback even when another scene is already active.
    final prefs = ref.read(sharedPreferencesProvider);
    final directPlayOnNavigation =
        prefs.getBool('video_direct_play_on_navigation') ?? false;
    if (!force && playerState.activeScene != null && !directPlayOnNavigation) {
      AppLogStore.instance.add(
        'SceneVideoPlayer: Skipping playback - another scene active=${playerState.activeScene?.id}, directPlayOnNavigation=$directPlayOnNavigation',
        source: 'scene_video_player',
      );
      return;
    }

    AppLogStore.instance.add(
      'SceneVideoPlayer: Starting playback for scene ${widget.scene.id}',
      source: 'scene_video_player',
    );

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
    // 1. Try using the provider's video dimensions first as they are updated via streams.
    final playerState = ref.read(playerStateProvider);
    if (playerState.videoWidth != null &&
        playerState.videoHeight != null &&
        playerState.videoHeight! > 0) {
      final ratio = playerState.videoWidth! / playerState.videoHeight!;
      // Force square videos to 9/16 portrait on mobile to avoid the "fat" look.
      if ((ratio - 1.0).abs() < 0.01 &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        return 9 / 16;
      }
      return ratio;
    }

    // 2. Fallback to the raw controller state if available.
    if (controller != null &&
        controller.player.state.width != null &&
        controller.player.state.height != null &&
        controller.player.state.height! > 0) {
      final ratio =
          controller.player.state.width! / controller.player.state.height!;
      if ((ratio - 1.0).abs() < 0.01 &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        return 9 / 16;
      }
      return ratio;
    }

    // 3. Fallback to scene file metadata if the controller is still loading.
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

      // Use the centralized prewarmer which uses Byte-Range GET (0-10MB)
      // and keeps the connection alive in a pool.
      await prewarmer.prewarm(scene, choice.url, headers: headers);

      stopwatch.stop();
      return _PrewarmResult(
        attempted: true,
        succeeded:
            true, // We assume success if no exception was thrown during request setup
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
    final isInFullscreenPath = _isSceneFullscreenPath(currentPath);

    AppLogStore.instance.add(
      'SceneVideoPlayer [${widget.scene.id}] _toggleFullScreen: path=$currentPath stateFS=${playerState.isFullScreen} inFSPath=$isInFullscreenPath',
      source: 'SceneVideoPlayer',
    );

    if (kIsWeb) {
      if (playerState.isFullScreen || isInFullscreenPath) {
        unawaited(exitWebFullScreen());
      } else {
        unawaited(enterWebFullScreen());
      }
    }

    if (playerState.isFullScreen || isInFullscreenPath) {
      AppLogStore.instance.add(
        'SceneVideoPlayer [${widget.scene.id}] exiting fullscreen via global state',
        source: 'SceneVideoPlayer',
      );
      ref.read(playerStateProvider.notifier).syncBackgroundToActiveScene(context);
      ref.read(playerStateProvider.notifier).setFullScreen(false);
      ref.read(playerStateProvider.notifier).setViewMode(PlayerViewMode.inline);
    } else {
      AppLogStore.instance.add(
        'SceneVideoPlayer [${widget.scene.id}] entering fullscreen via global state',
        source: 'SceneVideoPlayer',
      );
      ref.read(playerStateProvider.notifier).setViewMode(PlayerViewMode.fullscreen);
      ref.read(playerStateProvider.notifier).setFullScreen(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final castState = ref.watch(castServiceProvider);
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
    return LayoutBuilder(
      builder: (context, layoutConstraints) {
        final availableWidth = layoutConstraints.maxWidth;
        final intendedHeight = availableWidth / aspectRatio;

        Widget player = AspectRatio(
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
                        child: castState.isCasting
                            ? Image.network(
                                appendApiKey(
                                  widget.scene.paths.screenshot ?? '',
                                  ref.read(serverApiKeyProvider),
                                ),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.cast,
                                        size: 64,
                                        color: Colors.white24,
                                      ),
                                    ),
                              )
                            : TransformableVideoSurface(
                                fontSize: playerState.subtitleFontSize,
                                textAlign: _subtitleTextAlign(
                                  playerState.subtitleTextAlignment,
                                ),
                                bottomRatio:
                                    playerState.subtitlePositionBottomRatio,
                                constraints: constraints,
                                controller: controller,
                                aspectRatio: controllerAspectRatio,
                                fit: BoxFit.contain,
                                transformationNotifier: _transformationNotifier,
                              ),
                      ),
                    ),
                    if (showLoadingIndicator && !castState.isCasting)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    if (castState.isCasting)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cast_connected,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Casting to ${castState.activeSession?.device.name ?? 'Device'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

        if (widget.maxHeight != null && intendedHeight > widget.maxHeight!) {
          player = SizedBox(
            height: widget.maxHeight!,
            width: widget.maxHeight! * aspectRatio,
            child: player,
          );
        }

        return Center(child: player);
      },
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

