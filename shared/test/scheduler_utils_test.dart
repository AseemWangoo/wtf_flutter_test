import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('isValidScheduleSlot', () {
    test('rejects past times', () {
      final now = DateTime(2026, 5, 22, 12, 0);
      expect(
        isValidScheduleSlot(DateTime(2026, 5, 22, 11, 0), now: now),
        isFalse,
      );
    });

    test('accepts future times', () {
      final now = DateTime(2026, 5, 22, 12, 0);
      expect(
        isValidScheduleSlot(DateTime(2026, 5, 22, 18, 0), now: now),
        isTrue,
      );
    });
  });

  group('sessionDurationSec', () {
    test('calculates seconds between start and end', () {
      final start = DateTime(2026, 5, 22, 10, 0);
      final end = DateTime(2026, 5, 22, 10, 30);
      expect(sessionDurationSec(start, end), 1800);
    });
  });

  group('hasScheduleConflict', () {
    test('detects overlapping 30-min block', () {
      final candidate = DateTime(2026, 5, 22, 18, 0);
      final approved = [DateTime(2026, 5, 22, 18, 15)];
      expect(hasScheduleConflict(candidate, approved), isTrue);
    });
  });
}
