import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';

/// Resolves whether a scene preview URL points at existing media.
typedef PreviewAvailabilityCheck = Future<bool> Function(String previewUrl);

final previewAvailabilityCheckProvider = Provider<PreviewAvailabilityCheck>((
  ref,
) {
  final service = PreviewAvailabilityService();

  return (rawPreviewUrl) {
    final endpoint = Uri.tryParse(ref.read(serverUrlProvider));
    var url = endpoint == null
        ? rawPreviewUrl
        : resolveGraphqlMediaUrl(
            rawUrl: rawPreviewUrl,
            graphqlEndpoint: endpoint,
          );
    var headers = ref.read(mediaPlaybackHeadersProvider);

    if (kIsWeb) {
      final authState = ref.read(authProvider);
      url = applyWebMediaAuthFallback(
        url: url,
        authMode: authState.mode,
        apiKey: ref.read(serverApiKeyProvider),
        username: authState.username,
        password: authState.password,
        graphqlEndpoint: endpoint,
      );
      headers = const {};
    }

    return service.isAvailable(url, headers: headers);
  };
});

/// Lightweight media probe for scene previews.
///
/// Stash hands out a preview path even when the file was never generated, so a
/// ranged GET cancelled after the response headers is the cheapest way to tell
/// a real preview from a dead URL before the player tries to open it.
class PreviewAvailabilityService {
  PreviewAvailabilityService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<bool> isAvailable(String url, {Map<String, String>? headers}) async {
    final client = _client ?? http.Client();
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return true;

      final request = http.Request('GET', uri)
        ..headers.addAll(headers ?? const {})
        ..headers['Range'] = 'bytes=0-0';
      final response = await client.send(request);
      // The status is all we need; drop the body without downloading it.
      await response.stream.listen(null).cancel();

      // Only a definitive "gone" response hides the preview. Any other status
      // keeps it available so auth or method quirks never remove a valid entry.
      return response.statusCode != 404 && response.statusCode != 410;
    } catch (_) {
      // A failed probe must not hide a preview that might still play.
      return true;
    } finally {
      if (_client == null) client.close();
    }
  }
}
