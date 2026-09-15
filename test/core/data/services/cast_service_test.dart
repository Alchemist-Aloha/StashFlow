import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/services/cast_service.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';

void main() {
  setUp(() {
    AppLogStore.instance
      ..clear()
      ..isEnabled = true;
  });

  tearDown(() {
    AppLogStore.instance
      ..clear()
      ..isEnabled = false;
  });

  test(
    'tracks local handoff position while casting and clears session on stop',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = _FakeCastSession();
      final notifier = container.read(castServiceProvider.notifier);

      await notifier.setActiveSession(
        session,
        localResumePosition: const Duration(seconds: 42),
        localWasPlaying: true,
      );

      var state = container.read(castServiceProvider);
      expect(state.activeSession, same(session));
      expect(state.isCasting, isTrue);
      expect(state.localResumePosition, const Duration(seconds: 42));
      expect(state.localWasPlaying, isTrue);
      expect(state.remotePosition, const Duration(seconds: 42));
      expect(state.remoteIsPlaying, isTrue);

      await notifier.pause();
      state = container.read(castServiceProvider);
      expect(session.pauseCalls, 1);
      expect(state.remoteIsPlaying, isFalse);

      await notifier.seek(const Duration(seconds: 60));
      state = container.read(castServiceProvider);
      expect(session.seekCalls, 1);
      expect(session.lastSeekPosition, const Duration(seconds: 60));
      expect(state.remotePosition, const Duration(seconds: 60));

      await notifier.stopCasting();
      state = container.read(castServiceProvider);
      expect(session.disconnectCalls, 1);
      expect(state.activeSession, isNull);
      expect(state.isCasting, isFalse);
      expect(state.localResumePosition, isNull);
      expect(state.localWasPlaying, isFalse);
      expect(state.remotePosition, Duration.zero);
      expect(state.remoteIsPlaying, isFalse);
    },
  );

  test('records cast process logs in the app debug log store', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = _FakeCastSession();
    final notifier = container.read(castServiceProvider.notifier);

    await notifier.setActiveSession(
      session,
      localResumePosition: const Duration(seconds: 42),
      localWasPlaying: true,
    );
    await notifier.pause();
    await notifier.seek(const Duration(seconds: 60));
    await notifier.stopCasting();

    final entries = AppLogStore.instance.entries
        .where((entry) => entry.source == 'cast_service')
        .map((entry) => entry.message)
        .toList();

    expect(
      entries,
      containsAllInOrder([
        contains('active session set device=Fake Cast'),
        contains('pause requested device=Fake Cast'),
        contains('seek requested device=Fake Cast position=0:01:00.000000'),
        contains('stopping session device=Fake Cast'),
        contains('session stopped'),
      ]),
    );
  });

  test(
    'retries Chromecast media load until playback state is confirmed',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = _FakeCastSession(
        protocol: dc.CastProtocol.chromecast,
        playbackStartsOnLoadAttempt: 2,
      );
      final notifier = container.read(castServiceProvider.notifier);

      await notifier.loadMediaAndConfirm(
        session,
        const dc.CastMedia(
          url: 'http://example.test/video.mp4',
          type: dc.CastMediaType.mp4,
        ),
        confirmationTimeout: const Duration(milliseconds: 10),
        retryDelay: Duration.zero,
      );

      expect(session.loadMediaCalls, 2);
      expect(session.state, dc.SessionState.playing);
    },
  );

  test('tracks remote position updates from active cast session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = _FakeCastSession();
    final notifier = container.read(castServiceProvider.notifier);

    await notifier.setActiveSession(
      session,
      localResumePosition: const Duration(seconds: 5),
      localWasPlaying: true,
    );

    session.emitPosition(const Duration(seconds: 47));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(castServiceProvider);
    expect(state.remotePosition, const Duration(seconds: 47));
  });

  test(
    'reports remote completion once after playback reaches the end',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = _FakeCastSession();
      final notifier = container.read(castServiceProvider.notifier);
      session.emitState(dc.SessionState.playing);
      await notifier.setActiveSession(session);

      session.emitDuration(const Duration(minutes: 2));
      session.emitPosition(const Duration(minutes: 2));
      session.emitState(dc.SessionState.idle);
      await Future<void>.delayed(Duration.zero);

      var state = container.read(castServiceProvider);
      expect(state.remoteDuration, const Duration(minutes: 2));
      expect(state.completedMediaCount, 1);

      session.emitState(dc.SessionState.idle);
      await Future<void>.delayed(Duration.zero);
      state = container.read(castServiceProvider);
      expect(state.completedMediaCount, 1);
    },
  );

  test(
    'does not report a known-duration cast stopped before its end',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = _FakeCastSession();
      final notifier = container.read(castServiceProvider.notifier);
      session.emitState(dc.SessionState.playing);
      await notifier.setActiveSession(session);

      session.emitDuration(const Duration(minutes: 2));
      session.emitPosition(const Duration(seconds: 30));
      session.emitState(dc.SessionState.idle);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(castServiceProvider).completedMediaCount, 0);
    },
  );

  test('playing again rearms remote completion for loop playback', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = _FakeCastSession();
    final notifier = container.read(castServiceProvider.notifier);
    session.emitState(dc.SessionState.playing);
    await notifier.setActiveSession(session);
    session.emitState(dc.SessionState.idle);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(castServiceProvider).completedMediaCount, 1);

    await notifier.seek(Duration.zero);
    await notifier.play();
    session.emitState(dc.SessionState.idle);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(castServiceProvider).completedMediaCount, 2);
  });

  test('keeps the remote paused when a seek is issued while paused', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = _FakeCastSession();
    final notifier = container.read(castServiceProvider.notifier);

    await notifier.setActiveSession(session, localWasPlaying: true);
    await notifier.pause();
    expect(container.read(castServiceProvider).remoteIsPlaying, isFalse);

    await notifier.seek(const Duration(seconds: 60));

    final state = container.read(castServiceProvider);
    expect(state.remotePosition, const Duration(seconds: 60));
    expect(state.remoteIsPlaying, isFalse);
    // One pause from the user, one re-asserted because renderers commonly
    // resume playback when a seek lands.
    expect(session.pauseCalls, 2);
  });

  test(
    'keeps the remote playing when a seek is issued while playing',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = _FakeCastSession();
      final notifier = container.read(castServiceProvider.notifier);

      session.emitState(dc.SessionState.playing);
      await notifier.setActiveSession(session, localWasPlaying: true);

      await notifier.seek(const Duration(seconds: 60));

      expect(container.read(castServiceProvider).remoteIsPlaying, isTrue);
      expect(session.pauseCalls, 0);
    },
  );

  test(
    'polls a silent DLNA renderer to keep position and state in sync',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final controlUrl = 'http://127.0.0.1:${server.port}/control';
      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        if (body.contains('GetPositionInfo')) {
          request.response.write(
            '<?xml version="1.0"?><s:Envelope><s:Body>'
            '<u:GetPositionInfoResponse>'
            '<TrackDuration>00:10:00</TrackDuration>'
            '<RelTime>00:05:30</RelTime>'
            '</u:GetPositionInfoResponse></s:Body></s:Envelope>',
          );
        } else if (body.contains('GetTransportInfo')) {
          request.response.write(
            '<?xml version="1.0"?><s:Envelope><s:Body>'
            '<u:GetTransportInfoResponse>'
            '<CurrentTransportState>PLAYING</CurrentTransportState>'
            '</u:GetTransportInfoResponse></s:Body></s:Envelope>',
          );
        } else {
          request.response.statusCode = HttpStatus.internalServerError;
        }
        await request.response.close();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(castServiceProvider.notifier)
        ..remotePollInterval = const Duration(milliseconds: 20)
        ..remoteReportStaleAfter = const Duration(milliseconds: 20);

      final session = _FakeDlnaSession(avTransportControlUrl: controlUrl);
      await notifier.setActiveSession(session, localWasPlaying: true);

      // The session never reports, so the fallback poll has to take over.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final state = container.read(castServiceProvider);
      expect(state.remotePosition, const Duration(minutes: 5, seconds: 30));
      expect(state.remoteIsPlaying, isTrue);
      expect(state.remoteDuration, const Duration(minutes: 10));

      await notifier.stopCasting();
    },
  );

  test(
    'adds the piped seek offset when polling a silent DLNA renderer',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final controlUrl = 'http://127.0.0.1:${server.port}/control';
      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        if (body.contains('GetPositionInfo')) {
          request.response.write(
            '<?xml version="1.0"?><s:Envelope><s:Body>'
            '<u:GetPositionInfoResponse>'
            '<TrackDuration>00:00:01</TrackDuration>'
            '<RelTime>00:00:05</RelTime>'
            '</u:GetPositionInfoResponse></s:Body></s:Envelope>',
          );
        } else if (body.contains('GetTransportInfo')) {
          request.response.write(
            '<?xml version="1.0"?><s:Envelope><s:Body>'
            '<u:GetTransportInfoResponse>'
            '<CurrentTransportState>PLAYING</CurrentTransportState>'
            '</u:GetTransportInfoResponse></s:Body></s:Envelope>',
          );
        } else {
          request.response.statusCode = HttpStatus.internalServerError;
        }
        await request.response.close();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(castServiceProvider.notifier)
        ..remotePollInterval = const Duration(milliseconds: 20)
        ..remoteReportStaleAfter = const Duration(milliseconds: 20);

      final session = _FakeDlnaSession(avTransportControlUrl: controlUrl);
      await notifier.loadMediaAndConfirm(
        session,
        const dc.CastMedia(
          url: 'http://example.test/stream.m3u8',
          type: dc.CastMediaType.hls,
        ),
      );
      await notifier.setActiveSession(
        session,
        localResumePosition: const Duration(seconds: 10),
        localWasPlaying: true,
      );
      await notifier.seek(const Duration(seconds: 100));

      // A piped TS restarts at zero, so the renderer's 5s is 105s absolute.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final state = container.read(castServiceProvider);
      expect(state.remotePosition, const Duration(seconds: 105));
      // The renderer's placeholder duration must not replace the real one.
      expect(state.remoteDuration, Duration.zero);

      await notifier.stopCasting();
    },
  );

  test(
    'restarts cast media on the current session for scene switches',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = _FakeCastSession();
      final notifier = container.read(castServiceProvider.notifier);

      await notifier.setActiveSession(
        session,
        localResumePosition: const Duration(seconds: 12),
        localWasPlaying: true,
      );

      await notifier.restartActiveSessionWithMedia(
        const dc.CastMedia(
          url: 'http://example.test/next.mp4',
          type: dc.CastMediaType.mp4,
          title: 'Next Scene',
          startPosition: Duration(seconds: 3),
        ),
        localResumePosition: const Duration(seconds: 3),
        localWasPlaying: true,
      );

      final state = container.read(castServiceProvider);
      expect(session.disconnectCalls, 1);
      expect(session.connectCalls, 1);
      expect(session.loadMediaCalls, 1);
      expect(session.lastLoadedMedia?.url, 'http://example.test/next.mp4');
      expect(state.activeSession, same(session));
      expect(state.isCasting, isTrue);
      expect(state.localResumePosition, const Duration(seconds: 3));
      expect(state.remotePosition, const Duration(seconds: 3));
      expect(state.remoteIsPlaying, isTrue);
    },
  );
}

class _FakeDlnaSession extends dc.DlnaSession {
  _FakeDlnaSession({required String avTransportControlUrl})
    : super(
        device: dc.CastDevice(
          id: 'fake-dlna',
          name: 'Fake DLNA TV',
          protocol: dc.CastProtocol.dlna,
          address: InternetAddress.loopbackIPv4,
          port: 80,
        ),
        description: dc.DlnaDeviceDescription(
          friendlyName: 'Fake DLNA TV',
          udn: 'uuid:fake-dlna',
          avTransportControlUrl: avTransportControlUrl,
          locationUrl: 'http://127.0.0.1/',
        ),
      );

  @override
  Future<void> loadMedia(dc.CastMedia media) async {}

  // Transport actions are exercised through the app service, not the renderer.
  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seek(Duration position) async {}
}

class _FakeCastSession extends dc.CastSession {
  _FakeCastSession({
    dc.CastProtocol protocol = dc.CastProtocol.chromecast,
    this.playbackStartsOnLoadAttempt = 1,
  }) : super(
         dc.CastDevice(
           id: 'fake',
           name: 'Fake Cast',
           protocol: protocol,
           address: InternetAddress.loopbackIPv4,
           port: 8009,
         ),
       );

  final int playbackStartsOnLoadAttempt;
  final _positionController = StreamController<Duration>.broadcast();
  int loadMediaCalls = 0;
  int connectCalls = 0;
  int disconnectCalls = 0;
  int pauseCalls = 0;
  int seekCalls = 0;
  Duration? lastSeekPosition;
  dc.CastMedia? lastLoadedMedia;

  void emitPosition(Duration position) {
    updatePosition(position);
    _positionController.add(position);
  }

  void emitDuration(Duration duration) => updateDuration(duration);

  void emitState(dc.SessionState state) => stateMachine.forceState(state);

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Future<void> connect() async {
    connectCalls++;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }

  @override
  Future<void> loadMedia(dc.CastMedia media) async {
    loadMediaCalls++;
    lastLoadedMedia = media;
    stateMachine.forceState(dc.SessionState.loading);
    if (loadMediaCalls >= playbackStartsOnLoadAttempt) {
      Future<void>.microtask(
        () => stateMachine.forceState(dc.SessionState.playing),
      );
    }
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {
    seekCalls++;
    lastSeekPosition = position;
  }

  @override
  Future<void> setSubtitle(dc.CastSubtitle? subtitle) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}
}
