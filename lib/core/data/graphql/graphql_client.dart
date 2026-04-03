import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// StateProvider for the internal Stash server API Key value.
final serverApiKeyInternalProvider = StateProvider<String>((ref) => '');

/// Provider for the Stash server API Key.
@riverpod
String serverApiKey(Ref ref) {
  ref.watch(sharedPreferencesTriggerProvider);
  return ref.watch(serverApiKeyInternalProvider);
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

  final HttpLink httpLink = HttpLink(url, defaultHeaders: {'ApiKey': apiKey});

  // Use an in-memory cache during widget tests to avoid requiring Hive
  // initialization (which `initHiveForFlutter()` normally performs in
  // `main()`). Tests run with the `FLUTTER_TEST` environment flag.
  const bool isTestMode = bool.fromEnvironment(
    'FLUTTER_TEST',
    defaultValue: false,
  );

  return GraphQLClient(
    link: httpLink,
    cache: isTestMode ? GraphQLCache() : GraphQLCache(store: HiveStore()),
  );
}
