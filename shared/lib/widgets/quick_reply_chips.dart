import 'package:flutter/material.dart';

class QuickReplyChips extends StatelessWidget {
  const QuickReplyChips({
    super.key,
    required this.onSelected,
    this.replies = const [
      'Got it 👍',
      'Can we talk at 6?',
      'Share plan?',
    ],
  });

  final ValueChanged<String> onSelected;
  final List<String> replies;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = replies[index];
          return ActionChip(
            label: Text(text),
            onPressed: () => onSelected(text),
          );
        },
      ),
    );
  }
}
