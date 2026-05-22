import '../models/session_log.dart';

/// Session logs after video calls.
abstract class LogService {
  Stream<List<SessionLog>> watchLogs({String? memberId, String? trainerId});
  Future<void> saveLog(SessionLog log);
  Future<List<SessionLog>> listLogs({
    String? memberId,
    String? trainerId,
    DateTime? since,
  });
}
