import 'package:flutter/material.dart';

import '../models/message.dart';
import '../utils/app_colors.dart';

class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({
    super.key,
    required this.status,
    this.color = Colors.white70,
  });

  final MessageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: color,
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 16, color: color);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 16, color: AppColors.success);
    }
  }
}
