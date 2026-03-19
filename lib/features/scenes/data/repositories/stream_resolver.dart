import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../domain/entities/scene.dart';

part 'stream_resolver.g.dart';

class StreamChoice {
  const StreamChoice({required this.url, required this.mimeType, this.label});
  final String url;
  final String mimeType;
  final String? label;

  int get score {
    final lowerMime = mimeType.toLowerCase();
    final lowerLabel = (label ?? '').toLowerCase();
    if (lowerMime.contains('mpegurl') || lowerMime.contains('hls')) return 200;
    if (lowerMime.contains('dash')) return 150;
    // Prefer direct stream (fastest, no manifest parsing needed)
    if (lowerMime.contains('mp4') && lowerLabel.contains('direct')) return 300;
    if (lowerMime.contains('mp4')) return 250;
    return 100;
  }
}

@riverpod
class StreamResolver extends _$StreamResolver {
  @override
  void build() {}

  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql('''
          query SceneStreamsForPlayer(\$id: ID!) {
            sceneStreams(id: \$id) {
              url
              mime_type
              label
            }
            findScene(id: \$id) {
              sceneStreams {
                url
                mime_type
                label
              }
            }
          }
        '''),
        variables: <String, dynamic>{'id': scene.id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) return null;

    final rootStreams =
        ((result.data?['sceneStreams']) as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];
    final nestedStreams =
        ((result.data?['findScene']?['sceneStreams']) as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];
    final streams = rootStreams.isNotEmpty ? rootStreams : nestedStreams;

    final graphqlEndpoint = client.link is HttpLink
        ? (client.link as HttpLink).uri
        : Uri.parse(scene.paths.stream ?? 'https://localhost/graphql');

    if (streams.isEmpty) {
      final streamUrl = scene.paths.stream ?? '';
      if (streamUrl.isEmpty) return null;
      return StreamChoice(url: streamUrl, mimeType: guessMimeType(streamUrl));
    }

    StreamChoice? best;
    for (final stream in streams) {
      final resolvedUrl = resolveGraphqlMediaUrl(
        rawUrl: stream['url'] as String?,
        graphqlEndpoint: graphqlEndpoint,
      );
      if (resolvedUrl.isEmpty) continue;

      final mime = (stream['mime_type'] as String?)?.trim();
      final label = (stream['label'] as String?)?.trim();
      final guessed = guessMimeType(resolvedUrl, label: label);
      final choice = StreamChoice(
        url: resolvedUrl,
        mimeType: (mime == null || mime.isEmpty) ? guessed : mime,
        label: label,
      );

      if (best == null || choice.score > best.score) {
        best = choice;
      }
    }

    return best;
  }

  String guessMimeType(String url, {String? label}) {
    final uri = Uri.tryParse(url);
    final path = (uri?.path ?? url).toLowerCase();
    final lowerLabel = (label ?? '').toLowerCase();

    if (path.endsWith('.m3u8') || lowerLabel.contains('hls')) {
      return 'application/vnd.apple.mpegurl';
    }
    if (path.endsWith('.mpd') || lowerLabel.contains('dash')) {
      return 'application/dash+xml';
    }
    if (path.endsWith('.mp4') || lowerLabel.contains('mp4')) {
      return 'video/mp4';
    }
    if (path.endsWith('.webm') || lowerLabel.contains('webm')) {
      return 'video/webm';
    }
    return 'unknown';
  }

  Future<String?> probeMimeTypeFromHeaders(
    String url,
    Map<String, String> headers,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);

    try {
      Future<String?> requestAndExtract(
        String method, {
        bool withRange = false,
      }) async {
        final req = await client
            .openUrl(method, uri)
            .timeout(const Duration(seconds: 3));
        headers.forEach(req.headers.set);
        if (withRange) req.headers.set('Range', 'bytes=0-0');

        final res = await req.close().timeout(const Duration(seconds: 3));
        await res.drain<void>();

        final contentType = res.headers.value(HttpHeaders.contentTypeHeader);
        if (contentType == null || contentType.trim().isEmpty) return null;
        return contentType.split(';').first.trim().toLowerCase();
      }

      final fromHead = await requestAndExtract('HEAD');
      if (fromHead != null && fromHead.isNotEmpty) return fromHead;

      final fromGet = await requestAndExtract('GET', withRange: true);
      if (fromGet != null && fromGet.isNotEmpty) return fromGet;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
