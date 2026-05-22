import '../models/message.dart';

/// Real-time chat between member and trainer.
abstract class ChatService {
  Stream<List<Message>> watchMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<void> markRead(String chatId, String readerId);
  Future<List<Message>> loadHistory(String chatId, {int limit = 50});
}
