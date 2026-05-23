import 'call_request.dart';
import 'user.dart';

/// Trainer CRM row for an assigned member.
class MemberSummary {
  const MemberSummary({
    required this.member,
    required this.sessionCount,
    this.lastSessionAt,
    this.nextApprovedCall,
  });

  final User member;
  final int sessionCount;
  final DateTime? lastSessionAt;
  final CallRequest? nextApprovedCall;
}
