import 'package:flutter/material.dart';

import '../models/session_log.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import '../utils/session_log_utils.dart';

class SessionLogTile extends StatelessWidget {
  const SessionLogTile({
    super.key,
    required this.log,
    required this.viewerRole,
    required this.primary,
  });

  final SessionLog log;
  final UserRole viewerRole;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final peer = peerNameForSessionLog(log, viewerRole);
    final notes = viewerRole == UserRole.member ? log.memberNotes : log.trainerNotes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: Icon(Icons.videocam_outlined, size: 20, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(peer, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        formatSessionDateTime(log.startedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral700,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatSessionDuration(log.durationSec),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primary),
                ),
              ],
            ),
            if (viewerRole == UserRole.member && log.rating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Rating',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(5, (i) {
                    final filled = i < log.rating!;
                    return Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 18,
                      color: filled ? AppColors.warning : AppColors.neutral700,
                    );
                  }),
                ],
              ),
            ],
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                notes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
