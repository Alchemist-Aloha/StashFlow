import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../auth/auth_headers.dart';
import '../auth/auth_mode.dart';
import '../auth/auth_provider.dart';
import 'http_client_factory.dart';
import '../preferences/shared_preferences_provider.dart';
import '../../utils/environment.dart' as env;

part 'graphql_client.g.dart';

Uri _withGraphqlPathIfMissing(Uri uri) {
  final path = uri.path.trim();
  if (path.isEmpty || path == '/') {
    return uri.replace(path: '/graphql');
  }
  return uri;
}

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

@riverpod
class SharedPreferencesTrigger extends _$SharedPreferencesTrigger {
  @override
  int build() => 0;
  void trigger() => state++;
}

@riverpod
class ServerUrl extends _$ServerUrl {
  @override
  String build() {
    ref.watch(sharedPreferencesTriggerProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
    return normalizeGraphqlServerUrl(storedServerUrl);
  }
}

@riverpod
class InitialServerApiKey extends _$InitialServerApiKey {
  @override
  String build() => '';
}

@riverpod
class ServerApiKeyInternal extends _$ServerApiKeyInternal {
  @override
  String build() => ref.watch(initialServerApiKeyProvider);
  void update(String value) => state = value;
}

@riverpod
class ServerApiKey extends _$ServerApiKey {
  @override
  String build() {
    ref.watch(sharedPreferencesTriggerProvider);
    return ref.watch(serverApiKeyInternalProvider);
  }
}

final proxyAuthModesEnabledProvider = Provider<bool>((ref) {
  ref.watch(sharedPreferencesTriggerProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('enable_proxy_auth_modes') ?? false;
});

@riverpod
class GraphqlClient extends _$GraphqlClient {
  @override
  GraphQLClient build() {
    final url = ref.watch(serverUrlProvider);
    if (url.isEmpty) {
      if (env.isTestMode) {
        // Return a dummy client for tests if URL is not configured
        return GraphQLClient(
          link: HttpLink('http://localhost'),
          cache: GraphQLCache(),
        );
      }
      throw Exception('Server URL not configured');
    }

    final apiKey = ref.watch(serverApiKeyProvider);
    final authState = ref.watch(authProvider);
    final isPasswordMode = authState.mode == AuthMode.password;

    final headers = getAuthHeaders(authState: authState, apiKey: apiKey);

    final httpClient = createGraphqlHttpClient(withCredentials: isPasswordMode);

    final HttpLink httpLink = HttpLink(
      url,
      defaultHeaders: headers,
      httpClient: httpClient,
    );

    return GraphQLClient(
      link: httpLink,
      cache: env.isTestMode ? GraphQLCache() : GraphQLCache(store: HiveStore()),
    );
  }
}
