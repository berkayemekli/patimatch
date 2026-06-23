import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceEngagementRepository {
  ServiceEngagementRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String> acceptRequestAndCreateConversation({
    required DocumentReference<Map<String, dynamic>> requestReference,
    required String requestId,
    required String module,
    required String requesterUserId,
    required String providerUserId,
    required String title,
  }) async {
    final engagementId = '${module}_$requestId';
    final chatId = 'service_$engagementId';
    final engagementRef = _db
        .collection('service_engagements')
        .doc(engagementId);
    final chatRef = _db.collection('chats').doc(chatId);
    final firstMessageRef = chatRef.collection('messages').doc();

    await _db.runTransaction((transaction) async {
      transaction.update(requestReference, {
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(engagementRef, {
        'engagementId': engagementId,
        'requestId': requestId,
        'requestCollection': requestReference.parent.id,
        'module': module,
        'requesterUserId': requesterUserId,
        'providerUserId': providerUserId,
        'participantUserIds': [requesterUserId, providerUserId],
        'chatId': chatId,
        'title': title,
        'status': 'accepted',
        'stage': 'conversation',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(chatRef, {
        'chatId': chatId,
        'conversationType': 'service',
        'serviceEngagementId': engagementId,
        'serviceModule': module,
        'participantOwnerIds': [requesterUserId, providerUserId],
        'participantUserIds': [requesterUserId, providerUserId],
        'title': title,
        'status': 'active',
        'lastMessage': 'Talep kabul edildi. Detayları burada konuşabilirsiniz.',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(firstMessageRef, {
        'messageId': firstMessageRef.id,
        'chatId': chatId,
        'senderUserId': providerUserId,
        'text': 'Talep kabul edildi. Detayları burada konuşabiliriz.',
        'messageType': 'system_welcome',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
    });
    return chatId;
  }

  Future<void> updateStage({
    required String engagementId,
    required String stage,
  }) {
    return _db.collection('service_engagements').doc(engagementId).update({
      'stage': stage,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
