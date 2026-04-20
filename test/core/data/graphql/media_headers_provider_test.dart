import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';

class MockAuthProvider extends AuthProvider {
  MockAuthProvider(this._state);
  final AuthState _state;

  @override
  AuthState build() => _state;
}

void main() {
  group('mediaHeadersProvider', () {
    test('injects Basic Authorization header when mode is basic', () {
      final container = ProviderContainer(
        overrides: [
          serverApiKeyProvider.overrideWithValue(''),
          authProvider.overrideWith(() => MockAuthProvider(AuthState.initial().copyWith(
            mode: AuthMode.basic,
            username: 'alice',
            password: 'secret',
          ))),
        ],
      );
      addTearDown(container.dispose);

      final headers = container.read(mediaHeadersProvider);
      
      final expectedBase64 = base64Encode(utf8.encode('alice:secret'));
      expect(headers['Authorization'], 'Basic $expectedBase64');
    });

    test('injects Bearer Authorization header when mode is bearer', () {
      final container = ProviderContainer(
        overrides: [
          serverApiKeyProvider.overrideWithValue('some-token'),
          authProvider.overrideWith(() => MockAuthProvider(AuthState.initial().copyWith(
            mode: AuthMode.bearer,
          ))),
        ],
      );
      addTearDown(container.dispose);

      final headers = container.read(mediaHeadersProvider);
      
      expect(headers['Authorization'], 'Bearer some-token');
    });

    test('injects both ApiKey and Bearer when both are available', () {
      final container = ProviderContainer(
        overrides: [
          serverApiKeyProvider.overrideWithValue('some-token'),
          authProvider.overrideWith(() => MockAuthProvider(AuthState.initial().copyWith(
            mode: AuthMode.bearer,
          ))),
        ],
      );
      addTearDown(container.dispose);

      final headers = container.read(mediaHeadersProvider);
      
      expect(headers['ApiKey'], 'some-token');
      expect(headers['Authorization'], 'Bearer some-token');
    });

    test('injects both ApiKey and Basic when both are available', () {
      final container = ProviderContainer(
        overrides: [
          serverApiKeyProvider.overrideWithValue('some-token'),
          authProvider.overrideWith(() => MockAuthProvider(AuthState.initial().copyWith(
            mode: AuthMode.basic,
            username: 'alice',
            password: 'secret',
          ))),
        ],
      );
      addTearDown(container.dispose);

      final headers = container.read(mediaHeadersProvider);
      
      final expectedBase64 = base64Encode(utf8.encode('alice:secret'));
      expect(headers['ApiKey'], 'some-token');
      expect(headers['Authorization'], 'Basic $expectedBase64');
    });
  });

  group('mediaPlaybackHeadersProvider', () {
    test('injects Basic Authorization header when mode is basic', () {
      final container = ProviderContainer(
        overrides: [
          serverApiKeyProvider.overrideWithValue(''),
          authProvider.overrideWith(() => MockAuthProvider(AuthState.initial().copyWith(
            mode: AuthMode.basic,
            username: 'alice',
            password: 'secret',
          ))),
        ],
      );
      addTearDown(container.dispose);

      final headers = container.read(mediaPlaybackHeadersProvider);
      
      final expectedBase64 = base64Encode(utf8.encode('alice:secret'));
      expect(headers['Authorization'], 'Basic $expectedBase64');
    });

    test('injects Bearer Authorization header when mode is bearer', () {
      final container = ProviderContainer(
        overrides: [
          serverApiKeyProvider.overrideWithValue('some-token'),
          authProvider.overrideWith(() => MockAuthProvider(AuthState.initial().copyWith(
            mode: AuthMode.bearer,
          ))),
        ],
      );
      addTearDown(container.dispose);

      final headers = container.read(mediaPlaybackHeadersProvider);
      
      expect(headers['Authorization'], 'Bearer some-token');
    });
  });
}
