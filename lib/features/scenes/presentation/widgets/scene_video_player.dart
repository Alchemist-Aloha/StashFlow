import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/video_player_provider.dart';
import '../../domain/entities/scene.dart';
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
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final preferSceneStreams = prefs.getBool(_preferSceneStreamsKey) ?? true;
      final resolver = ref.read(streamResolverProvider.notifier);

      final choice = preferSceneStreams
          ? await resolver.resolvePreferredStream(widget.scene)
          : null;
      
      final streamUrl = choice?.url ?? widget.scene.paths.stream ?? '';
      var mimeType = choice?.mimeType ?? resolver.guessMimeType(streamUrl);
      final streamLabel = choice?.label;
      var streamSource = choice == null
          ? (preferSceneStreams ? 'paths.stream' : 'paths.stream(direct)')
          : 'sceneStreams';
      final mediaHeaders = ref.read(mediaHeadersProvider);

      final prewarmResult = await _prewarmPathsStreamOnce(mediaHeaders);
      if (prewarmResult.attempted) {
        streamSource = prewarmResult.succeeded
            ? '$streamSource+prewarm'
            : '$streamSource+prewarm-fail';
      }

      if (streamUrl.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stream URL available')),
        );
        return;
      }

      if (mimeType == 'unknown') {
        final probedMime = await resolver.probeMimeTypeFromHeaders(
          streamUrl,
          mediaHeaders,
        );
        if (probedMime != null && probedMime.isNotEmpty) {
          mimeType = probedMime;
          streamSource = '$streamSource+header';
        }
      }

      _autoStartedSceneId = widget.scene.id;
      await ref
          .read(playerStateProvider.notifier)
          .playScene(
            widget.scene,
            streamUrl,
            mimeType: mimeType,
            streamLabel: streamLabel,
            streamSource: streamSource,
            httpHeaders: mediaHeaders,
            prewarmAttempted: prewarmResult.attempted,
            prewarmSucceeded: prewarmResult.succeeded,
            prewarmLatencyMs: prewarmResult.latencyMs,
          );
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  Future<_PrewarmResult> _prewarmPathsStreamOnce(Map<String, String> headers) {
    final existingFuture = _pathsStreamPrewarmFuture;
    if (existingFuture != null) return existingFuture;

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

    if (playerState.activeScene?.id != widget.scene.id) {
      return AspectRatio(
        aspectRatio: 16 / 9,
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
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(child: Chewie(controller: chewieController)),
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
                onPressed: () => ref.read(playerStateProvider.notifier).playNext(),
                icon: const Icon(Icons.skip_next),
                label: Text('Next: ${nextScene.title}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                const Text('Autoplay Next', style: TextStyle(color: Colors.white70, fontSize: 10)),
                Switch.adaptive(
                  value: playerState.autoplayNext,
                  onChanged: (val) => ref.read(playerStateProvider.notifier).setAutoplayNext(val),
                  activeColor: context.colors.secondary,
                ),
              ],
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
