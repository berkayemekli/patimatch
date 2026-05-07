import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_payloads.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> blockUser({
    required String userId,
    required String blockedUserId,
    String reason = 'chat_action',
  }) async {
    final blockId = '${userId}_$blockedUserId';
    await _db.collection('blocks').doc(blockId).set(
          FirestorePayloads.block(
            blockId: blockId,
            userId: userId,
            blockedUserId: blockedUserId,
            reason: reason,
          ),
          SetOptions(merge: true),
        );
  }

  Future<void> markChatRead({
    required String chatId,
    required String userId,
  }) async {
    await _db.collection('chats').doc(chatId).set({
      'lastReadBy': {userId: FieldValue.serverTimestamp()},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderUserId,
    required String text,
  }) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'messageId': msgRef.id,
        'chatId': chatId,
        'senderUserId': senderUserId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
      tx.set(chatRef, {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderUserId': senderUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> reportMessage({
    required String reporterUserId,
    required String reportedUserId,
    required String chatId,
    required String messageId,
    required String reportedMessageText,
  }) async {
    final reportRef = _db.collection('reports').doc();
    await reportRef.set(
      FirestorePayloads.reportChatMessage(
        reportId: reportRef.id,
        reporterUserId: reporterUserId,
        reportedUserId: reportedUserId,
        chatId: chatId,
        messageId: messageId,
        reportedMessageText: reportedMessageText,
      ),
      SetOptions(merge: true),
    );
  }

  Future<void> softDeleteMessage({
    required String chatId,
    required String messageId,
    required String senderUserId,
  }) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc(messageId);
    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'isDeleted': true,
        'text': '[Bu mesaj silindi]',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      tx.set(chatRef, {
        'lastMessage': '[Bu mesaj silindi]',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderUserId': senderUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
