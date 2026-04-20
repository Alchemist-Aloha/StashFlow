import '../auth/auth_mode.dart';

String resolveGraphqlMediaUrl({
  required String? rawUrl,
  required Uri graphqlEndpoint,
}) {
  final value = rawUrl?.trim() ?? '';
  if (value.isEmpty) return '';

  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
    return parsed.toString();
  }

  if (value.startsWith('//')) {
    return '${graphqlEndpoint.scheme}:$value';
  }

  final base = Uri(
    scheme: graphqlEndpoint.scheme,
    userInfo: graphqlEndpoint.userInfo,
    host: graphqlEndpoint.host,
    port: graphqlEndpoint.hasPort ? graphqlEndpoint.port : null,
  );

  final resolved = base.resolve(value);

  if (graphqlEndpoint.queryParameters.isNotEmpty) {
    final mergedParams = Map<String, dynamic>.from(
      graphqlEndpoint.queryParameters,
    )..addAll(resolved.queryParameters);
    return resolved.replace(queryParameters: mergedParams).toString();
  }

  return resolved.toString();
}

/// Appends an API key to the given [url] as a query parameter.
///
/// This is used to allow external system components (like the Android notification shade)
/// to access media assets that normally require authentication.
String appendApiKey(String url, String apiKey) {
  final trimmedApiKey = apiKey.trim();
  if (trimmedApiKey.isEmpty) return url;

  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  // Stash uses 'apikey' as the query parameter for authentication.
  final newParams = Map<String, dynamic>.from(uri.queryParameters);
  newParams['apikey'] = trimmedApiKey;

  return uri.replace(queryParameters: newParams).toString();
}

/// Applies a web-specific media auth fallback when custom headers are unavailable.
///
/// Priority:
/// 1) If an API key exists, append it as `apikey` query param.
/// 2) Password and Basic auth rely on browser session/headers or apikey fallback.
///    Username and password are NO LONGER injected into the URL for security.
String applyWebMediaAuthFallback({
  required String url,
  required AuthMode authMode,
  required String apiKey,
  @Deprecated('Username should not be inserted into URL') String? username,
  @Deprecated('Password should not be inserted into URL') String? password,
  Uri? graphqlEndpoint,
}) {
  final trimmedUrl = url.trim();
  if (trimmedUrl.isEmpty) return trimmedUrl;

  // Keep password mode relying on browser cookie sessions.
  if (authMode == AuthMode.password) return trimmedUrl;

  final trimmedApiKey = apiKey.trim();
  if (trimmedApiKey.isNotEmpty) {
    return appendApiKey(trimmedUrl, trimmedApiKey);
  }

  return trimmedUrl;
}
