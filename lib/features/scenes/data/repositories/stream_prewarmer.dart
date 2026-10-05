import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  final Map<String, _PrewarmRequest> _activeRequests = {};
  HttpClient? _client;

  @override
  void build() {
    // HttpClient (dart:io) is not supported on Web.
    if (kIsWeb) return;

    // Shared client allows for connection pooling (keep-alive).
    _client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5)
      ..idleTimeout = const Duration(seconds: 15);

    ref.onDispose(() {
      for (final sub in _activeRequests.values) {
        sub.cancel();
      }
      _activeRequests.clear();
      _client?.close(force: true);
      _client = null;
    });
  }

  /// Initiates a Byte-Range GET request for the given [scene] and [url].
  ///
  /// [rangeBytes] defaults to 2MB, which is enough to warm the route and fetch
  /// typical video headers without spending much bandwidth ahead of playback.
  Future<void> prewarm(
    Scene scene,
    String url, {
    Map<String, String>? headers,
    int rangeBytes = 2 * 1024 * 1024,
  }) async {
    if (kIsWeb) return;
    if (_client == null) return;
    if (_activeRequests.containsKey(scene.id)) return;
    final operation = _PrewarmRequest();
    _activeRequests[scene.id] = operation;
    // Bound connect, headers, and body together, including stalled servers.
    operation.timeout = Timer(const Duration(seconds: 5), () {
      if (identical(_activeRequests[scene.id], operation)) cancel(scene.id);
    });
    void finish() {
      operation.timeout?.cancel();
      if (identical(_activeRequests[scene.id], operation)) {
        _activeRequests.remove(scene.id);
      }
    }

    AppLogStore.instance.add(
      'StreamPrewarmer: prewarming scene=${scene.id} url=$url',
      source: 'stream_prewarmer',
    );

    try {
      final request = await _client!.getUrl(Uri.parse(url));
      if (!identical(_activeRequests[scene.id], operation)) {
        request.abort();
        return;
      }
      operation.request = request;
      headers?.forEach((k, v) => request.headers.add(k, v));

      // Request only the first chunk to minimize bandwidth usage while warming the pipe.
      request.headers.add(HttpHeaders.rangeHeader, 'bytes=0-${rangeBytes - 1}');

      final response = await request.close();
      if (!identical(_activeRequests[scene.id], operation)) {
        request.abort();
        return;
      }
      var receivedBytes = 0;
      // Drain compliant responses to preserve keep-alive, but enforce the
      // budget ourselves when a server ignores Range or sends a chunked body.
      operation.subscription = response.listen(
        (data) {
          if (!identical(_activeRequests[scene.id], operation)) return;
          receivedBytes += data.length;
          if (receivedBytes >= rangeBytes &&
              response.contentLength != rangeBytes) {
            cancel(scene.id);
          }
        },
        onDone: () {
          if (!identical(_activeRequests[scene.id], operation)) return;
          finish();
          AppLogStore.instance.add(
            'StreamPrewarmer: prewarm completed for scene=${scene.id}',
            source: 'stream_prewarmer',
          );
        },
        onError: (Object e) {
          if (!identical(_activeRequests[scene.id], operation)) return;
          finish();
          AppLogStore.instance.add(
            'StreamPrewarmer: prewarm error for scene=${scene.id}: $e',
            source: 'stream_prewarmer',
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!identical(_activeRequests[scene.id], operation)) return;
      finish();
      AppLogStore.instance.add(
        'StreamPrewarmer: prewarm exception for scene=${scene.id}: $e',
        source: 'stream_prewarmer',
      );
    }
  }

  /// Cancels any active prewarm request for the given [sceneId].
  void cancel(String sceneId) {
    final operation = _activeRequests.remove(sceneId);
    if (operation != null) {
      operation.cancel();
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
    final idsToCancel = _activeRequests.keys
        .where((id) => !sceneIds.contains(id))
        .toList();
    for (final id in idsToCancel) {
      cancel(id);
    }
  }
}

class _PrewarmRequest {
  HttpClientRequest? request;
  StreamSubscription<List<int>>? subscription;
  Timer? timeout;

  void cancel() {
    timeout?.cancel();
    request?.abort();
    unawaited(subscription?.cancel());
  }
}
