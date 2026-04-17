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
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';

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
  group('AuthProvider', () {
    test('hydrates mode and credentials from storage', () async {
      SharedPreferences.setMockInitialValues({
        'server_base_url': 'http://localhost:9999/graphql',
        'auth_mode': 'password',
      });
      final prefs = await SharedPreferences.getInstance();

      final secureStorage = FakeSecureStorage({
        'server_username': 'alice',
        'server_password': 'secret',
        'server_cookie_header': 'session=restored',
      });

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(secureStorage),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state.mode, AuthMode.password);
      expect(state.username, 'alice');
      expect(state.password, 'secret');
      expect(state.cookieHeader, 'session=restored');
      expect(state.loginStatus, AuthLoginStatus.loggedIn);
    });

    test('login stores cookie header and updates status', () async {
      SharedPreferences.setMockInitialValues({
        'server_base_url': 'http://localhost:9999/graphql',
        'auth_mode': 'password',
      });
      final prefs = await SharedPreferences.getInstance();

      final secureStorage = FakeSecureStorage({
        'server_username': 'alice',
        'server_password': 'secret',
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

        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      });

      final endpoint = 'http://${server.address.host}:${server.port}/graphql';
      await prefs.setString('server_base_url', endpoint);

      final cookieJar = CookieJar();
      final dio = Dio()
        ..interceptors.add(CookieManager(cookieJar))
        ..options.validateStatus = (status) =>
            status != null && status >= 200 && status < 500;
      final authService = AuthService(dio: dio, cookieJar: cookieJar);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(secureStorage),
          authServiceProvider.overrideWith((ref) async => authService),
        ],
      );

      addTearDown(() async {
        container.dispose();
        await server.close(force: true);
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      await container.read(authProvider.notifier).setMode(AuthMode.password);
      await container.read(authProvider.notifier).updateUsername('alice');
      await container.read(authProvider.notifier).updatePassword('secret');

      final success = await container.read(authProvider.notifier).login();
      expect(success, isTrue);

      final state = container.read(authProvider);
      expect(state.loginStatus, AuthLoginStatus.loggedIn);
      expect(state.cookieHeader, contains('session=provider-cookie'));
      expect(await secureStorage.read(key: 'server_cookie_header'), isNotEmpty);
    });
  });
}
