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

/// Appends Basic Auth credentials to the given [url] if provided.
String appendBasicAuth(String url, String username, String password) {
  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  if (username.isEmpty && password.isEmpty) return url;

  return uri.replace(
    userInfo: '${Uri.encodeFull(username)}:${Uri.encodeFull(password)}',
  ).toString();
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
/// 2) If Basic auth is used, inject credentials into the URL (UserInfo).
///    This is necessary for standard <video> tags on Web which don't support custom headers.
String applyWebMediaAuthFallback({
  required String url,
  required AuthMode authMode,
  required String apiKey,
  String? username,
  String? password,
  Uri? graphqlEndpoint,
}) {
  final trimmedUrl = url.trim();
  if (trimmedUrl.isEmpty) return trimmedUrl;

  // Priority: If we have an API key, it's our best fallback for the URL itself.
  final trimmedApiKey = apiKey.trim();
  if (trimmedApiKey.isNotEmpty) {
    return appendApiKey(trimmedUrl, trimmedApiKey);
  }

  if (authMode == AuthMode.basic && username != null && password != null) {
    return appendBasicAuth(trimmedUrl, username, password);
  }

  return trimmedUrl;
}
