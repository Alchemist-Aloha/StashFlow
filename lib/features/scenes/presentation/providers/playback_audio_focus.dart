import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playbackAudioFocusProvider = Provider.autoDispose<PlaybackAudioFocus>(
  (ref) => PlaybackAudioFocus(),
);

/// Android focus bridge for the single audible local session, never preloads.
/// Focus operations are serialized so a late grant cannot outlive a release.
class PlaybackAudioFocus {
  PlaybackAudioFocus({Future<AudioSession> Function()? loadSession})
    : _loadSession = loadSession ?? (() => AudioSession.instance);

  final Future<AudioSession> Function() _loadSession;
  bool get supported => !kIsWeb && Platform.isAndroid;

  void Function(AudioInterruptionEvent)? onInterruption;
  Future<AudioSession>? _session;
  StreamSubscription<AudioInterruptionEvent>? _subscription;
  Future<void> _operation = Future.value();

  Future<AudioSession> _initialize() async {
    final session = await _loadSession();
    await _subscription?.cancel();
    await session.configure(
      const AudioSessionConfiguration(
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.movie,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
    _subscription = session.interruptionEventStream.listen(
      (event) => onInterruption?.call(event),
    );
    return session;
  }

  Future<bool> setActive(bool active) {
    if (!supported) return Future.value(true);
    final result = _operation.then((_) async {
      if (!active && _session == null) return true;
      final session = await (_session ??= _initialize());
      return session.setActive(active);
    });
    _operation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        // A failed request must not prevent subsequent release/retry operations.
        _session = null;
      },
    );
    return result;
  }

  Future<void> dispose() async {
    onInterruption = null;
    try {
      await setActive(false);
    } finally {
      await _subscription?.cancel();
    }
  }
}
