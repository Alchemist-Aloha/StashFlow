import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';

part 'stream_prewarmer.g.dart';

/// A utility that performs network-level prewarming of video streams.
///
/// By performing a partial GET request (Byte-Range), we:
/// 1. Warm up DNS, TCP, and TLS connections.
/// 2. Trigger server-side file system caching.
/// 3. Prime the network path for the upcoming media data.
@Riverpod(keepAlive: true)
class StreamPrewarmer extends _$StreamPrewarmer {
  final Map<String, StreamSubscription> _activeRequests = {};
  late final HttpClient _client;

  @override
  void build() {
    // Shared client allows for connection pooling (keep-alive).
    _client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5)
      ..idleTimeout = const Duration(seconds: 15);

    ref.onDispose(() {
      for (final sub in _activeRequests.values) {
        sub.cancel();
      }
      _client.close(force: true);
    });
  }

  /// Initiates a Byte-Range GET request for the given [scene] and [url].
  ///
  /// [rangeBytes] defaults to 2MB, which is usually enough to fetch
  /// the video headers (moov atom) and start the initial buffer.
  Future<void> prewarm(
    Scene scene,
    String url, {
    Map<String, String>? headers,
    int rangeBytes = 2 * 1024 * 1024,
  }) async {
    if (_activeRequests.containsKey(scene.id)) return;

    AppLogStore.instance.add(
      'StreamPrewarmer: prewarming scene=${scene.id} url=$url',
      source: 'stream_prewarmer',
    );

    try {
      final request = await _client.getUrl(Uri.parse(url));
      headers?.forEach((k, v) => request.headers.add(k, v));
      
      // Request only the first chunk to minimize bandwidth usage while warming the pipe.
      request.headers.add(HttpHeaders.rangeHeader, 'bytes=0-${rangeBytes - 1}');

      final response = await request.close();

      // We MUST consume the response stream to ensure the connection is fully
      // utilized and can be returned to the pool for reuse.
      final subscription = response.listen(
        (data) {
          // Data is discarded; we only care about the side effects of the request.
        },
        onDone: () {
          _activeRequests.remove(scene.id);
          AppLogStore.instance.add(
            'StreamPrewarmer: prewarm completed for scene=${scene.id}',
            source: 'stream_prewarmer',
          );
        },
        onError: (e) {
          _activeRequests.remove(scene.id);
          AppLogStore.instance.add(
            'StreamPrewarmer: prewarm error for scene=${scene.id}: $e',
            source: 'stream_prewarmer',
          );
        },
        cancelOnError: true,
      );

      _activeRequests[scene.id] = subscription;
    } catch (e) {
      AppLogStore.instance.add(
        'StreamPrewarmer: prewarm exception for scene=${scene.id}: $e',
        source: 'stream_prewarmer',
      );
    }
  }

  /// Cancels any active prewarm request for the given [sceneId].
  void cancel(String sceneId) {
    if (_activeRequests.containsKey(sceneId)) {
      _activeRequests[sceneId]?.cancel();
      _activeRequests.remove(sceneId);
      AppLogStore.instance.add(
        'StreamPrewarmer: cancelled prewarm for scene=$sceneId',
        source: 'stream_prewarmer',
      );
    }
  }

  /// Cancels all active prewarm requests except those for the provided [sceneIds].
  ///
  /// This is used to clean up "stale" prewarms as the user moves through the queue.
  void cancelAllExcept(Set<String> sceneIds) {
    final idsToCancel =
        _activeRequests.keys.where((id) => !sceneIds.contains(id)).toList();
    for (final id in idsToCancel) {
      cancel(id);
    }
  }
}
