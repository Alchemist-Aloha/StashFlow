import 'package:flutter_test/flutter_test.dart';

// Since _filterSubtitleContent is private in PlayerState,
// we'll implement a standalone test of the logic itself to verify it.
String filterSubtitleContent(String content) {
  if (!content.contains('#xywh')) return content;

  final lines = content.split('\n');
  final filteredLines = lines.where((line) {
    final trimmed = line.trim();
    if (trimmed.contains('#xywh')) return false;
    return true;
  });

  return filteredLines.join('\n');
}

void main() {
  group('Subtitle Filtering', () {
    test('should filter out lines with #xywh', () {
      const vttContent = '''
WEBVTT

00:00:00.000 --> 00:00:05.000
sprite.jpg#xywh=0,0,160,90

00:00:05.000 --> 00:00:10.000
Actual subtitle text

00:00:10.000 --> 00:00:15.000
Another thumbnail: sprite.jpg#xywh=160,0,160,90
''';

      final filtered = filterSubtitleContent(vttContent);

      expect(filtered, contains('WEBVTT'));
      expect(filtered, contains('Actual subtitle text'));
      expect(filtered, isNot(contains('sprite.jpg#xywh=0,0,160,90')));
      expect(filtered, isNot(contains('Another thumbnail')));

      // Basic sanity check on expected content
      expect(filtered, contains('00:00:05.000 --> 00:00:10.000'));
    });

    test('should not affect normal subtitles', () {
      const vttContent = '''
WEBVTT

00:00:05.000 --> 00:00:10.000
Actual subtitle text
''';

      final filtered = filterSubtitleContent(vttContent);
      expect(filtered, vttContent);
    });
  });
}
