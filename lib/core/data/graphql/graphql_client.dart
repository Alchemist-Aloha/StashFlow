import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../preferences/shared_preferences_provider.dart';

part 'graphql_client.g.dart';

Uri _withGraphqlPathIfMissing(Uri uri) {
  final path = uri.path.trim();
  if (path.isEmpty || path == '/') {
    return uri.replace(path: '/graphql');
  }
  return uri;
}

/// Normalizes a user-provided server URL to a valid GraphQL endpoint.
/// 
/// Ensures the URL has a scheme (defaults to https) and includes the `/graphql` path.
String normalizeGraphqlServerUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';

  final direct = Uri.tryParse(trimmed);
  if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
    return _withGraphqlPathIfMissing(direct).toString();
  }

  final withHttps = Uri.tryParse('https://$trimmed');
  if (withHttps != null && withHttps.host.isNotEmpty) {
    return _withGraphqlPathIfMissing(withHttps).toString();
  }

  return '';
}

/// A trigger to notify listeners when [SharedPreferences] settings are manually updated.
@riverpod
class SharedPreferencesTrigger extends _$SharedPreferencesTrigger {
  @override
  int build() => 0;
  
  /// Increments the revision counter to trigger dependency rebuilds.
  void trigger() => state++;
}

/// Provider for the normalized Stash server URL.
@riverpod
String serverUrl(Ref ref) {
  ref.watch(sharedPreferencesTriggerProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
  return normalizeGraphqlServerUrl(storedServerUrl);
}

/// Provider for the Stash server API Key.
@riverpod
String serverApiKey(Ref ref) {
  ref.watch(sharedPreferencesTriggerProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('server_api_key')?.trim() ?? '';
}

/// A centralized [GraphQLClient] provider for all feature repositories.
/// 
/// This client is automatically re-initialized whenever [serverUrl]
/// or [serverApiKey] changes. It handles the [HttpLink] setup with the 
/// correct `ApiKey` header required by Stash.
@riverpod
GraphQLClient graphqlClient(Ref ref) {
  final url = ref.watch(serverUrlProvider);
  if (url.isEmpty) {
    throw Exception('Server URL not configured');
  }

  final apiKey = ref.watch(serverApiKeyProvider);

  final HttpLink httpLink = HttpLink(
    url,
    defaultHeaders: {'ApiKey': apiKey},
  );

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: HiveStore()),
  );
}
