import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../utils/app_colors.dart';
import '../utils/join_call_utils.dart';
import '../utils/scheduler_utils.dart';

class CallRequestTile extends StatelessWidget {
  const CallRequestTile({
    super.key,
    required this.request,
    this.trainerName,
    this.memberName,
    this.showActions = false,
    this.onApprove,
    this.onDecline,
    this.onJoin,
  });

  final CallRequest request;
  final String? trainerName;
  final String? memberName;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onJoin;

  Color _statusColor(CallRequestStatus status) {
    switch (status) {
      case CallRequestStatus.pending:
        return AppColors.warning;
      case CallRequestStatus.approved:
        return AppColors.success;
      case CallRequestStatus.declined:
        return AppColors.error;
      case CallRequestStatus.cancelled:
        return AppColors.neutral700;
    }
  }

  String _statusLabel() {
    switch (request.status) {
      case CallRequestStatus.pending:
        return ScheduleCopy.pendingTrainer(trainerName ?? 'trainer');
      case CallRequestStatus.approved:
        return ScheduleCopy.approved(request.scheduledFor);
      case CallRequestStatus.declined:
        return ScheduleCopy.declined(request.declineReason ?? 'No reason given');
      case CallRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatScheduleDateTime(request.scheduledFor),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(request.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status.name,
                    style: TextStyle(
                      color: _statusColor(request.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (memberName != null) ...[
              const SizedBox(height: 4),
              Text('Member: $memberName', style: Theme.of(context).textTheme.bodySmall),
            ],
            if (request.note != null && request.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '"${request.note}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.neutral700,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _statusLabel(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral700,
                  ),
            ),
            if (onJoin != null &&
                request.status == CallRequestStatus.approved &&
                canJoinCall(request)) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onJoin,
                icon: const Icon(Icons.videocam),
                label: const Text('Join Call'),
              ),
            ],
            if (showActions && request.status == CallRequestStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: onApprove,
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
