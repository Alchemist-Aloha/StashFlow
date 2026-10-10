import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';

void main() {
  group('AppLogStore error logging', () {
    final logger = AppLogStore.instance;

    setUp(() {
      logger
        ..clear()
        ..isEnabled = true;
    });
    tearDown(() {
      logger
        ..isEnabled = false
        ..clear();
    });

    test(
      'records operation, type, source, and original stack without secrets',
      () {
        final revision = logger.revision.value;
        final error = StateError('password=super-secret-value');
        final stack = StackTrace.fromString('original failure location');

        logger.addError(
          'Restore configuration',
          error,
          stack,
          source: 'config',
        );

        final entry = logger.entries.single;
        expect(entry.source, 'config');
        expect(
          entry.message,
          contains('Restore configuration failed (StateError)'),
        );
        expect(entry.message, contains('original failure location'));
        expect(entry.message, isNot(contains('super-secret-value')));
        expect(logger.revision.value, revision + 1);
      },
    );

    test('does not record errors when logging is disabled', () {
      logger.isEnabled = false;
      final revision = logger.revision.value;

      logger.addError('Login', Exception('secret'), StackTrace.current);

      expect(logger.entries, isEmpty);
      expect(logger.revision.value, revision);
    });
  });

  group('AppLogEntry', () {
    test('instantiates correctly with all fields', () {
      final timestamp = DateTime(2023, 10, 27, 14, 30, 45, 123);
      final entry = AppLogEntry(
        timestamp: timestamp,
        message: 'Test message',
        source: 'custom_source',
      );

      expect(entry.timestamp, timestamp);
      expect(entry.message, 'Test message');
      expect(entry.source, 'custom_source');
    });

    test('uses default source "app" when not provided', () {
      final entry = AppLogEntry(
        timestamp: DateTime.now(),
        message: 'Default source test',
      );

      expect(entry.source, 'app');
    });

    test('formattedTimestamp pads correctly', () {
      // 0 hours, 5 mins, 9 seconds, 7 ms
      final timestamp = DateTime(2023, 1, 1, 0, 5, 9, 7);
      final entry = AppLogEntry(timestamp: timestamp, message: 'Padding test');

      // '00:05:09.007'
      expect(entry.formattedTimestamp, '00:05:09.007');
    });

    test('formattedTimestamp formats normal times correctly', () {
      // 14 hours, 30 mins, 45 seconds, 123 ms
      final timestamp = DateTime(2023, 1, 1, 14, 30, 45, 123);
      final entry = AppLogEntry(
        timestamp: timestamp,
        message: 'Normal time test',
      );

      expect(entry.formattedTimestamp, '14:30:45.123');
    });
  });
}
