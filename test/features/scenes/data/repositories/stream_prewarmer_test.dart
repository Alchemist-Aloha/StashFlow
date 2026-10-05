import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_prewarmer.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';

class _ProbeScene extends Fake implements Scene {
  @override
  String get id => 'probe';
}

void main() {
  late HttpServer server;
  late ProviderContainer container;
  late StreamPrewarmer prewarmer;
  late String url;
  final scene = _ProbeScene();

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    container = ProviderContainer();
    prewarmer = container.read(streamPrewarmerProvider.notifier);
    url = 'http://127.0.0.1:${server.port}/stream';
  });

  tearDown(() async {
    container.dispose();
    await server.close(force: true);
  });

  test('pending-header probes are deduplicated and cancellable', () async {
    final received = Completer<void>();
    var requests = 0;
    server.listen((request) {
      requests++;
      if (!received.isCompleted) received.complete();
    });
    final pending = prewarmer.prewarm(scene, url);
    await received.future.timeout(const Duration(seconds: 2));
    await prewarmer.prewarm(scene, url).timeout(const Duration(seconds: 1));
    expect(requests, 1);
    prewarmer.cancelAllExcept({});
    await pending.timeout(const Duration(seconds: 1));
  });

  test(
    'cancellation allows a new probe without stale cleanup removing it',
    () async {
      final first = Completer<void>();
      final second = Completer<void>();
      HttpRequest? replacementRequest;
      var requests = 0;
      server.listen((request) {
        requests++;
        if (requests == 1) {
          first.complete();
        } else if (requests == 2) {
          replacementRequest = request;
          second.complete();
        }
      });
      final pending = prewarmer.prewarm(scene, url);
      await first.future.timeout(const Duration(seconds: 2));
      prewarmer.cancel(scene.id);
      final replacement = prewarmer.prewarm(scene, url);
      await pending.timeout(const Duration(seconds: 1));
      await second.future.timeout(const Duration(seconds: 2));
      await prewarmer.prewarm(scene, url).timeout(const Duration(seconds: 1));
      expect(requests, 2);
      replacementRequest!.response.write('video header');
      await replacementRequest!.response.close();
      await replacement.timeout(const Duration(seconds: 1));
    },
  );

  test(
    'servers ignoring Range cannot leave an unbounded body download',
    () async {
      var requests = 0;
      server.listen((request) async {
        requests++;
        expect(request.headers.value(HttpHeaders.rangeHeader), 'bytes=0-1023');
        request.response.bufferOutput = false;
        if (requests == 1) {
          // Chunked 200 response: ignore Range and hold the body open.
          request.response.add(List<int>.filled(4096, 0));
          await request.response.flush();
        } else {
          request.response.write('header');
          await request.response.close();
        }
      });
      await prewarmer.prewarm(scene, url, rangeBytes: 1024);
      for (var attempt = 0; requests < 2 && attempt < 100; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await prewarmer.prewarm(scene, url, rangeBytes: 1024);
      }
      expect(
        requests,
        2,
        reason: 'the oversized probe must finish without waiting for EOF',
      );
    },
  );
}
