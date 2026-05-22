import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  test('Message serializes and deserializes', () {
    final original = Message(
      id: 'm1',
      chatId: 'chat-dk-aarav',
      senderId: 'dk',
      receiverId: 'aarav',
      text: 'Hi Coach 👋',
      createdAt: DateTime.utc(2026, 5, 22, 10, 0),
      status: MessageStatus.sent,
    );

    final restored = Message.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.text, original.text);
    expect(restored.status, MessageStatus.sent);
  });
}
