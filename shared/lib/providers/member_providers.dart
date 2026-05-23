import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/constants.dart';
import '../data/seed_data.dart';
import '../models/call_request.dart';
import '../models/member_summary.dart';
import '../models/user.dart';
import 'call_providers.dart';
import 'log_providers.dart';

/// Members assigned to a trainer (assessment seed: DK → Aarav).
final assignedMembersProvider = Provider.family<List<User>, String>((ref, trainerId) {
  if (trainerId == AppConstants.aaravUserId) {
    return [SeedData.dkTemplate];
  }
  return const [];
});

final memberSummariesProvider = Provider.family<List<MemberSummary>, User>(
  (ref, trainer) {
    final members = ref.watch(assignedMembersProvider(trainer.id));
    final logs = ref.watch(sessionLogsProvider(trainer)).valueOrNull ?? [];
    final requests = ref.watch(trainerRequestsProvider(trainer.id)).valueOrNull ?? [];
    final now = DateTime.now();

    return members.map((member) {
      final memberLogs = logs.where((l) => l.memberId == member.id).toList();
      final upcoming = requests
          .where(
            (r) =>
                r.memberId == member.id &&
                r.status == CallRequestStatus.approved &&
                r.scheduledFor.isAfter(now.subtract(const Duration(minutes: 30))),
          )
          .toList()
        ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));

      return MemberSummary(
        member: member,
        sessionCount: memberLogs.length,
        lastSessionAt: memberLogs.isEmpty ? null : memberLogs.first.startedAt,
        nextApprovedCall: upcoming.isEmpty ? null : upcoming.first,
      );
    }).toList();
  },
);
