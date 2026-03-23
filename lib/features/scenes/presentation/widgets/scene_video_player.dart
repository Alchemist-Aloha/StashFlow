import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../providers/video_player_provider.dart';
import '../../domain/entities/scene.dart';
import '../../data/repositories/stream_resolver.dart';
import 'native_video_controls.dart';
import 'tiktok_scenes_view.dart';

/// A comprehensive video player widget for a single [Scene].
///
/// This widget handles the entire playback lifecycle:
/// 1. **Startup**: Resolves the best stream (direct or transcoded) using [StreamResolver].
/// 2. **Probing**: Verifies stream availability and MIME types via HTTP headers.
/// 3. **Prewarming**: Initiates a 'Range: bytes=0-0' request to minimize time-to-first-frame.
/// 4. **State Sync**: Coordinates with [playerStateProvider] for global control.
/// 5. **UI**: Displays the video surface with [NativeVideoControls] and handles fullscreen.
class SceneVideoPlayer extends ConsumerStatefulWidget {
  const SceneVideoPlayer({required this.scene, super.key});

  /// The scene to play.
  final Scene scene;

  @override
  ConsumerState<SceneVideoPlayer> createState() => _SceneVideoPlayerState();
}

class _SceneVideoPlayerState extends ConsumerState<SceneVideoPlayer> {
  static const _preferSceneStreamsKey = 'prefer_scene_streams';
  
  /// Static future to prevent redundant prewarm requests across widget rebuilds.
  static Future<_PrewarmResult>? _pathsStreamPrewarmFuture;

  bool _isStarting = false;
  String? _autoStartedSceneId;

  /// Determines the aspect ratio to use for the player container.
  /// 
  /// Priority:
  /// 1. Current [VideoPlayerController] initialized ratio.
  /// 2. Metadata from the first file in [widget.scene.files].
  /// 3. Default 16:9.
  double _effectiveAspectRatio(VideoPlayerController? controller) {
    final controllerRatio = controller?.value.aspectRatio;
    if (controllerRatio != null &&
        controllerRatio.isFinite &&
        controllerRatio > 0) {
      return controllerRatio;
    }

    if (widget.scene.files.isNotEmpty) {
      final file = widget.scene.files.first;
      final width = file.width;
      final height = file.height;
      if (width != null && height != null && width > 0 && height > 0) {
        return width / height;
      }
    }

    return 16 / 9;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlaybackIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant SceneVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart playback if the scene ID has changed
    if (oldWidget.scene.id != widget.scene.id) {
      _autoStartedSceneId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startPlaybackIfNeeded();
      });
    }
  }

  /// Initiates the complex playback startup sequence.
  Future<void> _startPlaybackIfNeeded({bool force = false}) async {
    if (!mounted || _isStarting) return;

    final playerState = ref.read(playerStateProvider);
    // Don't auto-start if already playing or starting this specific scene
    if (!force && _autoStartedSceneId == widget.scene.id) return;
    if (!force && playerState.activeScene?.id == widget.scene.id) return;

    setState(() => _isStarting = true);
    final startupStopwatch = Stopwatch()..start();
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final preferSceneStreams = prefs.getBool(_preferSceneStreamsKey) ?? true;
      final resolver = ref.read(streamResolverProvider.notifier);
      final resolveStopwatch = Stopwatch()..start();

      AppLogStore.instance.add(
        'startup begin scene=${widget.scene.id} preferSceneStreams=$preferSceneStreams',
        source: 'player_startup',
      );

      // 1. Resolve the best stream choice
      final choice = preferSceneStreams
          ? await resolver.resolvePreferredStream(widget.scene)
          : null;
      resolveStopwatch.stop();

      final streamUrl = choice?.url ?? widget.scene.paths.stream ?? '';
      var mimeType = choice?.mimeType ?? resolver.guessMimeType(streamUrl);
      final streamLabel = choice?.label;
      var streamSource = choice == null
          ? (preferSceneStreams ? 'paths.stream' : 'paths.stream(direct)')
          : 'sceneStreams';
      final mediaHeaders = ref.read(mediaHeadersProvider);

      AppLogStore.instance.add(
        'startup select scene=${widget.scene.id} source=$streamSource mime=$mimeType label=${streamLabel ?? '-'} resolve=${resolveStopwatch.elapsedMilliseconds}ms',
        source: 'player_startup',
      );

      // 2. Start prewarming the 'direct' stream URL in the background
      final prewarmFuture = _prewarmPathsStreamOnce(mediaHeaders);

      if (streamUrl.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stream URL available')),
        );
        return;
      }

      // 3. Probe MIME type if unknown to ensure proper controller selection
      if (mimeType == 'unknown') {
        final mimeProbeStopwatch = Stopwatch()..start();
        final probedMime = await resolver.probeMimeTypeFromHeaders(
          streamUrl,
          mediaHeaders,
        );
        mimeProbeStopwatch.stop();
        if (probedMime != null && probedMime.isNotEmpty) {
          mimeType = probedMime;
          streamSource = '$streamSource+header';
          AppLogStore.instance.add(
            'startup header-probe scene=${widget.scene.id} mime=$probedMime elapsed=${mimeProbeStopwatch.elapsedMilliseconds}ms',
            source: 'player_startup',
          );
        }
      }

      // 4. Dispatch the actual play command to the global provider
      _autoStartedSceneId = widget.scene.id;
      final playSceneStopwatch = Stopwatch()..start();
      await ref
          .read(playerStateProvider.notifier)
          .playScene(
            widget.scene,
            streamUrl,
            mimeType: mimeType,
            streamLabel: streamLabel,
            streamSource: streamSource,
            httpHeaders: mediaHeaders,
            prewarmAttempted: false,
            prewarmSucceeded: false,
          );
      playSceneStopwatch.stop();

      startupStopwatch.stop();
      AppLogStore.instance.add(
        'startup playScene-dispatched scene=${widget.scene.id} elapsed=${startupStopwatch.elapsedMilliseconds}ms playScene=${playSceneStopwatch.elapsedMilliseconds}ms source=$streamSource mime=$mimeType',
        source: 'player_startup',
      );

      // 5. Update state with prewarm results once they arrive
      unawaited(
        prewarmFuture.then((result) {
          if (!mounted) return;
          final activeSceneId = ref.read(playerStateProvider).activeScene?.id;
          if (activeSceneId != widget.scene.id) return;

          ref
              .read(playerStateProvider.notifier)
              .setPrewarmResult(
                attempted: result.attempted,
                succeeded: result.succeeded,
                latencyMs: result.latencyMs,
              );
        }),
      );
    } catch (error, stack) {
      startupStopwatch.stop();
      AppLogStore.instance.add(
        'startup error scene=${widget.scene.id} elapsed=${startupStopwatch.elapsedMilliseconds}ms error=$error\n$stack',
        source: 'player_startup',
      );
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  /// Initiates a background prewarm for the scene's direct stream path.
  Future<_PrewarmResult> _prewarmPathsStreamOnce(Map<String, String> headers) {
    final existingFuture = _pathsStreamPrewarmFuture;
    if (existingFuture != null) {
      return existingFuture;
    }

    final rawStreamUrl = widget.scene.paths.stream ?? '';
    final client = ref.read(graphqlClientProvider);
    final graphqlEndpoint = client.link is HttpLink
        ? (client.link as HttpLink).uri
        : Uri.parse(
            rawStreamUrl.isEmpty ? 'https://localhost/graphql' : rawStreamUrl,
          );
    final streamUrl = resolveGraphqlMediaUrl(
      rawUrl: rawStreamUrl,
      graphqlEndpoint: graphqlEndpoint,
    );
    
    if (streamUrl.isEmpty) {
      _pathsStreamPrewarmFuture = Future<_PrewarmResult>.value(
        const _PrewarmResult(attempted: false, succeeded: false),
      );
      return _pathsStreamPrewarmFuture!;
    }

    final future = _prewarmStreamRequest(streamUrl, headers);
    _pathsStreamPrewarmFuture = future;
    return future;
  }

  /// Sends a HEAD/GET Range request to pre-establish TCP/TLS connections with the server.
  Future<_PrewarmResult> _prewarmStreamRequest(
    String streamUrl,
    Map<String, String> headers,
  ) async {
    final stopwatch = Stopwatch()..start();
    final uri = Uri.tryParse(streamUrl);
    if (uri == null) {
      stopwatch.stop();
      return _PrewarmResult(
        attempted: false,
        succeeded: false,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);

    try {
      final req = await client
          .openUrl('GET', uri)
          .timeout(const Duration(seconds: 3));
      headers.forEach(req.headers.set);
      req.headers.set('Range', 'bytes=0-0');

      final res = await req.close().timeout(const Duration(seconds: 4));
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
            Material(
              color: Colors.transparent,
              child: NativeVideoControls(
                controller: controller,
                useDoubleTapSeek: playerState.useDoubleTapSeek,
                enableNativePip: playerState.enableNativePip,
                onFullScreenToggle: _toggleFullScreen,
                scene: widget.scene,
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
  late PlayerState _playerStateNotifier;
  late FullScreenMode _fullScreenModeNotifier;

  @override
  void initState() {
    super.initState();
    _playerStateNotifier = ref.read(playerStateProvider.notifier);
    _fullScreenModeNotifier = ref.read(fullScreenModeProvider.notifier);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterFullscreen();
      _playerStateNotifier.setFullScreen(true);
    });
  }

  /// Sets up the immersive landscape environment.
  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore system UI and portrait orientations.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Notify providers that we've exited fullscreen.
    Future.microtask(() {
      _playerStateNotifier.setFullScreen(false);
      _fullScreenModeNotifier.set(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final controller = playerState.videoPlayerController;
    final scene = playerState.activeScene;

    // Error handling for state mismatches during transition.
    if (controller == null || !controller.value.isInitialized || scene == null || scene.id != widget.sceneId) {
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
