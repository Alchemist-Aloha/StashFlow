import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/entities/scene.dart';
import '../providers/video_player_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import 'native_video_controls.dart';

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
      final resolver = ref.read(streamResolverProvider.notifier);
      
      // Perform a background "prewarm" to fetch stream URL and test connectivity.
      final prewarmResult = await _prewarmStream(widget.scene);
      ref.read(playerStateProvider.notifier).setPrewarmResult(
        attempted: prewarmResult.attempted,
        succeeded: prewarmResult.succeeded,
        latencyMs: prewarmResult.latencyMs,
      );

      final choice = await resolver.resolvePreferredStream(widget.scene);
      if (choice != null && mounted) {
        final mediaHeaders = ref.read(mediaHeadersProvider);
        await ref.read(playerStateProvider.notifier).playScene(
          widget.scene,
          choice.url,
          mimeType: choice.mimeType,
          streamLabel: choice.label,
          streamSource: force ? 'manual-start' : 'auto-start',
          httpHeaders: mediaHeaders,
          prewarmAttempted: prewarmResult.attempted,
          prewarmSucceeded: prewarmResult.succeeded,
          prewarmLatencyMs: prewarmResult.latencyMs,
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
    final stopwatch = Stopwatch()..start();
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final resolver = ref.read(streamResolverProvider.notifier);
      final choice = await resolver.resolvePreferredStream(scene);
      if (choice == null) return const _PrewarmResult(attempted: false, succeeded: false);

      final uri = Uri.parse(choice.url);
      final request = await client.getUrl(uri);
      
      final headers = ref.read(mediaHeadersProvider);
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      final res = await response.timeout(const Duration(seconds: 5));
      // Drain response to ensure connection is properly closed/reused.
      await res.drain<void>();
      stopwatch.stop();
      return _PrewarmResult(
        attempted: true,
        succeeded: true,
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
    final playerState = ref.read(playerStateProvider);
    if (playerState.isFullScreen) {
      if (context.mounted) {
        context.pop();
      }
    } else {
      context.push('/scenes/scene/${widget.scene.id}/fullscreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    
    final aspectRatio = _effectiveAspectRatio(
      playerState.videoPlayerController,
    );

    // If this player isn't active, show a placeholder with a play button.
    if (playerState.activeScene?.id != widget.scene.id) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: Colors.black,
          child: Center(
            child: _isStarting
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 64,
                      color: Colors.white,
                    ),
                    onPressed: () => _startPlaybackIfNeeded(force: true),
                  ),
          ),
        ),
      );
    }

    final controller = playerState.videoPlayerController;

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
        child: Stack(
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
  ConsumerState<FullscreenPlayerPage> createState() => _FullscreenPlayerPageState();
}

class _FullscreenPlayerPageState extends ConsumerState<FullscreenPlayerPage> {
  @override
  void initState() {
    super.initState();
    // Request landscape and hide system UI immediately upon entering fullscreen.
    _enterFullScreen();
  }

  @override
  void dispose() {
    // Reset orientation and show system UI upon leaving fullscreen.
    _exitFullScreen();
    super.dispose();
  }

  Future<void> _enterFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      ref.read(playerStateProvider.notifier).setFullScreen(true);
    }
  }

  Future<void> _exitFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      ref.read(playerStateProvider.notifier).setFullScreen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
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

    return Material(
      color: Colors.black,
      child: Hero(
        tag: 'scene_player_${widget.sceneId}',
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
              NativeVideoControls(
                controller: controller,
                useDoubleTapSeek: playerState.useDoubleTapSeek,
                enableNativePip: playerState.enableNativePip,
                onFullScreenToggle: () => Navigator.of(context).pop(),
                scene: scene,
              ),
            ],
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
