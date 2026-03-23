import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';

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
    final client = ref.read(graphqlClientProvider);
    final mediaHeaders = ref.read(mediaHeadersProvider);
    final queryStopwatch = Stopwatch()..start();
    
    // Fetch available stream endpoints for the scene
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

    // Fallback to scene direct path if no API streams exist
    if (streams.isEmpty) {
      final streamUrl = scene.paths.stream ?? '';
      if (streamUrl.isEmpty) return null;
      return StreamChoice(url: streamUrl, mimeType: guessMimeType(streamUrl));
    }

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

    // Prioritize candidates by compatibility score
    candidates.sort((a, b) => b.score.compareTo(a.score));

    StreamChoice? best;
    var probeCount = 0;
    const maxProbes = 2; // Limit network probing to avoid excessive startup delay
    
    for (final choice in candidates) {
      final shouldProbe =
          probeCount < maxProbes && _shouldProbeByHeaders(choice);
      if (!shouldProbe) {
        best = choice;
        break;
      }

      probeCount++;
      // Probe headers to check for actual MIME type (detect HTML wrapper pages)
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

  /// Determines if a stream choice needs an HTTP probe to confirm its content type.
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

  /// Guesses the MIME type from a URL string if not provided by the API.
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

  /// Probes a URL using an HTTP HEAD/GET request to determine the actual 
  /// MIME type from the 'Content-Type' header.
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
