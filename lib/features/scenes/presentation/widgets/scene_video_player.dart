import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class SceneVideoPlayer extends ConsumerStatefulWidget {
  final Scene scene;
  const SceneVideoPlayer({required this.scene, super.key});

  @override
  ConsumerState<SceneVideoPlayer> createState() => _SceneVideoPlayerState();
}

class _SceneVideoPlayerState extends ConsumerState<SceneVideoPlayer> {
  static const _preferSceneStreamsKey = 'prefer_scene_streams';
  static Future<_PrewarmResult>? _pathsStreamPrewarmFuture;

  bool _isStarting = false;
  String? _autoStartedSceneId;

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
    if (oldWidget.scene.id != widget.scene.id) {
      _autoStartedSceneId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startPlaybackIfNeeded();
      });
    }
  }

  Future<void> _startPlaybackIfNeeded({bool force = false}) async {
    if (!mounted || _isStarting) return;

    final playerState = ref.read(playerStateProvider);
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

      final prewarmFuture = _prewarmPathsStreamOnce(mediaHeaders);

      if (streamUrl.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stream URL available')),
        );
        return;
      }

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
        } else {
          AppLogStore.instance.add(
            'startup header-probe scene=${widget.scene.id} mime=unknown elapsed=${mimeProbeStopwatch.elapsedMilliseconds}ms',
            source: 'player_startup',
          );
        }
      }

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

          AppLogStore.instance.add(
            'startup prewarm-result scene=${widget.scene.id} attempted=${result.attempted} success=${result.succeeded} latency=${result.latencyMs ?? -1}ms',
            source: 'player_startup',
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

  Future<_PrewarmResult> _prewarmPathsStreamOnce(Map<String, String> headers) {
    final existingFuture = _pathsStreamPrewarmFuture;
    if (existingFuture != null) {
      AppLogStore.instance.add(
        'startup prewarm reused scene=${widget.scene.id}',
        source: 'player_startup',
      );
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
      AppLogStore.instance.add(
        'startup prewarm skipped scene=${widget.scene.id} reason=empty_stream_url',
        source: 'player_startup',
      );
      _pathsStreamPrewarmFuture = Future<_PrewarmResult>.value(
        const _PrewarmResult(attempted: false, succeeded: false),
      );
      return _pathsStreamPrewarmFuture!;
    }

    AppLogStore.instance.add(
      'startup prewarm start scene=${widget.scene.id} url=$streamUrl',
      source: 'player_startup',
    );

    final future = _prewarmStreamRequest(streamUrl, headers);
    _pathsStreamPrewarmFuture = future;
    return future;
  }

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

  Future<void> _toggleFullScreen() async {
    final playerState = ref.read(playerStateProvider);
    if (playerState.isFullScreen) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (context) => FullscreenPlayerPage(
            scene: widget.scene,
          ),
        ),
      );
      // Ensure state is reset when the pushed route is popped, 
      // regardless of how it was popped.
      if (mounted) {
        ref.read(playerStateProvider.notifier).setFullScreen(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final isActive = playerState.activeScene?.id == widget.scene.id;
    
    AppLogStore.instance.add(
      'SceneVideoPlayer build scene=${widget.scene.id} isActive=$isActive hasController=${playerState.videoPlayerController != null}',
      source: 'SceneVideoPlayer',
    );

    final aspectRatio = _effectiveAspectRatio(
      playerState.videoPlayerController,
    );

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

    if (controller == null || !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
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
          NativeVideoControls(
            controller: controller,
            useDoubleTapSeek: playerState.useDoubleTapSeek,
            enableNativePip: playerState.enableNativePip,
            onFullScreenToggle: _toggleFullScreen,
            scene: widget.scene,
          ),
        ],
      ),
    );
  }
}

class FullscreenPlayerPage extends ConsumerStatefulWidget {
  final String sceneId;
  const FullscreenPlayerPage({required this.sceneId, super.key});

  @override
  ConsumerState<FullscreenPlayerPage> createState() => _FullscreenPlayerPageState();
}

class _FullscreenPlayerPageState extends ConsumerState<FullscreenPlayerPage> {
  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerStateProvider.notifier).setFullScreen(true);
    });
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Ensure fullScreen state is reset on any exit (back gesture, toggle, pop)
    // Use read() here because we are in dispose.
    Future.microtask(() {
      if (ref.mounted) {
        ref.read(playerStateProvider.notifier).setFullScreen(false);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final controller = playerState.videoPlayerController;
    final scene = playerState.activeScene;

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
    );
  }
}

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
