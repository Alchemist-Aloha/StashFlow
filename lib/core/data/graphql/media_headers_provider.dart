import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_mode.dart';
import '../auth/auth_provider.dart';
import '../graphql/graphql_client.dart';

final mediaHeadersProvider = Provider<Map<String, String>>((ref) {
  final authState = ref.watch(authProvider);
  final apiKey = ref.watch(serverApiKeyProvider);
  final headers = <String, String>{};

  if (authState.mode == AuthMode.password) {
    // Browsers treat Cookie as a forbidden request header. For web we rely
    // on credentials-enabled requests instead of manually setting Cookie.
    if (!kIsWeb && authState.cookieHeader.isNotEmpty) {
      headers['Cookie'] = authState.cookieHeader;
    }
  } else if (authState.mode == AuthMode.basic) {
    final user = authState.username.trim();
    final pass = authState.password;
    if (user.isNotEmpty || pass.isNotEmpty) {
      final bytes = utf8.encode('$user:$pass');
      final base64 = base64Encode(bytes);
      headers['Authorization'] = 'Basic $base64';
    }
  } else if (authState.mode == AuthMode.bearer) {
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
  } else if (apiKey.isNotEmpty) {
    headers['ApiKey'] = apiKey;
  }

  return headers;
});

final mediaPlaybackHeadersProvider = Provider<Map<String, String>>((ref) {
  final authState = ref.watch(authProvider);
  final apiKey = ref.watch(serverApiKeyProvider);
  final headers = <String, String>{};

  if (authState.mode == AuthMode.password) {
    // Browsers treat Cookie as a forbidden request header. For web we rely
    // on credentials-enabled requests instead of manually setting Cookie.
    if (!kIsWeb && authState.cookieHeader.isNotEmpty) {
      headers['Cookie'] = authState.cookieHeader;
    }
  } else if (authState.mode == AuthMode.basic) {
    final user = authState.username.trim();
    final pass = authState.password;
    if (user.isNotEmpty || pass.isNotEmpty) {
      final bytes = utf8.encode('$user:$pass');
      final base64 = base64Encode(bytes);
      headers['Authorization'] = 'Basic $base64';
    }
  } else if (authState.mode == AuthMode.bearer) {
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
  } else if (apiKey.isNotEmpty) {
    headers['ApiKey'] = apiKey;
  }

  return headers;
});
