import 'dart:async';
import 'dart:io';

import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/services/cast_service.dart';

void main() {
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
  int disconnectCalls = 0;
  int pauseCalls = 0;
  int seekCalls = 0;
  Duration? lastSeekPosition;

  void emitPosition(Duration position) {
    updatePosition(position);
    _positionController.add(position);
  }

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }

  @override
  Future<void> loadMedia(dc.CastMedia media) async {
    loadMediaCalls++;
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
