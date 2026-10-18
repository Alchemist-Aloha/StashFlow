import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stash_app_flutter/core/utils/vtt_service.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';

void main() {
  test('VTT logs omit authenticated URLs and exception payloads', () async {
    final logger = AppLogStore.instance
      ..clear()
      ..isEnabled = true;
    addTearDown(() {
      logger
        ..isEnabled = false
        ..clear();
    });
    final service = VttService(
      apiKey: 'secret-test-key',
      client: MockClient((request) async {
        expect(request.url.queryParameters['apikey'], 'secret-test-key');
        throw http.ClientException('failed to fetch ${request.url}');
      }),
    );
    expect(
      await service.fetchSpriteInfo('https://stash.test/thumbs.vtt', {}),
      isNull,
    );
    expect(logger.entries, isNotEmpty);
    final messages = logger.entries.map((entry) => entry.message).join('\n');
    expect(messages, isNot(contains('secret-test-key')));
    expect(messages, isNot(contains('https://stash.test')));
  });

  test('concurrent VTT loads share one HTTP request', () async {
    final responseCompleter = Completer<http.Response>();
    var requestCount = 0;
    final client = MockClient((request) {
      requestCount++;
      return responseCompleter.future;
    });
    final service = VttService(client: client);

    final first = service.fetchSpriteInfo(
      'https://example.com/scene_thumbs.vtt',
      const {},
    );
    final second = service.fetchSpriteInfo(
      'https://example.com/scene_thumbs.vtt',
      const {},
    );

    await Future<void>.delayed(Duration.zero);
    expect(requestCount, 1);

    responseCompleter.complete(
      http.Response(
        'WEBVTT\n\n'
        '00:00:00.000 --> 00:00:10.000\n'
        'scene_sprite.jpg#xywh=0,0,160,90\n',
        200,
      ),
    );

    final results = await Future.wait([first, second]);
    expect(results[0], hasLength(1));
    expect(results[1], hasLength(1));
    expect(requestCount, 1);
  });

  test('non-404 VTT failures remain retryable', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return http.Response('temporary failure', 500);
    });
    final service = VttService(client: client);

    final first = await service.fetchSpriteInfo(
      'https://example.com/scene_thumbs.vtt',
      const {},
    );
    final second = await service.fetchSpriteInfo(
      'https://example.com/scene_thumbs.vtt',
      const {},
    );

    expect(first, isNull);
    expect(second, isNull);
    expect(requestCount, 2);
  });
}
