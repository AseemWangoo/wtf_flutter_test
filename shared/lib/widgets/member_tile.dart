import 'package:flutter/material.dart';

import '../models/member_summary.dart';
import '../utils/app_colors.dart';
import '../utils/scheduler_utils.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.summary,
    required this.primary,
    required this.onMessage,
    this.onSchedule,
  });

  final MemberSummary summary;
  final Color primary;
  final VoidCallback onMessage;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    final member = summary.member;
    final next = summary.nextApprovedCall;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: TextStyle(color: primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        member.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  icon: Icons.history,
                  label: '${summary.sessionCount} sessions',
                ),
                if (summary.lastSessionAt != null)
                  _Chip(
                    icon: Icons.access_time,
                    label: 'Last ${formatRelativeSession(summary.lastSessionAt!)}',
                  ),
              ],
            ),
            if (next != null) ...[
              const SizedBox(height: 8),
              Text(
                'Next call: ${formatScheduleDateTime(next.scheduledFor)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primary),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: const Text('Message'),
                  ),
                ),
                if (onSchedule != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.video_call_outlined, size: 18),
                      label: const Text('Requests'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String formatRelativeSession(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  return '${diff.inMinutes}m ago';
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral700),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
