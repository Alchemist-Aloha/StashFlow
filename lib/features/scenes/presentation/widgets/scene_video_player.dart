import 'dart:async';

import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/scene_random_navigation_provider.dart';
import '../providers/player_view_mode.dart';
import '../providers/video_player_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/data/services/cast_service.dart';
import '../../../../core/presentation/providers/keybinds_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/web_helpers.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'player_surface.dart';
// import 'scene_subtitle_overlay.dart'; // Don't remove. For customizeable subtitle rendering in the future, but currently we rely on native subtitles for performance and compatibility reasons.

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

  @override
  void initState() {
    super.initState();
    // Prewarm the stream if this scene is not yet active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startPlaybackIfNeeded(force: widget.autoPlayOnMount);
    });
  }

  @override
  void didUpdateWidget(covariant SceneVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scene.id != widget.scene.id) {
      _isStarting = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startPlaybackIfNeeded(force: widget.autoPlayOnMount);
      });
      return;
    }

    if (!oldWidget.autoPlayOnMount && widget.autoPlayOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startPlaybackIfNeeded(force: true);
      });
    }
  }

  /// Automatically start playback if this scene is designated as active,
  /// or if requested by the user.
  Future<void> _startPlaybackIfNeeded({bool force = false}) async {
    if (!mounted) return;

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

      final choice = await resolver.resolvePreferredStream(widget.scene);
      if (choice != null && mounted) {
        final mediaHeaders = ref.read(mediaPlaybackHeadersProvider);
        final castStateBeforeStart = ref.read(castServiceProvider);
        final shouldRestartCastForScene =
            castStateBeforeStart.isCasting &&
            castStateBeforeStart.activeSession != null &&
            playerState.activeScene?.id != widget.scene.id;

        final currentPlayerState = ref.read(playerStateProvider);
        final resumeSec = widget.scene.resumeTime;
        Duration? resumePosition;
        if (currentPlayerState.resumePlayPosition &&
            resumeSec != null &&
            resumeSec > 0) {
          final totalDuration = widget.scene.files.firstOrNull?.duration ?? 0.0;
          if (totalDuration > 0) {
            final percentage = resumeSec / totalDuration;
            if (percentage >= 0.1 && percentage <= 0.9) {
              resumePosition = Duration(
                milliseconds: (resumeSec * 1000).round(),
              );
            }
          } else {
            // Fallback if no duration metadata is available
            resumePosition = Duration(milliseconds: (resumeSec * 1000).round());
          }
        }

        await ref
            .read(playerStateProvider.notifier)
            .playScene(
              widget.scene,
              choice.url,
              mimeType: choice.mimeType,
              streamLabel: choice.label,
              streamSource: force ? 'manual-start' : 'auto-start',
              httpHeaders: mediaHeaders,
              initialPosition: resumePosition,
            );

        if (shouldRestartCastForScene && mounted) {
          await _restartCastForCurrentScene(
            streamUrl: choice.url,
            startPosition: resumePosition ?? Duration.zero,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _restartCastForCurrentScene({
    required String streamUrl,
    required Duration startPosition,
  }) async {
    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    final localPlayer = ref.read(playerStateProvider).player;
    final localWasPlaying = localPlayer?.state.playing ?? false;

    if (localWasPlaying) {
      playerStateNotifier.pause();
    }

    final media = dc.CastMedia(
      url: streamUrl,
      type: detectCastMediaType(streamUrl),
      title: widget.scene.displayTitle,
      startPosition: startPosition > Duration.zero ? startPosition : null,
    );

    try {
      await ref
          .read(castServiceProvider.notifier)
          .restartActiveSessionWithMedia(
            media,
            localResumePosition: startPosition,
            localWasPlaying: localWasPlaying,
          );
    } catch (e) {
      AppLogStore.instance.add(
        'SceneVideoPlayer: failed to restart cast for scene ${widget.scene.id}: $e',
        source: 'scene_video_player',
      );
      if (localWasPlaying) {
        playerStateNotifier.play();
      }
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

  /// Toggles between inline and immersive fullscreen mode.
  Future<void> _toggleFullScreen() async {
    if (!mounted) return;

    var playerState = ref.read(playerStateProvider);
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
      ref
          .read(playerStateProvider.notifier)
          .syncBackgroundToActiveScene(context);
      ref.read(playerStateProvider.notifier).requestExitFullscreen();
    } else {
      // Fullscreen overlay always renders the global active scene.
      // Ensure the scene details page owns the global player before entering
      // fullscreen, otherwise a previously active scene can be shown.
      if (playerState.activeScene?.id != widget.scene.id) {
        await _startPlaybackIfNeeded(force: true);
        if (!mounted) return;
        playerState = ref.read(playerStateProvider);
        if (playerState.activeScene?.id != widget.scene.id) {
          AppLogStore.instance.add(
            'SceneVideoPlayer [${widget.scene.id}] fullscreen aborted: active scene remains ${playerState.activeScene?.id}',
            source: 'SceneVideoPlayer',
          );
          return;
        }
      }

      AppLogStore.instance.add(
        'SceneVideoPlayer [${widget.scene.id}] entering fullscreen via global state',
        source: 'SceneVideoPlayer',
      );
      final notifier = ref.read(playerStateProvider.notifier);
      notifier.setViewMode(PlayerViewMode.fullscreen);
      notifier.requestEnterFullscreen();
    }
  }

  Future<void> _openRandomScene() async {
    final randomScene = await ref
        .read(sceneRandomNavigationControllerProvider)
        .getRandomScene(excludeSceneId: widget.scene.id);
    if (!mounted || randomScene == null) return;

    final router = GoRouter.of(context);
    router.push('/scenes/scene/${randomScene.id}', extra: true);
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
            autofocus: false,
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

    // Main playback surface.
    return LayoutBuilder(
      builder: (context, layoutConstraints) {
        final availableWidth = layoutConstraints.maxWidth;
        final intendedHeight = availableWidth / aspectRatio;

        Widget player = AspectRatio(
          aspectRatio: aspectRatio,
          child: Hero(
            tag: 'scene_player_${widget.scene.id}',
            child: PlayerSurface(
              scene: widget.scene,
              controller: controller,
              onFullScreenToggle: _toggleFullScreen,
              onRandomScene: _openRandomScene,
              onInlineBack: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                }
              },
              fit: BoxFit.contain,
              squareFit: BoxFit.contain,
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
