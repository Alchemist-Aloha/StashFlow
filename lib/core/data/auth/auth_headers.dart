import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'auth_mode.dart';
import 'auth_provider.dart';

Map<String, String> getAuthHeaders({
  required AuthState authState,
  required String apiKey,
}) {
  final headers = <String, String>{};

  // Priority order: Cookie > Bearer > Basic > ApiKey
  
  // 1. Cookie (for password mode)
  if (authState.mode == AuthMode.password && authState.cookieHeader.isNotEmpty) {
    // Browsers treat Cookie as a forbidden request header. For web we rely
    // on credentials-enabled requests instead of manually setting Cookie.
    if (!kIsWeb) {
      headers['Cookie'] = authState.cookieHeader;
    }
  } 
  // 2. Bearer Header
  else if (authState.mode == AuthMode.bearer && apiKey.isNotEmpty) {
    headers['Authorization'] = 'Bearer $apiKey';
  } 
  // 3. Basic Header
  else if (authState.mode == AuthMode.basic) {
    final user = authState.username.trim();
    final pass = authState.password;
    if (user.isNotEmpty || pass.isNotEmpty) {
      final bytes = utf8.encode('$user:$pass');
      final base64 = base64Encode(bytes);
      headers['Authorization'] = 'Basic $base64';
    }
  } 
  // 4. Stash Header (ApiKey) - lowest priority fallback
  else if (apiKey.isNotEmpty) {
    headers['ApiKey'] = apiKey;
  }

  return headers;
}
