import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';
import 'package:stash_app_flutter/core/data/auth/auth_service.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/features/setup/data/graphql/version.graphql.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/domain/models/server_profile.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage([Map<String, String>? seed]) : _values = {...?seed};

  final Map<String, String> _values;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }
}

void main() {
  const profileId = 'test_profile';
  final testProfile = ServerProfile(
    id: profileId,
    name: 'Test Profile',
    baseUrl: 'http://localhost:9999/graphql',
    authMode: AuthMode.password,
  );

  group('AuthProvider', () {
    test('a saved cookie alone cannot restore a password session', () async {
      SharedPreferences.setMockInitialValues({
        'profile_${profileId}_auth_mode': 'password',
      });
      final prefs = await SharedPreferences.getInstance();

      final secureStorage = FakeSecureStorage({
        'profile_${profileId}_username': 'alice',
        'profile_${profileId}_cookie_header': 'session=restored',
      });

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(
            AppSecureStorage(
              secureStorage: secureStorage,
              sharedPreferences: prefs,
            ),
          ),
          activeProfileProvider.overrideWithValue(testProfile),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state.mode, AuthMode.password);
      expect(state.username, 'alice');
      expect(state.password, '');
      expect(state.cookieHeader, '');
      expect(state.loginStatus, AuthLoginStatus.loggedOut);
    });

    test('startup renews an expired session for GraphQL and media', () async {
      SharedPreferences.setMockInitialValues({
        'profile_${profileId}_auth_mode': 'password',
      });
      final prefs = await SharedPreferences.getInstance();

      final secureStorage = FakeSecureStorage({
        'profile_${profileId}_username': 'alice',
        'profile_${profileId}_password': 'secret',
        'profile_${profileId}_cookie_header': 'session=expired',
      });

      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final tempDir = await Directory.systemTemp.createTemp(
        'stashflow-auth-provider-test-',
      );

      server.listen((HttpRequest request) async {
        if (request.method == 'POST' && request.uri.path == '/login') {
          final body = await utf8.decoder.bind(request).join();
          final fields = Uri.splitQueryString(body);
          if (fields['username'] == 'alice' && fields['password'] == 'secret') {
            request.response.headers.add(
              HttpHeaders.setCookieHeader,
              'session=provider-cookie; Path=/; HttpOnly',
            );
            request.response.statusCode = HttpStatus.ok;
          } else {
            request.response.statusCode = HttpStatus.unauthorized;
          }
          await request.response.close();
          return;
        }

        if (request.uri.path == '/graphql' &&
            request.headers.value(HttpHeaders.cookieHeader) ==
                'session=provider-cookie') {
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            '{"data":{"__typename":"Query","version":'
            '{"__typename":"StashVersion","version":"v-test"}}}',
          );
        } else {
          request.response.statusCode = HttpStatus.unauthorized;
        }
        await request.response.close();
      });

      final endpoint = 'http://${server.address.host}:${server.port}/graphql';
      final profileWithDynamicUrl = testProfile.copyWith(baseUrl: endpoint);

      final cookieJar = CookieJar(ignoreExpires: false);
      await cookieJar.saveFromResponse(Uri.parse(endpoint), [
        Cookie('session', 'expired')
          ..path = '/'
          ..expires = DateTime.now().subtract(const Duration(days: 1)),
      ]);
      final dio = Dio()
        ..interceptors.add(CookieManager(cookieJar))
        ..options.validateStatus = (status) =>
            status != null && status >= 200 && status < 500;
      final authService = AuthService(dio: dio, cookieJar: cookieJar);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(
            AppSecureStorage(
              secureStorage: secureStorage,
              sharedPreferences: prefs,
            ),
          ),
          authServiceProvider.overrideWith((ref) async => authService),
          activeProfileProvider.overrideWithValue(profileWithDynamicUrl),
        ],
      );

      addTearDown(() async {
        container.dispose();
        dio.close(force: true);
        await server.close(force: true);
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final loggedIn = Completer<void>();
      container.listen(authProvider, (previous, next) {
        if (next.loginStatus == AuthLoginStatus.loggedIn &&
            !loggedIn.isCompleted) {
          loggedIn.complete();
        }
      });
      await loggedIn.future.timeout(const Duration(seconds: 5));

      final state = container.read(authProvider);
      expect(state.loginStatus, AuthLoginStatus.loggedIn);
      expect(state.cookieHeader, contains('session=provider-cookie'));
      expect(
        container.read(mediaHeadersProvider)['Cookie'],
        state.cookieHeader,
      );
      final result = await container
          .read(graphqlClientProvider)
          .query$GetVersion();
      expect(result.hasException, isFalse);
      expect(result.parsedData?.version.version, 'v-test');
      expect(
        await secureStorage.read(key: 'profile_${profileId}_cookie_header'),
        isNotEmpty,
      );
    });

    test('hydrates basic mode and sets loggedIn status', () async {
      SharedPreferences.setMockInitialValues({
        'profile_${profileId}_auth_mode': 'basic',
      });
      final prefs = await SharedPreferences.getInstance();

      final secureStorage = FakeSecureStorage({
        'profile_${profileId}_username': 'alice',
        'profile_${profileId}_password': 'secret',
      });

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(
            AppSecureStorage(
              secureStorage: secureStorage,
              sharedPreferences: prefs,
            ),
          ),
          activeProfileProvider.overrideWithValue(testProfile),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state.mode, AuthMode.basic);
      expect(state.username, 'alice');
      expect(state.password, 'secret');
      expect(state.loginStatus, AuthLoginStatus.loggedIn);
    });

    test('hydrates bearer mode and sets loggedIn status', () async {
      SharedPreferences.setMockInitialValues({
        'profile_${profileId}_auth_mode': 'bearer',
      });
      final prefs = await SharedPreferences.getInstance();

      final secureStorage = FakeSecureStorage({
        'profile_${profileId}_api_key': 'some-token',
      });

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(
            AppSecureStorage(
              secureStorage: secureStorage,
              sharedPreferences: prefs,
            ),
          ),
          activeProfileProvider.overrideWithValue(testProfile),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state.mode, AuthMode.bearer);
      expect(state.loginStatus, AuthLoginStatus.loggedIn);
    });
  });
}
