import 'dart:collection';

import 'package:flutter/foundation.dart';

class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.message,
    this.source = 'app',
  });

  final DateTime timestamp;
  final String message;
  final String source;

  String get formattedTimestamp {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

class AppLogStore {
  AppLogStore._();

  static final AppLogStore instance = AppLogStore._();
  static const int _maxEntries = 1200;

  final List<AppLogEntry> _entries = <AppLogEntry>[];
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  UnmodifiableListView<AppLogEntry> get entries =>
      UnmodifiableListView<AppLogEntry>(_entries);

  void add(String message, {String source = 'app'}) {
    if (message.trim().isEmpty) return;
    _entries.add(
      AppLogEntry(timestamp: DateTime.now(), message: message, source: source),
    );
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    revision.value++;
  }

  void clear() {
    _entries.clear();
    revision.value++;
  }
}
