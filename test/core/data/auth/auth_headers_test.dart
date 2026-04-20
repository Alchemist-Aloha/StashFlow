import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/auth/auth_headers.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';

void main() {
  group('getAuthHeaders', () {
    const String testApiKey = 'test-api-key';

    test('always includes ApiKey header if apiKey is present', () {
      final authState = AuthState.initial().copyWith(mode: AuthMode.apiKey);
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      expect(headers['ApiKey'], testApiKey);
    });

    test('includes Bearer token in Authorization header when mode is bearer', () {
      final authState = AuthState.initial().copyWith(mode: AuthMode.bearer);
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      expect(headers['ApiKey'], testApiKey);
      expect(headers['Authorization'], 'Bearer $testApiKey');
    });

    test('includes Basic auth in Authorization header when mode is basic', () {
      final authState = AuthState.initial().copyWith(
        mode: AuthMode.basic,
        username: 'user',
        password: 'pass',
      );
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      final expectedBase64 = base64Encode(utf8.encode('user:pass'));
      expect(headers['ApiKey'], testApiKey);
      expect(headers['Authorization'], 'Basic $expectedBase64');
    });

    test('includes both ApiKey and Authorization headers (additive)', () {
      final authState = AuthState.initial().copyWith(mode: AuthMode.bearer);
      final headers = getAuthHeaders(authState: authState, apiKey: testApiKey);
      
      expect(headers.containsKey('ApiKey'), true);
      expect(headers.containsKey('Authorization'), true);
    });
  });
}
