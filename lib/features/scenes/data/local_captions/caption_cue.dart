/// A generated phrase in the original media time base, independent of playback speed.
class CaptionCue {
  const CaptionCue(this.start, this.end, this.text, {this.language});
  final String? language;
  final Duration start, end;
  final String text;
  bool contains(Duration position) => start <= position && position < end;
}

/// Groups timestamped subwords into readable phrases. Half-open window ownership
/// discards overlap tokens so adjacent windows never own the same timestamp.
List<CaptionCue> captionCuesFromTokens({
  required List<String> tokens,
  required List<double> timestamps,
  required Duration audioStart,
  required Duration windowStart,
  required Duration windowEnd,
  String? language,
}) {
  final cues = <CaptionCue>[];
  var words = <String>[];
  Duration? start;
  var last = Duration.zero;
  void flush() {
    final text = words.join().replaceAll('▁', ' ').trim();
    if (start != null && text.isNotEmpty) {
      final end = last + const Duration(milliseconds: 600);
      cues.add(
        CaptionCue(
          start!,
          end < windowEnd ? end : windowEnd,
          text,
          language: language,
        ),
      );
    }
    words = [];
    start = null;
  }

  for (var i = 0; i < tokens.length && i < timestamps.length; i++) {
    if (!timestamps[i].isFinite || timestamps[i] < 0) continue;
    final time =
        audioStart + Duration(microseconds: (timestamps[i] * 1000000).round());
    if (time < windowStart || time >= windowEnd || tokens[i].startsWith('<')) {
      continue;
    }
    if (start != null &&
        (time - start! >= const Duration(seconds: 4) ||
            time - last > const Duration(milliseconds: 900))) {
      flush();
    }
    start ??= time;
    last = time;
    words.add(tokens[i]);
  }
  flush();
  return cues;
}
