import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/format_duration.dart';

void main() {
  test('formats minutes and hours as clock time', () {
    expect(formatClockDuration(0), '00:00');
    expect(formatClockDuration(65.9), '01:05');
    expect(formatClockDuration(3725), '1:02:05');
  });
}
