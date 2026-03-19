import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/utils/app_log_store.dart';
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
    final queryStopwatch = Stopwatch()..start();
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
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    queryStopwatch.stop();
    final exceptionSummary = _summarizeException(result.exception);

    AppLogStore.instance.add(
      'resolver query scene=${scene.id} elapsed=${queryStopwatch.elapsedMilliseconds}ms hasException=${result.hasException}${exceptionSummary == null || exceptionSummary.isEmpty ? '' : ' error=$exceptionSummary'}',
      source: 'stream_resolver',
    );

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

    if (result.hasException && streams.isEmpty) return null;
    if (result.hasException && streams.isNotEmpty) {
      AppLogStore.instance.add(
        'resolver query scene=${scene.id} continuing with ${streams.length} streams despite exception',
        source: 'stream_resolver',
      );
    }

    final graphqlEndpoint = client.link is HttpLink
        ? (client.link as HttpLink).uri
        : Uri.parse(scene.paths.stream ?? 'https://localhost/graphql');

    if (streams.isEmpty) {
      final streamUrl = scene.paths.stream ?? '';
      if (streamUrl.isEmpty) return null;
      return StreamChoice(url: streamUrl, mimeType: guessMimeType(streamUrl));
    }

    final mediaHeaders = ref.read(mediaHeadersProvider);
    final candidates = <StreamChoice>[];
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

      candidates.add(choice);
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.score.compareTo(a.score));

    StreamChoice? best;
    var probeCount = 0;
    const maxProbes = 2;
    for (final choice in candidates) {
      final shouldProbe =
          probeCount < maxProbes && _shouldProbeByHeaders(choice);
      if (!shouldProbe) {
        best = choice;
        break;
      }

      probeCount++;
      final probedMime = await probeMimeTypeFromHeaders(
        choice.url,
        mediaHeaders,
      );
      if (probedMime == null || probedMime.isEmpty) {
        best = choice;
        break;
      }

      if (_isLikelyHtmlContentType(probedMime)) {
        AppLogStore.instance.add(
          'skip html stream candidate scene=${scene.id} mime=$probedMime label=${choice.label ?? '-'} url=${_shortUrl(choice.url)}',
          source: 'stream_resolver',
        );
        continue;
      }

      best = StreamChoice(
        url: choice.url,
        mimeType: probedMime,
        label: choice.label,
      );
      break;
    }

    best ??= candidates.first;

    AppLogStore.instance.add(
      'selected stream scene=${scene.id} candidates=${candidates.length} mime=${best.mimeType} label=${best.label ?? '-'} url=${_shortUrl(best.url)}',
      source: 'stream_resolver',
    );

    return best;
  }

  bool _shouldProbeByHeaders(StreamChoice choice) {
    final lowerMime = choice.mimeType.toLowerCase();
    final lowerLabel = (choice.label ?? '').toLowerCase();
    final path = (Uri.tryParse(choice.url)?.path ?? choice.url).toLowerCase();

    if (lowerMime.contains('mpegurl') || lowerMime.contains('dash')) {
      return false;
    }

    final hasKnownExtension =
        path.endsWith('.mp4') ||
        path.endsWith('.webm') ||
        path.endsWith('.mkv');
    final looksLikeStreamRoute =
        path.contains('/stream') || path.contains('/scene/');

    // Probe when URL shape might return an HTML wrapper despite direct-media labels.
    return (lowerMime.contains('mp4') || lowerLabel.contains('direct')) &&
        (!hasKnownExtension || looksLikeStreamRoute);
  }

  bool _isLikelyHtmlContentType(String mimeType) {
    final lower = mimeType.toLowerCase();
    return lower.contains('text/html') ||
        lower.contains('application/xhtml+xml');
  }

  String _shortUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return '${uri.scheme}://${uri.host}${uri.path}';
  }

  String? _summarizeException(OperationException? exception) {
    if (exception == null) return null;

    final parts = <String>[];
    parts.addAll(exception.graphqlErrors.map((e) => e.message.trim()));
    final linkException = exception.linkException;
    if (linkException != null) {
      parts.add(linkException.runtimeType.toString());
    }

    final joined = parts.where((e) => e.isNotEmpty).join(' | ');
    if (joined.isEmpty) return null;

    final redacted = joined.replaceAll(
      RegExp(r'apikey=[^&\s\},]+', caseSensitive: false),
      'apikey=<redacted>',
    );
    return redacted.length > 260
        ? '${redacted.substring(0, 260)}...'
        : redacted;
  }

  String guessMimeType(String url, {String? label}) {
    final uri = Uri.tryParse(url);
    final path = (uri?.path ?? url).toLowerCase();
    final wholeUrl = url.toLowerCase();
    final lowerLabel = (label ?? '').toLowerCase();
    final queryParams =
        uri?.queryParametersAll ?? const <String, List<String>>{};

    String? fromToken(String token) {
      final lower = token.toLowerCase();
      if (lower.contains('m3u8') ||
          lower.contains('mpegurl') ||
          lower == 'hls') {
        return 'application/vnd.apple.mpegurl';
      }
      if (lower.contains('mpd') || lower.contains('dash')) {
        return 'application/dash+xml';
      }
      if (lower.contains('webm')) return 'video/webm';
      if (lower.contains('mp4')) return 'video/mp4';
      return null;
    }

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

    // Extension-less stream endpoints often encode format in query parameters.
    for (final entry in queryParams.entries) {
      final keyGuess = fromToken(entry.key);
      if (keyGuess != null) return keyGuess;
      for (final value in entry.value) {
        final valueGuess = fromToken(value);
        if (valueGuess != null) return valueGuess;
      }
    }

    final inlineGuess = fromToken(wholeUrl);
    if (inlineGuess != null) return inlineGuess;

    // Stash-style scene stream endpoints default to direct MP4 when no manifest hint exists.
    if (path.contains('/scene/') && path.endsWith('/stream')) {
      return 'video/mp4';
    }

    if (lowerLabel.contains('direct') || lowerLabel.contains('source')) {
      return 'video/mp4';
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
        final requestStopwatch = Stopwatch()..start();
        final req = await client
            .openUrl(method, uri)
            .timeout(const Duration(seconds: 3));
        headers.forEach(req.headers.set);
        if (withRange) req.headers.set('Range', 'bytes=0-0');

        final res = await req.close().timeout(const Duration(seconds: 3));
        await res.drain<void>();
        requestStopwatch.stop();

        final contentType = res.headers.value(HttpHeaders.contentTypeHeader);
        AppLogStore.instance.add(
          'resolver probe method=$method range=$withRange status=${res.statusCode} elapsed=${requestStopwatch.elapsedMilliseconds}ms type=${contentType ?? '-'} url=${_shortUrl(url)}',
          source: 'stream_resolver',
        );
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
