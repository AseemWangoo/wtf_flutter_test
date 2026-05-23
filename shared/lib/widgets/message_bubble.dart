import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import 'message_status_icon.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.bubbleColor,
  });

  final Message message;
  final bool isMine;
  final Color bubbleColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.92 + (0.08 * value),
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          margin: EdgeInsets.only(
            left: isMine ? 48 : 16,
            right: isMine ? 16 : 48,
            top: 4,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              if (isMine) ...[
                const SizedBox(height: 4),
                MessageStatusIcon(status: message.status),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Color bubbleColorFor(UserRole role, {required bool isMine}) {
  if (!isMine) {
    return role == UserRole.member ? AppColors.memberBubble : AppColors.trainerBubble;
  }
  return role == UserRole.member ? AppColors.memberBubble : AppColors.trainerBubble;
}
