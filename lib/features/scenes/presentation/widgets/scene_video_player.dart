import 'dart:io';
import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
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
import '../../domain/entities/scene_title_utils.dart';
import '../providers/playback_queue_provider.dart';
import '../../data/repositories/stream_resolver.dart';

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

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final nextScene = ref.watch(playbackQueueProvider.notifier).getNextScene();
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

    final chewieController = playerState.chewieController;

    if (chewieController == null) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        children: [
          Positioned.fill(child: Chewie(controller: chewieController)),
          if (playerState.showVideoDebugInfo)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'mime: ${playerState.streamMimeType ?? 'unknown'}'
                  '${playerState.streamLabel == null || playerState.streamLabel!.isEmpty ? '' : '  label: ${playerState.streamLabel}'}'
                  '${playerState.streamSource == null || playerState.streamSource!.isEmpty ? '' : '  src: ${playerState.streamSource}'}'
                  '${playerState.prewarmAttempted != true ? '' : '  prewarm: ${playerState.prewarmSucceeded == true ? 'ok' : 'fail'}${playerState.prewarmLatencyMs == null ? '' : '/${playerState.prewarmLatencyMs}ms'}'}'
                  '${playerState.startupLatencyMs == null ? '' : '  start: ${playerState.startupLatencyMs}ms'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          if (nextScene != null)
            Positioned(
              bottom: 50,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(playerStateProvider.notifier).playNext(),
                icon: const Icon(Icons.skip_next),
                label: Text('Next: ${nextScene.displayTitle}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
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
