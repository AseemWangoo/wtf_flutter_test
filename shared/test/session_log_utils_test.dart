import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  final now = DateTime.utc(2026, 5, 22, 12);

  SessionLog log({
    required DateTime startedAt,
    int durationSec = 600,
  }) {
    return SessionLog(
      id: 'log-1',
      memberId: AppConstants.dkUserId,
      trainerId: AppConstants.aaravUserId,
      startedAt: startedAt,
      endedAt: startedAt.add(Duration(seconds: durationSec)),
      durationSec: durationSec,
      rating: 4,
    );
  }

  test('sinceForSessionFilter returns null for all', () {
    expect(sinceForSessionFilter(SessionLogFilter.all, now: now), isNull);
  });

  test('sinceForSessionFilter last7Days is seven days ago', () {
    final since = sinceForSessionFilter(SessionLogFilter.last7Days, now: now)!;
    expect(now.difference(since).inDays, 7);
  });

  test('sinceForSessionFilter thisMonth is first of month', () {
    final since = sinceForSessionFilter(SessionLogFilter.thisMonth, now: now)!;
    expect(since.year, 2026);
    expect(since.month, 5);
    expect(since.day, 1);
  });

  test('filterSessionLogs keeps logs within range', () {
    final logs = [
      log(startedAt: DateTime.utc(2026, 5, 10)),
      log(startedAt: DateTime.utc(2026, 5, 20)),
    ];
    final filtered = filterSessionLogs(logs, SessionLogFilter.last7Days, now: now);
    expect(filtered, hasLength(1));
    expect(filtered.first.startedAt, DateTime.utc(2026, 5, 20));
  });

  test('formatSessionDuration renders minutes and seconds', () {
    expect(formatSessionDuration(45), '45s');
    expect(formatSessionDuration(125), '2m 5s');
    expect(formatSessionDuration(120), '2m');
  });

  test('peerNameForSessionLog resolves seed personas', () {
    final entry = log(startedAt: now);
    expect(
      peerNameForSessionLog(entry, UserRole.member),
      SeedData.aarav.name,
    );
    expect(
      peerNameForSessionLog(entry, UserRole.trainer),
      SeedData.dkTemplate.name,
    );
  });
}
