import 'package:flutter/material.dart';

import '../models/chat_thread.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import '../utils/relative_time.dart';

class ChatListTileWidget extends StatelessWidget {
  const ChatListTileWidget({
    super.key,
    required this.thread,
    required this.onTap,
  });

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = thread.lastMessage?.text ?? 'No messages yet';
    final time = thread.lastMessage != null
        ? formatRelativeTime(thread.lastMessage!.createdAt)
        : '';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: thread.peer.role == UserRole.trainer
            ? AppColors.trainerPrimary.withValues(alpha: 0.15)
            : AppColors.guruPrimary.withValues(alpha: 0.15),
        child: Text(
          thread.peer.name.isNotEmpty ? thread.peer.name[0] : '?',
          style: TextStyle(
            color: thread.peer.role == UserRole.trainer
                ? AppColors.trainerPrimary
                : AppColors.guruPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(thread.peer.name),
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (time.isNotEmpty)
            Text(time, style: Theme.of(context).textTheme.labelSmall),
          if (thread.unreadCount > 0) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.error,
              child: Text(
                '${thread.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
