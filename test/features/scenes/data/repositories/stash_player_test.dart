import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/playback_media.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stash_player.dart';

/// Requires libmpv: `flutter test --dart-define=RUN_NATIVE_PLAYER=true`.
const _native = bool.fromEnvironment('RUN_NATIVE_PLAYER');

void main() {
  test('classifies only MP4/WebM transcodes as live', () {
    const base = 'http://h/scene/7';
    expect(isLiveTranscode('$base/stream.mp4?resolution=LOW'), isTrue);
    expect(isLiveTranscode('$base/stream.webm'), isTrue);
    expect(isLiveTranscode('$base/stream'), isFalse);
    expect(isLiveTranscode('$base/stream.m3u8'), isFalse);
    expect(isLiveTranscode('$base/stream.mpd'), isFalse);
  });

  group('live transcodes', () {
    late HttpServer server;
    late List<Uri> requests;
    late StashPlayer player;

    /// mpv may probe or retry, so match on content rather than order.
    Future<Uri> waitFor(bool Function(Uri) matches) async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (DateTime.now().isBefore(deadline)) {
        final hit = requests.where(matches).firstOrNull;
        if (hit != null) return hit;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      throw TimeoutException('no matching request in $requests');
    }

    setUp(() async {
      MediaKit.ensureInitialized();
      requests = [];
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        requests.add(request.uri);
        request.response.statusCode = 404;
        await request.response.close();
      });
      player = StashPlayer();
    });

    tearDown(() async {
      await player.dispose();
      await server.close(force: true);
    });

    String url(String path) => 'http://127.0.0.1:${server.port}/scene/7/$path';

    test('opens at start= and reports scene time and duration', () async {
      await player.open(
        createPlaybackMedia(
          url('stream.mp4?resolution=LOW'),
          start: const Duration(seconds: 30),
          duration: const Duration(minutes: 10),
        ),
        play: false,
      );

      final uri = await waitFor((u) => u.path.endsWith('stream.mp4'));
      expect(uri.queryParameters['start'], '30.000');
      expect(uri.queryParameters['resolution'], 'LOW');
      expect(player.state.position, const Duration(seconds: 30));
      expect(player.state.duration, const Duration(minutes: 10));
    });

    test('seeking reopens the transcode at the target', () async {
      await player.open(
        createPlaybackMedia(url('stream.webm'), duration: Duration.zero),
        play: false,
      );
      await waitFor((u) => u.queryParameters['start'] == '0.000');

      await player.seek(const Duration(seconds: 90, milliseconds: 500));

      await waitFor((u) => u.queryParameters['start'] == '90.500');
      expect(player.liveOffset, const Duration(seconds: 90, milliseconds: 500));
      expect(
        player.state.position,
        const Duration(seconds: 90, milliseconds: 500),
      );
    });

    test('seekable sources pass through without an offset', () async {
      await player.open(
        createPlaybackMedia(
          url('stream.mp4'),
          start: const Duration(seconds: 30),
        ),
        play: false,
      );
      await player.open(createPlaybackMedia(url('stream')), play: false);

      final uri = await waitFor((u) => u.path.endsWith('/stream'));
      expect(uri.queryParameters.containsKey('start'), isFalse);
      expect(player.liveOffset, Duration.zero);
      expect(player.state.position, lessThan(const Duration(seconds: 1)));
    });
  }, skip: !_native);
}
