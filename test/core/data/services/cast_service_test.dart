import 'dart:async';
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
