import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_mode.dart';
import '../auth/auth_provider.dart';
import '../graphql/graphql_client.dart';

final mediaHeadersProvider = Provider<Map<String, String>>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.mode == AuthMode.password) {
    if (authState.cookieHeader.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Cookie': authState.cookieHeader};
  }

  final apiKey = ref.watch(serverApiKeyProvider);

  if (authState.mode == AuthMode.basic) {
    final user = authState.username.trim();
    final pass = authState.password;
    if (user.isNotEmpty || pass.isNotEmpty) {
      final bytes = utf8.encode('$user:$pass');
      final base64 = base64Encode(bytes);
      return <String, String>{'Authorization': 'Basic $base64'};
    }
  }

  if (authState.mode == AuthMode.bearer) {
    if (apiKey.isNotEmpty) {
      return <String, String>{'Authorization': 'Bearer $apiKey'};
    }
  }

  if (apiKey.isEmpty) {
    return const <String, String>{};
  }

  return <String, String>{'ApiKey': apiKey};
});

final mediaPlaybackHeadersProvider = Provider<Map<String, String>>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.mode == AuthMode.password) {
    if (authState.cookieHeader.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Cookie': authState.cookieHeader};
  }

  final apiKey = ref.watch(serverApiKeyProvider);

  if (authState.mode == AuthMode.basic) {
    final user = authState.username.trim();
    final pass = authState.password;
    if (user.isNotEmpty || pass.isNotEmpty) {
      final bytes = utf8.encode('$user:$pass');
      final base64 = base64Encode(bytes);
      return <String, String>{'Authorization': 'Basic $base64'};
    }
  }

  if (authState.mode == AuthMode.bearer) {
    if (apiKey.isNotEmpty) {
      return <String, String>{'Authorization': 'Bearer $apiKey'};
    }
  }

  if (apiKey.isEmpty) {
    return const <String, String>{};
  }

  return <String, String>{'ApiKey': apiKey};
});
