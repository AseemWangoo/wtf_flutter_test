import '../data/constants.dart';
import '../data/seed_data.dart';
import '../models/chat_thread.dart';
import '../models/message.dart';
import '../models/user.dart';

/// Fixed threads for assessment personas (DK ↔ Aarav).
List<ChatThread> chatThreadsForUser(User currentUser) {
  if (currentUser.role == UserRole.member) {
    return [
      const ChatThread(
        chatId: AppConstants.dkAaravChatId,
        peer: SeedData.aarav,
      ),
    ];
  }
  return [
    ChatThread(
      chatId: AppConstants.dkAaravChatId,
      peer: SeedData.dkTemplate,
    ),
  ];
}

int unreadCountFor(List<Message> messages, String readerId) {
  return messages
      .where(
        (m) =>
            m.receiverId == readerId &&
            m.status != MessageStatus.read,
      )
      .length;
}

Message? latestMessage(List<Message> messages) {
  if (messages.isEmpty) return null;
  return messages.reduce(
    (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
  );
}
