import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../preferences/shared_preferences_provider.dart';

part 'graphql_client.g.dart';

@riverpod
GraphQLClient graphqlClient(Ref ref) {
  // Default settings for development/testing. Remove or override in production.
  const defaultServerUrl = 'https://stash.cai.co.im/graphql';
  const defaultApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJxbWtreGNsayIsInN1YiI6IkFQSUtleSIsImlhdCI6MTc3Mzc5MjkyNX0.611H2b2FvizfvU7ooAPW7H6b-u7SU0lI2hvZ34u78t0';

  final prefs = ref.watch(sharedPreferencesProvider);
  final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
  final storedApiKey = prefs.getString('server_api_key')?.trim() ?? '';

  final serverUrl = storedServerUrl.isEmpty
      ? defaultServerUrl
      : storedServerUrl;
  final apiKey = storedApiKey.isEmpty ? defaultApiKey : storedApiKey;

  final HttpLink httpLink = HttpLink(
    serverUrl,
    defaultHeaders: {'ApiKey': apiKey},
  );

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  );
}
