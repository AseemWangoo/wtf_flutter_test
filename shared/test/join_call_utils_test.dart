import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  test('canJoinCall allows approved requests in demo mode', () {
    final request = CallRequest(
      id: 'r1',
      memberId: AppConstants.dkUserId,
      trainerId: AppConstants.aaravUserId,
      requestedAt: DateTime.utc(2026, 5, 22, 10),
      scheduledFor: DateTime.utc(2026, 5, 22, 18),
      status: CallRequestStatus.approved,
    );
    expect(canJoinCall(request, now: DateTime.utc(2026, 5, 22, 12)), isTrue);
  });

  test('canJoinCall rejects pending requests', () {
    final request = CallRequest(
      id: 'r1',
      memberId: AppConstants.dkUserId,
      trainerId: AppConstants.aaravUserId,
      requestedAt: DateTime.utc(2026, 5, 22, 10),
      scheduledFor: DateTime.utc(2026, 5, 22, 18),
      status: CallRequestStatus.pending,
    );
    expect(canJoinCall(request), isFalse);
  });
}
