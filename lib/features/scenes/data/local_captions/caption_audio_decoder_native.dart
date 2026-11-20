import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;

const _sampleRate = 16000;

/// Separate untimed PCM output. Never changes the audible player's configuration.
///
/// One decoder segment streams continuously from its start position into an
/// append-only temporary PCM file, and consecutive windows are served from it.
/// mpv's PCM output is untimed, so decoding runs ahead of playback (bounded by
/// [_readAhead]) while the worker transcribes earlier windows. A segment is
/// replaced after a seek outside its buffer, a source change, or [_maxSegment]
/// of audio, which bounds the temporary file (about 64 KB per second).
class CaptionAudioDecoder {
  static const _maxSegment = Duration(minutes: 3);
  static const _readAhead = Duration(seconds: 30);

  /// Jumps no further than this past decoded audio reuse the segment.
  static const _reuseGap = Duration(seconds: 4);
  static const _stallTimeout = Duration(seconds: 30);

  _Segment? _segment;
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
    try {
      var segment = _segment;
      if (segment == null ||
          !segment.serves(url, headers, audioTrack, start, end)) {
        _segment = null;
        await segment?.dispose();
        if (_closed || cancelled.isCompleted) throw StateError('Cancelled');
        segment = await _Segment.open(
          url: url,
          headers: headers,
          audioTrack: audioTrack,
          origin: start,
          temporaryDirectory: temporaryDirectory,
          readAhead: _readAhead,
        );
        if (_closed) {
          await segment.dispose();
          throw StateError('Decoder closed');
        }
        _segment = segment;
      }
      final samples = await segment.take(
        start,
        end,
        cancelled.future,
        _stallTimeout,
      );
      if (cancelled.isCompleted || _closed) throw StateError('Cancelled');
      return samples;
    } on Object {
      // A failed or cancelled segment may be mid-stream or broken; reopen.
      final failed = _segment;
      _segment = null;
      await failed?.dispose();
      rethrow;
    } finally {
      if (identical(_cancelled, cancelled)) _cancelled = null;
    }
  }

  /// Aborts the in-flight [read]. The next read reopens decoding.
  void cancel() {
    final cancelled = _cancelled;
    if (cancelled != null && !cancelled.isCompleted) cancelled.complete();
  }

  Future<void> close() async {
    _closed = true;
    cancel();
    final segment = _segment;
    _segment = null;
    await segment?.dispose();
  }
}

class _Segment {
  _Segment._(
    this.url,
    this.headers,
    this.audioTrack,
    this.origin,
    this._player,
    this._directory,
    this._file,
    this._readAhead,
  );

  final String url, audioTrack;
  final Map<String, String> headers;
  final Duration origin, _readAhead;
  final Player _player;
  final Directory _directory;
  final File _file;
  final _subscriptions = <StreamSubscription<Object?>>[];
  RandomAccessFile? _reader;
  Timer? _poll;
  Future<void>? _pulling;
  bool _completed = false, _failed = false, _paused = false, _disposed = false;
  bool _flushed = false;

  /// Decoded samples; `_buffer[0]` is segment sample index [_bufferStart].
  Float32List _buffer = Float32List(_sampleRate * 16);
  int _bufferStart = 0, _bufferLength = 0, _fileOffset = 0;

  /// The furthest sample a reader has requested, for read-ahead pausing.
  int _requested = 0;

  int get _decoded => _bufferStart + _bufferLength;

  static int _index(Duration offset) =>
      (offset.inMicroseconds * _sampleRate / 1000000).round();

  static Future<_Segment> open({
    required String url,
    required Map<String, String> headers,
    required String audioTrack,
    required Duration origin,
    required Directory temporaryDirectory,
    required Duration readAhead,
  }) async {
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
    final segment = _Segment._(
      url,
      Map.unmodifiable(headers),
      audioTrack,
      origin,
      player,
      dir,
      file,
      readAhead,
    );
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
        // An audio reinitialization must never truncate samples already read.
        'ao-pcm-append': 'yes',
        'ao-pcm-waveheader': 'no',
        'audio-format': 'float',
        'audio-samplerate': '$_sampleRate',
        'audio-channels': 'mono',
        'af': 'format=format=float:srate=$_sampleRate:channels=mono',
        'keep-open': 'no',
      }.entries) {
        await native.setProperty(option.key, option.value);
      }
      // setProperty does not propagate libmpv error codes. Never open a source
      // unless PCM output was accepted: falling back could play a second audio.
      if (await native.getProperty('options/ao') != 'pcm') {
        throw UnsupportedError('PCM audio output unavailable');
      }
      segment._subscriptions
        ..add(
          player.stream.completed.listen((value) {
            if (value) segment._completed = true;
          }),
        )
        ..add(player.stream.error.listen((_) => segment._failed = true));
      await player.open(Media(url, httpHeaders: headers, start: origin));
      segment._poll = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => unawaited(segment._pull().catchError((Object _) {})),
      );
      return segment;
    } on Object {
      await segment.dispose();
      rethrow;
    }
  }

  /// Whether [start, end) can come from this segment without reopening.
  bool serves(
    String url,
    Map<String, String> headers,
    String audioTrack,
    Duration start,
    Duration end,
  ) {
    if (_failed || _disposed) return false;
    if (url != this.url || audioTrack != this.audioTrack) return false;
    if (headers.length != this.headers.length ||
        headers.entries.any((e) => this.headers[e.key] != e.value)) {
      return false;
    }
    final first = _index(start - origin), last = _index(end - origin);
    return first >= _bufferStart &&
        first <= _decoded + _index(CaptionAudioDecoder._reuseGap) &&
        last <= _index(CaptionAudioDecoder._maxSegment) &&
        !(_completed && first >= _decoded);
  }

  /// Waits until [start, end) is decoded (or the media ends) and copies it.
  Future<Float32List> take(
    Duration start,
    Duration end,
    Future<void> cancelled,
    Duration stallTimeout,
  ) async {
    final first = math.max(_index(start - origin), _bufferStart);
    final last = _index(end - origin);
    _requested = math.max(_requested, last);
    var cancel = false;
    unawaited(cancelled.then((_) => cancel = true));
    var progress = DateTime.now();
    var seen = _decoded;
    while (true) {
      if (cancel || _disposed) throw StateError('Cancelled');
      if (_failed) throw StateError('Audio extraction failed');
      if (_paused && _decoded < last + _index(_readAhead)) {
        _paused = false;
        await _player.play();
      }
      await _pull();
      if (_decoded >= last || _completed) break;
      if (_decoded != seen) {
        seen = _decoded;
        progress = DateTime.now();
      } else if (DateTime.now().difference(progress) > stallTimeout) {
        throw TimeoutException('Audio extraction stalled');
      }
      await Future.any([
        Future<void>.delayed(const Duration(milliseconds: 40)),
        cancelled,
      ]);
    }
    if (_completed && !_flushed) {
      // The PCM writer flushes its last buffered samples when output closes.
      _flushed = true;
      await _player.stop();
      await _pull(drain: true);
    }
    final available = math.min(last, _decoded);
    if (available <= first) throw StateError('Invalid PCM output');
    final result = Float32List.fromList(
      Float32List.sublistView(
        _buffer,
        first - _bufferStart,
        available - _bufferStart,
      ),
    );
    // Windows advance monotonically; earlier context is never requested again
    // without a seek, which reopens the segment.
    _trim(first);
    return result;
  }

  /// Reads newly written PCM. With [drain], also waits for a read that starts
  /// after any in-flight one, so bytes flushed just now are included.
  Future<void> _pull({bool drain = false}) {
    final running = _pulling;
    if (running != null) {
      return drain ? running.then((_) => _pull(drain: true)) : running;
    }
    return _pulling = _read().whenComplete(() => _pulling = null);
  }

  Future<void> _read() async {
    if (_disposed) return;
    if (_reader == null) {
      if (!await _file.exists()) return;
      _reader = await _file.open();
    }
    final reader = _reader!;
    final length = await reader.length();
    final available = (length - _fileOffset) & ~3;
    if (available > 0) {
      await reader.setPosition(_fileOffset);
      final bytes = await reader.read(available);
      final count = bytes.length ~/ 4;
      _fileOffset += count * 4;
      _append(Float32List.view(bytes.buffer, bytes.offsetInBytes, count));
    }
    if (!_paused && !_completed && _decoded > _requested + _index(_readAhead)) {
      _paused = true;
      await _player.pause();
    }
  }

  void _append(Float32List samples) {
    final needed = _bufferLength + samples.length;
    if (needed > _buffer.length) {
      final grown = Float32List(math.max(needed, _buffer.length * 2));
      grown.setRange(0, _bufferLength, _buffer);
      _buffer = grown;
    }
    _buffer.setRange(_bufferLength, needed, samples);
    _bufferLength = needed;
  }

  void _trim(int index) {
    final drop = math.min(index - _bufferStart, _bufferLength);
    if (drop <= 0) return;
    _buffer.setRange(0, _bufferLength - drop, _buffer, drop);
    _bufferStart += drop;
    _bufferLength -= drop;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _poll?.cancel();
    try {
      await _pulling;
    } on Object {
      // Disposal continues; the segment is unusable either way.
    }
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _reader?.close();
    await _player.dispose();
    await _directory.delete(recursive: true);
  }
}
