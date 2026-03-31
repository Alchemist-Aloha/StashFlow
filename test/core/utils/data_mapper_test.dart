import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/data_mapper.dart';

void main() {
  group('DataMapper.formatDuration', () {
    test('formats null as 00:00', () {
      expect(DataMapper.formatDuration(null), '00:00');
    });

    test('formats seconds less than a minute', () {
      expect(DataMapper.formatDuration(45), '00:45');
    });

    test('formats minutes and seconds', () {
      expect(DataMapper.formatDuration(125), '02:05');
    });

    test('formats hours, minutes, and seconds', () {
      expect(DataMapper.formatDuration(3661), '1:01:01');
    });
  });
}
