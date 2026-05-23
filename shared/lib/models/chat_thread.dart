import 'message.dart';
import 'user.dart';

/// Summary row for chat list (preview + unread).
class ChatThread {
  const ChatThread({
    required this.chatId,
    required this.peer,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String chatId;
  final User peer;
  final Message? lastMessage;
  final int unreadCount;

  ChatThread copyWith({
    Message? lastMessage,
    int? unreadCount,
  }) =>
      ChatThread(
        chatId: chatId,
        peer: peer,
        lastMessage: lastMessage ?? this.lastMessage,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}
