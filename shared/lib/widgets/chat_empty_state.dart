import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.onSayHi,
  });

  final VoidCallback onSayHi;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 72,
              color: AppColors.neutral700.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet. Start the conversation.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutral700,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onSayHi,
              child: const Text('Say hi'),
            ),
          ],
        ),
      ),
    );
  }
}
