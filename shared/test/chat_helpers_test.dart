import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  test('unreadCountFor counts non-read inbound messages', () {
    final messages = [
      Message(
        id: '1',
        chatId: AppConstants.dkAaravChatId,
        senderId: AppConstants.aaravUserId,
        receiverId: AppConstants.dkUserId,
        text: 'Hi',
        createdAt: DateTime.utc(2026, 5, 22, 10),
        status: MessageStatus.sent,
      ),
      Message(
        id: '2',
        chatId: AppConstants.dkAaravChatId,
        senderId: AppConstants.dkUserId,
        receiverId: AppConstants.aaravUserId,
        text: 'Hey',
        createdAt: DateTime.utc(2026, 5, 22, 11),
        status: MessageStatus.read,
      ),
    ];

    expect(unreadCountFor(messages, AppConstants.dkUserId), 1);
    expect(unreadCountFor(messages, AppConstants.aaravUserId), 0);
  });

  test('formatRelativeTime shows minutes ago', () {
    final now = DateTime(2026, 5, 22, 12, 10);
    final msg = DateTime(2026, 5, 22, 12, 5);
    expect(formatRelativeTime(msg, now: now), '5m ago');
  });
}
