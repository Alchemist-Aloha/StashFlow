import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Represents a single diagnostic log entry.
class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.message,
    this.source = 'app',
  });

  /// The exact time this log was recorded.
  final DateTime timestamp;

  /// The log message text.
  final String message;

  /// A tag identifying the component that generated the log.
  final String source;

  /// Returns the timestamp formatted as HH:mm:ss.SSS for UI display.
  String get formattedTimestamp {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

/// A central store for in-app diagnostic logs.
///
/// This store persists logs in memory during the app session, allowing
/// developers and users to inspect runtime behavior (like playback startup,
/// network requests, and state transitions) via a dedicated UI.
///
/// It uses a [ValueNotifier] called `revision` to notify listeners (like the
/// Debug Log Viewer) when the log list has changed.
class AppLogStore {
  AppLogStore._();

  /// The singleton instance of [AppLogStore].
  static final AppLogStore instance = AppLogStore._();

  /// Maximum number of log entries to keep in memory before discarding the oldest.
  static const int _maxEntries = 1200;

  final List<AppLogEntry> _entries = <AppLogEntry>[];

  /// Notifies listeners whenever a log is added or the store is cleared.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Returns an unmodifiable view of all recorded log entries.
  UnmodifiableListView<AppLogEntry> get entries =>
      UnmodifiableListView<AppLogEntry>(_entries);

  /// Adds a new log entry to the store.
  ///
  /// [message] is the log text.
  /// [source] is an optional tag identifying the component (e.g., 'player_provider').
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

  /// Clears all logs from the store.
  void clear() {
    _entries.clear();
    revision.value++;
  }
}
