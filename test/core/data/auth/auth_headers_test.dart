import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/auth/auth_headers.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';

void main() {
  group('getAuthHeaders', () {
    const String testApiKey = 'test-api-key';

    test('prefers Cookie header if in password mode and cookie is present', () {
      final authState = AuthState.initial().copyWith(
        mode: AuthMode.password,
        cookieHeader: 'session=123',
      );
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      expect(headers['Cookie'], 'session=123');
      expect(headers.containsKey('Authorization'), false);
      expect(headers.containsKey('ApiKey'), false);
    });

    test('prefers Bearer token over ApiKey when mode is bearer', () {
      final authState = AuthState.initial().copyWith(mode: AuthMode.bearer);
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      expect(headers['Authorization'], 'Bearer $testApiKey');
      expect(headers.containsKey('ApiKey'), false);
    });

    test('prefers Basic auth over ApiKey when mode is basic', () {
      final authState = AuthState.initial().copyWith(
        mode: AuthMode.basic,
        username: 'user',
        password: 'pass',
      );
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      final expectedBase64 = base64Encode(utf8.encode('user:pass'));
      expect(headers['Authorization'], 'Basic $expectedBase64');
      expect(headers.containsKey('ApiKey'), false);
    });

    test('falls back to ApiKey header if no other mode is active', () {
      final authState = AuthState.initial().copyWith(mode: AuthMode.apiKey);
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      expect(headers['ApiKey'], testApiKey);
      expect(headers.containsKey('Authorization'), false);
    });
  });
}
