import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';
import '../graphql/scenes.graphql.dart';

part 'stream_resolver.g.dart';

/// Represents a potential video stream candidate for a scene.
class StreamChoice {
  const StreamChoice({required this.url, required this.mimeType, this.label});

  /// The absolute URL to the video stream.
  final String url;

  /// The MIME type of the stream (e.g., 'video/mp4', 'application/vnd.apple.mpegurl').
  final String mimeType;

  /// A human-readable label from the server (e.g., 'Direct', 'HLS').
  final String? label;

  /// Calculates a priority score for this stream candidate.
  ///
  /// Preference order:
  /// 1. Direct MP4 (300) - Lowest latency, highest compatibility.
  /// 2. General MP4 (250)
  /// 3. HLS/M3U8 (200) - Best for adaptive bitrate but higher startup latency.
  /// 4. DASH (150)
  /// 5. Others (100)
  int get score {
    final lowerMime = mimeType.toLowerCase();
    final lowerLabel = (label ?? '').toLowerCase();
    if (lowerMime.contains('mpegurl') || lowerMime.contains('hls')) return 200;
    if (lowerMime.contains('dash')) return 150;
    if (lowerMime.contains('mp4') && lowerLabel.contains('direct')) return 300;
    if (lowerMime.contains('mp4')) return 250;
    return 100;
  }
}

/// A utility that resolves the best available video stream for a given [Scene].
///
/// Stash provides multiple ways to stream a scene:
/// 1. Direct file paths (if the client has network access to the storage).
/// 2. Scene-specific stream endpoints (transcoded or direct-from-server).
///
/// This class handles the logic of choosing between these options based on
/// user preferences and stream availability.
@riverpod
class StreamResolver extends _$StreamResolver {
  /// In-memory cache for resolved stream URLs.
  final Map<String, StreamChoice> _urlCache = {};

  @override
  void build() {
    // Keep resolver alive during async stream selection/probing work.
    ref.keepAlive();
  }

  /// Resolves the preferred stream URL and its metadata for a given [scene].
  ///
  /// It first attempts to fetch available stream options from the Stash API.
  /// If multiple options are available, it selects the best one based on [StreamChoice.score].
  ///
  /// If no API streams are found, it falls back to the scene's direct path.
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    if (_urlCache.containsKey(scene.id)) {
      AppLogStore.instance.add(
        'resolver hit cache scene=${scene.id} url=${_shortUrl(_urlCache[scene.id]!.url)}',
        source: 'stream_resolver',
      );
      return _urlCache[scene.id];
    }

    final client = ref.read(graphqlClientProvider);
    final queryStopwatch = Stopwatch()..start();

    // Fetch available stream endpoints for the scene
    final result = await client.query$SceneStreamsForPlayer(
      Options$Query$SceneStreamsForPlayer(
        variables: Variables$Query$SceneStreamsForPlayer(id: scene.id),
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    queryStopwatch.stop();
    final exceptionSummary = _summarizeException(result.exception);

    AppLogStore.instance.add(
      'resolver query scene=${scene.id} elapsed=${queryStopwatch.elapsedMilliseconds}ms hasException=${result.hasException}${exceptionSummary == null || exceptionSummary.isEmpty ? '' : ' error=$exceptionSummary'}',
      source: 'stream_resolver',
    );

    final List<Query$SceneStreamsForPlayer$sceneStreams> rootStreams =
        result.parsedData?.sceneStreams ?? [];
    final List<Query$SceneStreamsForPlayer$findScene$sceneStreams>
        nestedStreams = result.parsedData?.findScene?.sceneStreams ?? [];

    final List<StreamChoice> choices = [];
    for (final s in rootStreams) {
      choices.add(StreamChoice(
        url: s.url,
        mimeType: s.mime_type ?? 'video/mp4',
        label: s.label,
      ));
    }
    for (final s in nestedStreams) {
      choices.add(StreamChoice(
        url: s.url,
        mimeType: s.mime_type ?? 'video/mp4',
        label: s.label,
      ));
    }

    if (choices.isEmpty) {
      AppLogStore.instance.add(
        'resolver no api streams scene=${scene.id}, falling back to path',
        source: 'stream_resolver',
      );
      return null;
    }

    // Sort by priority and pick the best one
    choices.sort((a, b) => b.score.compareTo(a.score));
    final best = choices.first;
    _urlCache[scene.id] = best;

    AppLogStore.instance.add(
      'resolver selected scene=${scene.id} score=${best.score} url=${_shortUrl(best.url)}',
      source: 'stream_resolver',
    );

    return best;
  }

  String _shortUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final queryStr = uri.query;
      return '${uri.path}${queryStr.isEmpty ? '' : '?${queryStr.substring(0, queryStr.length > 20 ? 20 : queryStr.length)}...'}';
    } catch (_) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  String? _summarizeException(OperationException? ex) {
    if (ex == null) return null;
    if (ex.graphqlErrors.isNotEmpty) {
      return ex.graphqlErrors.map((e) => e.message).join(', ');
    }
    return ex.linkException?.toString();
  }
}
