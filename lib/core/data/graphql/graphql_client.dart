import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../auth/auth_headers.dart';
import '../auth/auth_mode.dart';
import '../auth/auth_provider.dart';
import 'http_client_factory.dart';
import '../preferences/shared_preferences_provider.dart';
import '../preferences/secure_storage_provider.dart';
import '../../../features/setup/domain/models/server_profile.dart';
import '../../../features/setup/presentation/providers/server_profiles_provider.dart';
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
    final profile = ref.watch(activeProfileProvider);
    if (profile != null) {
      return normalizeGraphqlServerUrl(profile.baseUrl);
    }
    
    final prefs = ref.watch(sharedPreferencesProvider);
    final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
    return normalizeGraphqlServerUrl(storedServerUrl);
  }
}

@riverpod
Future<String> profileApiKey(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_api_key') ?? '';
}

@riverpod
class ServerApiKey extends _$ServerApiKey {
  @override
  String build() {
    ref.watch(sharedPreferencesTriggerProvider);
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return '';
    
    return ref.watch(profileApiKeyProvider(profile.id)).value ?? '';
  }
}

final proxyAuthModesEnabledProvider = Provider<bool>((ref) {
  ref.watch(sharedPreferencesTriggerProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('enable_proxy_auth_modes') ?? false;
});

@riverpod
Future<String> profileUsername(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_username') ?? '';
}

@riverpod
Future<String> profilePassword(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_password') ?? '';
}

@riverpod
GraphQLClient profileGraphqlClient(Ref ref, ServerProfile profile) {
  final url = normalizeGraphqlServerUrl(profile.baseUrl);
  if (url.isEmpty) {
    throw Exception('Invalid profile URL');
  }

  final apiKey = ref.watch(profileApiKeyProvider(profile.id)).value ?? '';
  final username = ref.watch(profileUsernameProvider(profile.id)).value ?? '';
  final password = ref.watch(profilePasswordProvider(profile.id)).value ?? '';

  final authState = const AuthState.initial().copyWith(
    mode: profile.authMode,
    username: username,
    password: password,
  );

  final headers = getAuthHeaders(authState: authState, apiKey: apiKey);
  final isPasswordMode = profile.authMode == AuthMode.password;
  final httpClient = createGraphqlHttpClient(withCredentials: isPasswordMode);

  final HttpLink httpLink = HttpLink(
    url,
    defaultHeaders: headers,
    httpClient: httpClient,
  );

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(), // Always use fresh cache for non-active profile checks
  );
}

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
