import 'dart:async';

import 'package:flutter/foundation.dart';

class DevLogEntry {
  const DevLogEntry({
    required this.tag,
    required this.message,
    required this.at,
  });

  final String tag;
  final String message;
  final DateTime at;

  String get line => '[$tag] $message';
}

/// In-memory ring buffer for DevPanel (last 20 structured log lines).
abstract final class DevLog {
  static const _maxEntries = 20;

  static final List<DevLogEntry> _entries = [];
  static final _updates = StreamController<void>.broadcast();

  static Stream<List<DevLogEntry>> watchEntries() async* {
    yield List.unmodifiable(_entries);
    await for (final _ in _updates.stream) {
      yield List.unmodifiable(_entries);
    }
  }

  static List<DevLogEntry> entries() => List.unmodifiable(_entries);

  static void log(String tag, String message) {
    debugPrint('[$tag] $message');
    _entries.insert(
      0,
      DevLogEntry(tag: tag, message: message, at: DateTime.now()),
    );
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    _updates.add(null);
  }

  static void clear() {
    _entries.clear();
    _updates.add(null);
  }
}
