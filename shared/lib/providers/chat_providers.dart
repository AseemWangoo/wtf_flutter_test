import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/constants.dart';
import '../models/chat_thread.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../utils/chat_helpers.dart';
import 'service_providers.dart';

final _uuid = const Uuid();
final _random = Random();

/// Live messages for a chat room.
final messagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, chatId) => ref.watch(chatServiceProvider).watchMessages(chatId),
);

/// Active typers in a chat (user ids).
final typingUsersProvider = StreamProvider.family<Set<String>, String>(
  (ref, chatId) => ref.watch(chatServiceProvider).watchTypingUserIds(chatId),
);

/// Chat list rows with preview + unread for the signed-in user.
final chatThreadsProvider = Provider.family<List<ChatThread>, User>((ref, user) {
  final base = chatThreadsForUser(user);
  return base.map((thread) {
    final messages = ref.watch(messagesProvider(thread.chatId)).valueOrNull ?? [];
    return thread.copyWith(
      lastMessage: latestMessage(messages),
      unreadCount: unreadCountFor(messages, user.id),
    );
  }).toList();
});

/// Sends a message with typing simulation (400–800ms) before delivery.
final sendMessageProvider = Provider.family<Future<void> Function(String text), SendMessageArgs>(
  (ref, args) {
    final chat = ref.read(chatServiceProvider);
    return (String text) async {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return;

      final messageId = _uuid.v4();
      await chat.setTyping(args.chatId, args.senderId, active: true);

      final delayMs = 400 + _random.nextInt(401);
      await Future<void>.delayed(Duration(milliseconds: delayMs));

      final message = Message(
        id: messageId,
        chatId: args.chatId,
        senderId: args.senderId,
        receiverId: args.receiverId,
        text: trimmed,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
      );

      await chat.sendMessage(message);
      await chat.sendMessage(
        message.copyWithStatus(MessageStatus.sent),
      );
      await chat.setTyping(args.chatId, args.senderId, active: false);
    };
  },
);

class SendMessageArgs {
  const SendMessageArgs({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
  });

  final String chatId;
  final String senderId;
  final String receiverId;

  @override
  bool operator ==(Object other) =>
      other is SendMessageArgs &&
      chatId == other.chatId &&
      senderId == other.senderId &&
      receiverId == other.receiverId;

  @override
  int get hashCode => Object.hash(chatId, senderId, receiverId);
}

extension MessageCopy on Message {
  Message copyWithStatus(MessageStatus status) => Message(
        id: id,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        createdAt: createdAt,
        status: status,
      );
}

/// Default DK ↔ Aarav conversation args.
SendMessageArgs sendArgsFor(User current, User peer) => SendMessageArgs(
      chatId: AppConstants.dkAaravChatId,
      senderId: current.id,
      receiverId: peer.id,
    );
