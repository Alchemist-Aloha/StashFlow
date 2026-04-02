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

  final origin = Uri(
    scheme: graphqlEndpoint.scheme,
    host: graphqlEndpoint.host,
    port: graphqlEndpoint.hasPort ? graphqlEndpoint.port : null,
  );

  if (value.startsWith('/')) {
    return origin.resolveUri(Uri.parse(value)).toString();
  }

  return origin.resolve(value).toString();
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
