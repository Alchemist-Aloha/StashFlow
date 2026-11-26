import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';
import '../graphql/scenes.graphql.dart';

/// Represents a potential video stream candidate for a scene.
class StreamChoice {
  const StreamChoice({required this.url, required this.mimeType, this.label});

  /// The absolute URL to the video stream.
  final String url;

  /// The MIME type of the stream (e.g., 'video/mp4', 'application/vnd.apple.mpegurl').
  final String mimeType;

  /// A human-readable label from the server (e.g., 'Direct', 'HLS').
  final String? label;
}

typedef StreamResolver = Future<StreamChoice?> Function(Scene scene);

/// SharedPreferences key for the default stream source kind.
const defaultStreamSourceKey = 'video_default_stream_source';

/// Stream source kinds Stash exposes via `sceneStreams`, in menu order.
const streamSourceKinds = ['direct', 'mp4', 'webm', 'hls', 'dash'];

/// SharedPreferences key for the default transcode resolution.
const defaultStreamResolutionKey = 'video_default_stream_resolution';

/// Stash `StreamingResolutionEnum` values with their heights; `ORIGINAL`
/// is the source file's height. Settings list them in this order.
const streamResolutionHeights = {
  'ORIGINAL': null,
  'FOUR_K': 2160,
  'FULL_HD': 1080,
  'STANDARD_HD': 720,
  'STANDARD': 480,
  'LOW': 240,
};

/// Stash's `resolution` query value; streams without one are original.
String streamResolution(String url) =>
    Uri.tryParse(url)?.queryParameters['resolution'] ?? 'ORIGINAL';

/// Picks the highest of [options] not above [preferred], preferring the
/// untranscoded original on ties; when all are higher, the lowest one.
StreamChoice? pickStreamResolution(
  List<StreamChoice> options,
  String preferred, {
  int? sourceHeight,
}) {
  int height(String resolution) =>
      streamResolutionHeights[resolution] ??
      (resolution == 'ORIGINAL' ? sourceHeight : null) ??
      1 << 30;
  final target = height(preferred);
  StreamChoice? best;
  StreamChoice? lowest;
  for (final option in options) {
    final h = height(streamResolution(option.url));
    if (lowest == null || h < height(streamResolution(lowest.url))) {
      lowest = option;
    }
    if (h > target) continue;
    final bestHeight = best == null ? -1 : height(streamResolution(best.url));
    if (h > bestHeight ||
        (h == bestHeight && streamResolution(option.url) == 'ORIGINAL')) {
      best = option;
    }
  }
  return best ?? lowest;
}

/// Classifies a Stash stream URL (`/stream`, `/stream.m3u8`, ...) by kind.
String streamSourceKind(String url) {
  final segment = Uri.tryParse(url)?.pathSegments.lastOrNull ?? '';
  final dot = segment.lastIndexOf('.');
  if (dot < 0) return 'direct';
  return switch (segment.substring(dot + 1).toLowerCase()) {
    'm3u8' => 'hls',
    'mpd' => 'dash',
    final ext => ext,
  };
}

/// Fetches every stream endpoint Stash offers for [sceneId].
Future<List<StreamChoice>> fetchSceneStreams(Ref ref, String sceneId) async {
  final result = await ref
      .read(graphqlClientProvider)
      .query$SceneStreams(
        Options$Query$SceneStreams(
          variables: Variables$Query$SceneStreams(id: sceneId),
          fetchPolicy: FetchPolicy.networkOnly,
          // The normalized Scene re-read misses sceneStreams; use raw data.
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        ),
      );
  if (result.exception != null) throw result.exception!;
  final endpoint = Uri.parse(ref.read(serverUrlProvider));
  return [
    for (final s
        in result.parsedData?.findScene?.sceneStreams ??
            const <Query$SceneStreams$findScene$sceneStreams>[])
      StreamChoice(
        url: resolveGraphqlMediaUrl(rawUrl: s.url, graphqlEndpoint: endpoint),
        mimeType: s.mime_type ?? 'video/mp4',
        label: s.label,
      ),
  ];
}

/// Stream endpoints for the source menu; kept only while a menu watches it.
final sceneStreamsProvider = FutureProvider.autoDispose
    .family<List<StreamChoice>, String>(fetchSceneStreams);

/// Resolves the scene stream matching the default source preference, falling
/// back to Stash's direct stream when that kind is unavailable.
final streamResolverProvider = Provider<StreamResolver>(
  (ref) => (scene) async {
    final direct = await resolvePreferredStream(scene);
    final kind =
        ref.read(sharedPreferencesProvider).getString(defaultStreamSourceKey) ??
        'direct';
    if (kind == 'direct') return direct;
    try {
      final streams = await fetchSceneStreams(ref, scene.id);
      final resolution =
          ref
              .read(sharedPreferencesProvider)
              .getString(defaultStreamResolutionKey) ??
          'ORIGINAL';
      return pickStreamResolution(
            streams.where((s) => streamSourceKind(s.url) == kind).toList(),
            resolution,
            sourceHeight: scene.files.firstOrNull?.height,
          ) ??
          direct;
    } on Object catch (e) {
      AppLogStore.instance.add(
        'sceneStreams failed scene=${scene.id}: $e',
        source: 'stream_resolver',
      );
      return direct;
    }
  },
);

/// Resolves Stash's direct file stream, or `null` when no path is available.
Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
  final url = scene.paths.stream?.trim();
  if (url == null || url.isEmpty) return null;
  return StreamChoice(url: url, mimeType: 'video/mp4', label: 'Direct');
}
