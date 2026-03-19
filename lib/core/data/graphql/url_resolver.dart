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
