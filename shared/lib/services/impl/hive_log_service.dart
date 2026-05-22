import 'dart:async';

import '../../models/session_log.dart';
import '../../storage/hive_store.dart';
import '../log_service.dart';

class HiveLogService implements LogService {
  HiveLogService();

  static const _logsKey = 'session_logs';
  final _updates = StreamController<void>.broadcast();

  List<SessionLog> _readAll() {
    final raw = HiveStore.cache.get(_logsKey);
    if (raw is! List) return [];
    return raw
        .map((e) => SessionLog.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writeAll(List<SessionLog> logs) async {
    await HiveStore.cache.put(_logsKey, logs.map((l) => l.toJson()).toList());
    _updates.add(null);
  }

  List<SessionLog> _filter({String? memberId, String? trainerId}) {
    return _readAll().where((log) {
      if (memberId != null && log.memberId != memberId) return false;
      if (trainerId != null && log.trainerId != trainerId) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Stream<List<SessionLog>> watchLogs({String? memberId, String? trainerId}) async* {
    yield _filter(memberId: memberId, trainerId: trainerId);
    await for (final _ in _updates.stream) {
      yield _filter(memberId: memberId, trainerId: trainerId);
    }
  }

  @override
  Future<void> saveLog(SessionLog log) async {
    final logs = _readAll();
    logs.removeWhere((l) => l.id == log.id);
    logs.insert(0, log);
    await _writeAll(logs);
  }

  @override
  Future<List<SessionLog>> listLogs({
    String? memberId,
    String? trainerId,
    DateTime? since,
  }) async {
    var logs = _filter(memberId: memberId, trainerId: trainerId);
    if (since != null) {
      logs = logs.where((l) => l.startedAt.isAfter(since)).toList();
    }
    return logs;
  }
}
