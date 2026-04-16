import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stash_app_flutter/core/data/auth/auth_service.dart';

void main() {
  group('AuthService', () {
    late HttpServer server;
    late Directory tempDir;
    late AuthService service;
    late Uri graphqlEndpoint;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      tempDir = await Directory.systemTemp.createTemp('stashflow-auth-test-');

      final cookieJar = CookieJar();

      final dio = Dio()
        ..interceptors.add(CookieManager(cookieJar))
        ..options.validateStatus = (status) =>
            status != null && status >= 200 && status < 500;

      service = AuthService(dio: dio, cookieJar: cookieJar);
      graphqlEndpoint = Uri.parse(
        'http://${server.address.host}:${server.port}/graphql',
      );
    });

    tearDown(() async {
      await server.close(force: true);
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'login posts form data to /login and persists session cookie',
      () async {
        server.listen((HttpRequest request) async {
          if (request.method == 'POST' && request.uri.path == '/login') {
            final body = await utf8.decoder.bind(request).join();
            final fields = Uri.splitQueryString(body);

            if (fields['username'] == 'alice' &&
                fields['password'] == 'secret') {
              request.response.headers.add(
                HttpHeaders.setCookieHeader,
                'session=abc123; Path=/; HttpOnly',
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

        final ok = await service.login(
          graphqlEndpoint: graphqlEndpoint,
          username: 'alice',
          password: 'secret',
        );

        expect(ok, isTrue);

        final cookieHeader = await service.cookieHeaderFor(
          requestUri: graphqlEndpoint,
        );
        expect(cookieHeader, contains('session=abc123'));
      },
    );

    test('logout calls /logout and clears persisted cookies', () async {
      server.listen((HttpRequest request) async {
        if (request.method == 'POST' && request.uri.path == '/login') {
          request.response.headers.add(
            HttpHeaders.setCookieHeader,
            'session=to-clear; Path=/; HttpOnly',
          );
          request.response.statusCode = HttpStatus.ok;
          await request.response.close();
          return;
        }

        if (request.method == 'GET' && request.uri.path == '/logout') {
          request.response.statusCode = HttpStatus.ok;
          await request.response.close();
          return;
        }

        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      });

      await service.login(
        graphqlEndpoint: graphqlEndpoint,
        username: 'alice',
        password: 'secret',
      );
      expect(
        await service.cookieHeaderFor(requestUri: graphqlEndpoint),
        contains('session=to-clear'),
      );

      await service.logout(graphqlEndpoint: graphqlEndpoint);

      expect(
        await service.cookieHeaderFor(requestUri: graphqlEndpoint),
        isEmpty,
      );
    });
  });
}
