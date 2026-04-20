import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_headers.dart';
import '../auth/auth_mode.dart';
import '../auth/auth_provider.dart';
import '../graphql/graphql_client.dart';

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
