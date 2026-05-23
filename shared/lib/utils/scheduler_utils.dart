import '../models/call_request.dart';

/// Validates call scheduling slots (assessment: no past times).
bool isValidScheduleSlot(DateTime scheduledFor, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  return scheduledFor.isAfter(reference);
}

/// Returns true if [candidate] overlaps an already approved slot (30-min blocks).
bool hasScheduleConflict(
  DateTime candidate,
  List<DateTime> approvedSlots, {
  Duration block = const Duration(minutes: 30),
}) {
  for (final slot in approvedSlots) {
    final diff = candidate.difference(slot).abs();
    if (diff < block) return true;
  }
  return false;
}

/// Next 3 calendar days starting today.
List<DateTime> nextThreeDays({DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  return List.generate(3, (i) => today.add(Duration(days: i)));
}

/// 30-minute slots from 08:00–20:00 for [day]; skips past slots on today.
List<DateTime> timeSlotsForDay(DateTime day, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final slots = <DateTime>[];
  for (var hour = 8; hour < 20; hour++) {
    for (final minute in [0, 30]) {
      final slot = DateTime(day.year, day.month, day.day, hour, minute);
      if (isValidScheduleSlot(slot, now: reference)) {
        slots.add(slot);
      }
    }
  }
  return slots;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Human-readable date for chips, e.g. "Today", "Tomorrow", "Sat 24 May".
String formatDayLabel(DateTime day, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final d = _dateOnly(day);
  if (d == today) return 'Today';
  if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
}

/// e.g. "6:00 PM" for assessment copy.
String formatScheduleTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return minute == '00' ? '$hour:00 $period' : '$hour:$minute $period';
}

String formatScheduleDate(DateTime dt) {
  return formatDayLabel(dt);
}

String formatScheduleDateTime(DateTime dt) => '${formatScheduleDate(dt)} ${formatScheduleTime(dt)}';

List<DateTime> approvedSlotsFrom(List<CallRequest> requests) => requests
    .where((r) => r.status == CallRequestStatus.approved)
    .map((r) => r.scheduledFor)
    .toList();

/// Formats duration for session logs.
int sessionDurationSec(DateTime startedAt, DateTime endedAt) {
  return endedAt.difference(startedAt).inSeconds;
}

/// Assessment UI copy.
abstract final class ScheduleCopy {
  static const requestSent = 'Call requested. Waiting for trainer approval.';
  static String approved(DateTime dt) =>
      'Call approved for ${formatScheduleDate(dt)} ${formatScheduleTime(dt)}.';
  static String declined(String reason) =>
      'Call request declined. Reason: $reason.';
  static String pendingTrainer(String trainerName) =>
      'Pending approval by $trainerName';
}
