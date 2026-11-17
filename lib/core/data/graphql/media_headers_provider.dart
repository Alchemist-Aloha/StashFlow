import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_headers.dart';
import '../auth/auth_provider.dart';
import '../graphql/graphql_client.dart';
import 'url_resolver.dart';

final mediaHeadersProvider = Provider<Map<String, String>>((ref) {
  final authState = ref.watch(authProvider);
  final apiKey = ref.watch(serverApiKeyProvider);
  return getAuthHeaders(authState: authState, apiKey: apiKey);
});

final mediaPlaybackHeadersProvider = Provider<Map<String, String>>((ref) {
  final authState = ref.watch(authProvider);
  final apiKey = ref.watch(serverApiKeyProvider);
  return getAuthHeaders(authState: authState, apiKey: apiKey);
});

/// Rewrites media URLs for web players, which cannot send custom auth headers.
/// Native platforms receive the URL unchanged.
final webMediaUrlProvider = Provider<String Function(String url)>((ref) {
  if (!kIsWeb) return (url) => url;
  final authState = ref.watch(authProvider);
  final apiKey = ref.watch(serverApiKeyProvider);
  return (url) => applyWebMediaAuthFallback(
    url: url,
    authMode: authState.mode,
    apiKey: apiKey,
    username: authState.username,
    password: authState.password,
  );
});
