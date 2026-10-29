import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;

/// Separate untimed PCM output. Never changes the audible player's configuration.
class CaptionAudioDecoder {
  Completer<void>? _cancelled;
  bool _closed = false;

  Future<Float32List> read({
    required String url,
    required Map<String, String> headers,
    required Duration start,
    required Duration end,
    required String audioTrack,
    required Directory temporaryDirectory,
  }) async {
    if (_closed) throw StateError('Decoder closed');
    final cancelled = _cancelled = Completer<void>();
    final dir = await temporaryDirectory.createTemp('scene-captions-');
    final file = File(p.join(dir.path, 'audio.pcm'));
    final player = Player(
      configuration: const PlayerConfiguration(
        title: 'StashFlow caption decoder',
        vo: 'null',
        bufferSize: 2 * 1024 * 1024,
        logLevel: MPVLogLevel.error,
      ),
    );
    StreamSubscription<bool>? completion;
    StreamSubscription<String>? errors;
    try {
      final native = player.platform;
      if (native is! NativePlayer) {
        throw UnsupportedError('Native audio required');
      }
      for (final option in {
        'vid': 'no',
        'sid': 'no',
        'aid': audioTrack == 'no' ? 'auto' : audioTrack,
        'ao': 'pcm',
        'ao-pcm-file': file.path,
        'ao-pcm-waveheader': 'no',
        'audio-format': 'float',
        'audio-samplerate': '16000',
        'audio-channels': 'mono',
        'af': 'format=format=float:srate=16000:channels=mono',
        'keep-open': 'no',
      }.entries) {
        await native.setProperty(option.key, option.value);
      }
      // setProperty does not propagate libmpv error codes. Never open a source
      // unless PCM output was accepted: falling back could play a second audio.
      if (await native.getProperty('options/ao') != 'pcm') {
        throw UnsupportedError('PCM audio output unavailable');
      }
      if (cancelled.isCompleted || _closed) throw StateError('Cancelled');
      final done = Completer<void>();
      completion = player.stream.completed.listen((value) {
        if (value && !done.isCompleted) done.complete();
      });
      errors = player.stream.error.listen((_) {
        if (!done.isCompleted) {
          done.completeError(StateError('Audio extraction failed'));
        }
      });
      final opened = Future.wait<void>([
        player.open(Media(url, httpHeaders: headers, start: start, end: end)),
        done.future,
      ]);
      await Future.any([
        opened,
        cancelled.future,
      ]).timeout(const Duration(seconds: 30));
      await player.stop(); // Flush the file writer before reading.
      if (cancelled.isCompleted || _closed) throw StateError('Cancelled');
      final maximum = (end - start).inMilliseconds * 64 + 65536;
      if (!await file.exists() ||
          await file.length() == 0 ||
          await file.length() > maximum) {
        throw StateError('Invalid PCM output');
      }
      final bytes = await file.readAsBytes();
      if (bytes.length % 4 != 0) throw StateError('Invalid PCM samples');
      return Float32List.view(
        bytes.buffer,
        bytes.offsetInBytes,
        bytes.length ~/ 4,
      );
    } finally {
      await completion?.cancel();
      await errors?.cancel();
      await player.dispose();
      if (identical(_cancelled, cancelled)) _cancelled = null;
      await dir.delete(recursive: true);
    }
  }

  void cancel() {
    final cancelled = _cancelled;
    if (cancelled != null && !cancelled.isCompleted) cancelled.complete();
  }

  void close() {
    _closed = true;
    cancel();
  }
}
