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
/// 2) For Basic auth without API key, inject userinfo (`user:pass@`) only for
///    same-origin media URLs to avoid leaking credentials cross-origin.
String applyWebMediaAuthFallback({
  required String url,
  required AuthMode authMode,
  required String apiKey,
  required String username,
  required String password,
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

  if (authMode != AuthMode.basic) {
    return trimmedUrl;
  }

  final trimmedUser = username.trim();
  if ((trimmedUser.isEmpty && password.isEmpty) || graphqlEndpoint == null) {
    return trimmedUrl;
  }

  final mediaUri = Uri.tryParse(trimmedUrl);
  if (mediaUri == null || !mediaUri.hasScheme || mediaUri.host.isEmpty) {
    return trimmedUrl;
  }

  final sameOrigin = mediaUri.scheme == graphqlEndpoint.scheme &&
      mediaUri.host == graphqlEndpoint.host &&
      ((mediaUri.hasPort ? mediaUri.port : null) ==
          (graphqlEndpoint.hasPort ? graphqlEndpoint.port : null));
  if (!sameOrigin) {
    return trimmedUrl;
  }

  return mediaUri
      .replace(userInfo: '$trimmedUser:$password')
      .toString();
}
