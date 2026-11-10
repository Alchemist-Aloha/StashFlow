import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_audio_focus.dart';

class _AndroidFocus extends PlaybackAudioFocus {
  _AndroidFocus(Future<AudioSession> Function() load)
    : super(loadSession: load);
  @override
  bool get supported => true;
}

class _Session implements AudioSession {
  final events = StreamController<AudioInterruptionEvent>.broadcast();
  Future<void> close() => events.close();

  final operations = <bool>[];
  AudioSessionConfiguration? config;
  Completer<bool>? pending;

  @override
  Stream<AudioInterruptionEvent> get interruptionEventStream => events.stream;

  @override
  Future<void> configure(AudioSessionConfiguration configuration) async {
    config = configuration;
  }

  @override
  Future<bool> setActive(
    bool active, {
    AVAudioSessionSetActiveOptions? avAudioSessionSetActiveOptions,
    AndroidAudioFocusGainType? androidAudioFocusGainType,
    AndroidAudioAttributes? androidAudioAttributes,
    bool? androidWillPauseWhenDucked,
    AudioSessionConfiguration fallbackConfiguration =
        const AudioSessionConfiguration.music(),
  }) async {
    operations.add(active);
    return active ? (pending?.future ?? Future.value(true)) : true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a new playback owner gets a fresh focus bridge', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final first = container.listen(playbackAudioFocusProvider, (_, _) {});
    final original = first.read();
    first.close();
    await container.pump();
    final second = container.listen(playbackAudioFocusProvider, (_, _) {});
    expect(second.read(), isNot(same(original)));
  });

  test(
    'release queued before initialization still follows a late grant',
    () async {
      final session = _Session()..pending = Completer<bool>();
      final focus = _AndroidFocus(() async => session);
      final request = focus.setActive(true);
      final release = focus.setActive(false);
      await Future<void>.delayed(Duration.zero);
      expect(session.operations, [true]);
      session.pending!.complete(true);
      expect(await request, isTrue);
      expect(await release, isTrue);
      expect(session.operations, [true, false]);
      expect(
        session.config!.androidAudioAttributes!.contentType,
        AndroidAudioContentType.movie,
      );
      expect(
        session.config!.androidAudioAttributes!.usage,
        AndroidAudioUsage.media,
      );
      expect(
        session.config!.androidAudioFocusGainType,
        AndroidAudioFocusGainType.gain,
      );
      expect(session.config!.androidWillPauseWhenDucked, isTrue);
      await focus.dispose();
      await session.events.close();
    },
  );

  test(
    'failed initialization can retry, and disposal cancels interruptions',
    () async {
      final session = _Session();
      var attempts = 0;
      final focus = _AndroidFocus(() async {
        if (attempts++ == 0) throw StateError('initialization failed');
        return session;
      });
      await expectLater(focus.setActive(true), throwsStateError);
      expect(await focus.setActive(true), isTrue);
      var interruptions = 0;
      focus.onInterruption = (_) => interruptions++;
      session.events.add(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);
      expect(interruptions, 1);
      await focus.dispose();
      session.events.add(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);
      expect(interruptions, 1);
      expect(session.operations, [true, false]);
      await session.events.close();
    },
  );
}
