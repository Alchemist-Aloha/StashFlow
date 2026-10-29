import 'dart:async';
import 'caption_cue.dart';

enum CaptionStatus { preparing, ready, failed }

class CaptionFrame {
  const CaptionFrame(this.status, [this.text = '']);
  final CaptionStatus status;
  final String text;
}

/// Bounded look-ahead scheduling, owned by one scene/track/model/language session.
class CaptionSession {
  CaptionSession({
    required this.position,
    required this.duration,
    required this.process,
    required this.cancelDecode,
    required this.onFrame,
  });
  final Duration Function() position, duration;
  final Future<List<CaptionCue>> Function(Duration start, Duration end) process;
  final void Function() cancelDecode;
  final void Function(CaptionFrame) onFrame;
  final _cache = <int, List<CaptionCue>>{};
  Timer? _timer;
  Future<void>? _pending;
  bool _disposed = false, _failed = false;
  int _generation = 0;
  Duration? _lastPosition;
  CaptionFrame? _lastFrame;
  static const window = Duration(seconds: 6);

  void start() {
    tick();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
  }

  void _emit(CaptionFrame frame) {
    if (_disposed ||
        (_lastFrame?.text == frame.text && _lastFrame?.status == frame.status)) {
      return;
    }
    _lastFrame = frame;
    onFrame(frame);
  }

  /// Exposed for deterministic tests; production ticks on a timer.
  void tick() {
    if (_disposed || _failed) return;
    final now = position();
    if (_lastPosition != null &&
        (now - _lastPosition!).abs() > const Duration(seconds: 2)) {
      ++_generation;
      cancelDecode();
    }
    _lastPosition = now;
    final index = now.inMilliseconds ~/ window.inMilliseconds;
    final current = _cache[index];
    if (current == null) {
      _emit(const CaptionFrame(CaptionStatus.preparing));
    } else {
      _emit(
        CaptionFrame(
          CaptionStatus.ready,
          current
              .where((cue) => cue.contains(now))
              .map((cue) => cue.text)
              .join('\n'),
        ),
      );
    }
    if (_pending != null) return;
    for (var next = index; next <= index + 2; next++) {
      if (_cache.containsKey(next)) continue;
      final start = window * next;
      final total = duration();
      if (total > Duration.zero && start >= total) return;
      final end = total > Duration.zero && start + window > total
          ? total
          : start + window;
      _pending = _process(next, start, end, _generation);
      return;
    }
  }

  Future<void> _process(
    int index,
    Duration start,
    Duration end,
    int generation,
  ) async {
    try {
      final cues = await process(start, end);
      if (_disposed || generation != _generation) return;
      _cache[index] = cues;
      // Session-local text only, bounded to roughly three minutes.
      if (_cache.length > 32) _cache.remove(_cache.keys.first);
    } on Object catch (_) {
      if (_disposed || generation != _generation) return;
      _failed = true;
      _emit(const CaptionFrame(CaptionStatus.failed));
    } finally {
      _pending = null;
    }
  }

  Future<void> close() async {
    _disposed = true;
    _timer?.cancel();
    cancelDecode();
    await _pending;
    _cache.clear();
  }
}
