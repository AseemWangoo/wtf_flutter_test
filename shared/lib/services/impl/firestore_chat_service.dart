import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../data/constants.dart';
import '../../firebase/app_bootstrap.dart';
import '../../models/message.dart';
import '../chat_service.dart';

class FirestoreChatService implements ChatService {
  FirestoreChatService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages(String chatId) => _db
      .collection(AppConstants.firestoreChats)
      .doc(chatId)
      .collection(AppConstants.firestoreMessages);

  CollectionReference<Map<String, dynamic>> _typing(String chatId) => _db
      .collection(AppConstants.firestoreChats)
      .doc(chatId)
      .collection('typing');

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    if (!AppBootstrap.firebaseReady) {
      return Stream.value(const []);
    }
    return _messages(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> sendMessage(Message message) async {
    if (!AppBootstrap.firebaseReady) {
      debugPrint('[CHAT] Firebase offline — message not synced');
      return;
    }
    debugPrint('[CHAT] send ${message.id}');
    await _messages(message.chatId).doc(message.id).set(message.toJson());
  }

  @override
  Future<void> markRead(String chatId, String readerId) async {
    if (!AppBootstrap.firebaseReady) return;
    debugPrint('[CHAT] markRead chat=$chatId reader=$readerId');
    final snap = await _messages(chatId)
        .where('receiverId', isEqualTo: readerId)
        .where('status', whereIn: [
          MessageStatus.sent.name,
          MessageStatus.sending.name,
        ])
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'status': MessageStatus.read.name});
    }
    await batch.commit();
  }

  @override
  Future<List<Message>> loadHistory(String chatId, {int limit = 50}) async {
    if (!AppBootstrap.firebaseReady) return [];
    debugPrint('[CHAT] loadHistory chat=$chatId limit=$limit');
    final snap = await _messages(chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList().reversed.toList();
  }

  @override
  Stream<Set<String>> watchTypingUserIds(String chatId) {
    if (!AppBootstrap.firebaseReady) {
      return Stream.value({});
    }
    return _typing(chatId).snapshots().map((snap) {
      final now = DateTime.now();
      final active = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['active'] != true) continue;
        final at = data['at'] as String?;
        if (at != null) {
          final ts = DateTime.tryParse(at);
          if (ts != null && now.difference(ts).inSeconds > 8) continue;
        }
        active.add(doc.id);
      }
      return active;
    });
  }

  @override
  Future<void> setTyping(String chatId, String userId, {required bool active}) async {
    if (!AppBootstrap.firebaseReady) return;
    debugPrint('[CHAT] typing user=$userId active=$active');
    if (active) {
      await _typing(chatId).doc(userId).set({
        'active': true,
        'at': DateTime.now().toIso8601String(),
      });
    } else {
      await _typing(chatId).doc(userId).delete();
    }
  }

  Message _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return Message.fromJson(data);
  }
}
