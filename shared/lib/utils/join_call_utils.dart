import '../config/rtc_config.dart';
import '../models/call_request.dart';
import '../models/user.dart';

/// Join window: 10 min before scheduled time (or demo mode for assessment).
bool canJoinCall(CallRequest request, {DateTime? now}) {
  if (request.status != CallRequestStatus.approved) return false;
  final reference = now ?? DateTime.now();

  if (RtcConfig.demoJoin) {
    return reference.isBefore(request.scheduledFor.add(const Duration(hours: 2)));
  }

  final windowStart = request.scheduledFor.subtract(const Duration(minutes: 10));
  final windowEnd = request.scheduledFor.add(const Duration(minutes: 30));
  return !reference.isBefore(windowStart) && reference.isBefore(windowEnd);
}

/// Maps app user role to token server query param.
String hmsRoleParamFor(UserRole role) =>
    role == UserRole.trainer ? 'trainer' : 'member';
