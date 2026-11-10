import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stash_app_flutter/core/data/auth/auth_service.dart';
import 'package:stash_app_flutter/core/data/auth/dio_image_client.dart';
import 'package:stash_app_flutter/core/data/cache/app_cache_service.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory root;
  late HttpServer server;
  late StreamSubscription<HttpRequest> subscription;
  late Uri base;
  final receivedHeaders = <HttpHeaders>[];
  final waiting = Completer<void>();

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('stashflow-image-client-');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => root.path,
    );
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = Uri.parse('http://127.0.0.1:${server.port}');
    subscription = server.listen((request) async {
      receivedHeaders.add(request.headers);
      if (request.uri.path == '/wait') {
        waiting.complete();
        // Leave the request open until the test aborts it.
        return;
      }
      if (request.uri.path == '/stream') {
        request.response
          ..bufferOutput = false
          ..contentLength = 4;
        request.response.add([1, 2]);
        await request.response.flush();
        return;
      }
      if (request.uri.path == '/redirect') {
        await request.response.redirect(base.resolve('/image.png'));
        return;
      }
      request.response.headers
        ..contentType = ContentType('image', 'png')
        ..set(HttpHeaders.cacheControlHeader, 'max-age=604800')
        ..set(HttpHeaders.etagHeader, 'image-v1');
      if (request.uri.path == '/missing') {
        request.response.statusCode = HttpStatus.notFound;
      }
      request.response.add([1, 2, 3, 4]);
      await request.response.close();
    });
  });

  tearDownAll(() async {
    await StashImage.cacheManager.dispose();
    await subscription.cancel();
    await server.close(force: true);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, null);
    await root.delete(recursive: true);
  });

  test(
    'preserves headers, session cookies, redirects, and streamed bytes',
    () async {
      final jar = await AuthService.createPersistCookieJar();
      await jar.saveFromResponse(base, [Cookie('session', 'image-session')]);
      final client = DioImageClient();
      addTearDown(client.close);
      final request = http.Request('GET', base.resolve('/redirect'))
        ..headers['ApiKey'] = 'image-api-key';
      final response = await client.send(request);

      expect(response.statusCode, HttpStatus.ok);
      expect(await response.stream.toBytes(), [1, 2, 3, 4]);
      expect(response.headers[HttpHeaders.etagHeader], 'image-v1');
      expect(receivedHeaders.last.value('ApiKey'), 'image-api-key');
      expect(
        receivedHeaders.last.value(HttpHeaders.cookieHeader),
        contains('session=image-session'),
      );
    },
  );

  test('returns HTTP failures without caching a successful response', () async {
    final client = DioImageClient();
    addTearDown(client.close);
    final response = await client.send(
      http.Request('GET', base.resolve('/missing')),
    );

    expect(response.statusCode, HttpStatus.notFound);
    expect(await response.stream.toBytes(), [1, 2, 3, 4]);
  });

  test('aborts requests while waiting for response headers', () async {
    final client = DioImageClient();
    addTearDown(client.close);
    final abort = Completer<void>();
    final request = http.AbortableRequest(
      'GET',
      base.resolve('/wait'),
      abortTrigger: abort.future,
    );
    final result = client.send(request);
    final expectation = expectLater(
      result,
      throwsA(isA<http.RequestAbortedException>()),
    );
    await waiting.future;
    abort.complete();
    await expectation;
  });

  test('aborts the response body after headers have arrived', () async {
    final client = DioImageClient();
    addTearDown(client.close);
    final abort = Completer<void>();
    final response = await client
        .send(
          http.AbortableRequest(
            'GET',
            base.resolve('/stream'),
            abortTrigger: abort.future,
          ),
        )
        .timeout(const Duration(seconds: 3));
    final chunks = StreamIterator(response.stream);
    addTearDown(chunks.cancel);
    expect(await chunks.moveNext().timeout(const Duration(seconds: 3)), isTrue);
    expect(chunks.current, [1, 2]);

    abort.complete();

    await expectLater(
      chunks.moveNext(),
      throwsA(isA<http.RequestAbortedException>()),
    );
  });

  test('rejects requests after close', () async {
    final client = DioImageClient()..close();
    await expectLater(client.get(base), throwsA(isA<http.ClientException>()));
  });

  test('clearing the CE cache keeps its metadata usable for another download', () async {
    final cache = StashImage.cacheManager;
    final url = base.resolve('/image.png').toString();
    await cache.getFileStream(url).drain<void>();
    expect(await cache.getFileFromCache(url), isNotNull);
    final metadata = File(
      '${root.path}/cached_network_image_ce/hive/cached_network_image_cache.hive',
    );
    expect(await metadata.exists(), isTrue);
    final unrelated = File('${root.path}/settings.json')
      ..writeAsStringSync('keep');
    final legacyDir = Directory('${root.path}/stashImageCache')..createSync();
    final legacy = File('${legacyDir.path}/old.png')..writeAsBytesSync([1]);
    final service = AppCacheService(
      temporaryDirectoryProvider: () async => root,
      applicationCacheDirectoryProvider: () async => root,
    );

    await service.clearImageCache();

    expect(await cache.getFileFromCache(url), isNull);
    expect(await metadata.exists(), isTrue);
    expect(await legacy.exists(), isFalse);
    expect(await unrelated.readAsString(), 'keep');
    await cache.getFileStream(url).drain<void>();
    final restored = await cache.getFileFromCache(url);
    expect(await restored!.file.readAsBytes(), [1, 2, 3, 4]);
  });
}
