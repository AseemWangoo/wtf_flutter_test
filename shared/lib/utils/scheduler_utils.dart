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

/// Formats duration for session logs.
int sessionDurationSec(DateTime startedAt, DateTime endedAt) {
  return endedAt.difference(startedAt).inSeconds;
}
