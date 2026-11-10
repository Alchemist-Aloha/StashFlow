// Run with: flutter test scripts/benchmark_image_cache.dart --reporter expanded
// Measures the production cache on this host, not rendering or Internet latency.
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  test('production image cache benchmark', () async {
    const imageCount = 80;
    const warmPasses = 10;
    const measuredRounds = 7;
    const headers = {'Authorization': 'Bearer image-cache-benchmark'};
    final root = await Directory.systemTemp.createTemp(
      'stashflow-cache-bench-',
    );
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => root.path,
    );

    final bytes = await File('asset/stashfluttericon.png').readAsBytes();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var requests = 0;
    final subscription = server.listen((request) async {
      requests++;
      if (request.headers.value(HttpHeaders.authorizationHeader) !=
          headers['Authorization']) {
        request.response.statusCode = HttpStatus.unauthorized;
      } else {
        request.response.headers
          ..contentType = ContentType('image', 'png')
          ..set(HttpHeaders.cacheControlHeader, 'max-age=604800')
          ..set(HttpHeaders.etagHeader, 'benchmark-image');
        request.response.contentLength = bytes.length;
        request.response.add(bytes);
      }
      await request.response.close();
    });
    final urls = List.generate(
      imageCount,
      (i) => 'http://127.0.0.1:${server.port}/image-$i.png',
    );
    final cache = StashImage.cacheManager;
    final cold = <double>[];
    final warm = <double>[];
    final clear = <double>[];

    Future<void> load(String url) async {
      final info = await cache
          .getFileStream(url, headers: headers)
          .where((response) => response is FileInfo)
          .cast<FileInfo>()
          .first;
      final actual = await info.file.readAsBytes();
      if (actual.length != bytes.length || actual.first != bytes.first) {
        throw StateError('Cached image bytes differ');
      }
    }

    try {
      await cache.emptyCache();
      // The first round warms the JIT, transport, and metadata store equally.
      for (var round = 0; round <= measuredRounds; round++) {
        final beforeCold = requests;
        final watch = Stopwatch()..start();
        for (final url in urls) {
          await load(url);
        }
        watch.stop();
        expect(requests - beforeCold, imageCount);
        if (round > 0) cold.add(watch.elapsedMicroseconds / 1000);

        final beforeWarm = requests;
        watch
          ..reset()
          ..start();
        for (var pass = 0; pass < warmPasses; pass++) {
          for (final url in urls) {
            await load(url);
          }
        }
        watch.stop();
        expect(requests, beforeWarm, reason: 'Warm reads must not use HTTP');
        if (round > 0) warm.add(watch.elapsedMicroseconds / 1000);

        watch
          ..reset()
          ..start();
        await cache.emptyCache();
        watch.stop();
        if (round > 0) clear.add(watch.elapsedMicroseconds / 1000);
        for (final url in urls) {
          expect(await cache.getFileFromCache(url), isNull);
        }
      }
      // ignore: avoid_print
      print(
        'IMAGE_CACHE_BENCHMARK ${jsonEncode({'os': Platform.operatingSystem, 'dart': Platform.version, 'image_count': imageCount, 'image_bytes': bytes.length, 'warm_reads': imageCount * warmPasses, 'measured_rounds': measuredRounds, 'cold_download_ms': cold, 'warm_read_ms': warm, 'clear_ms': clear})}',
      );
    } finally {
      await cache.dispose();
      await subscription.cancel();
      await server.close(force: true);
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pathChannel,
        null,
      );
      await root.delete(recursive: true);
    }
  });
}
