import '../data/seed_data.dart';
import '../models/session_log.dart';
import '../models/user.dart';

enum SessionLogFilter { all, last7Days, thisMonth }

/// Start of range for [filter], or null for all time.
DateTime? sinceForSessionFilter(SessionLogFilter filter, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  switch (filter) {
    case SessionLogFilter.all:
      return null;
    case SessionLogFilter.last7Days:
      return reference.subtract(const Duration(days: 7));
    case SessionLogFilter.thisMonth:
      return DateTime(reference.year, reference.month, 1);
  }
}

List<SessionLog> filterSessionLogs(
  List<SessionLog> logs,
  SessionLogFilter filter, {
  DateTime? now,
}) {
  final since = sinceForSessionFilter(filter, now: now);
  if (since == null) return logs;
  return logs.where((log) => !log.startedAt.isBefore(since)).toList();
}

String formatSessionDuration(int durationSec) {
  if (durationSec < 60) return '${durationSec}s';
  final minutes = durationSec ~/ 60;
  final seconds = durationSec % 60;
  if (seconds == 0) return '${minutes}m';
  return '${minutes}m ${seconds}s';
}

String formatSessionDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  final time = minute == '00' ? '$hour:00 $period' : '$hour:$minute $period';
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $time';
}

String peerNameForSessionLog(SessionLog log, UserRole viewerRole) {
  if (viewerRole == UserRole.member) {
    return log.trainerId == SeedData.aarav.id ? SeedData.aarav.name : 'Trainer';
  }
  return log.memberId == SeedData.dkTemplate.id ? SeedData.dkTemplate.name : 'Member';
}

String sessionLogFilterLabel(SessionLogFilter filter) {
  switch (filter) {
    case SessionLogFilter.all:
      return 'All';
    case SessionLogFilter.last7Days:
      return '7 days';
    case SessionLogFilter.thisMonth:
      return 'Month';
  }
}
