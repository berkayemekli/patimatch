import 'package:cloud_firestore/cloud_firestore.dart';

class MatchesRepository {
  MatchesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMatchesForUser(String userId) {
    return _db
        .collection('matches')
        .where('ownerIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<Set<String>> fetchBlockedOwnerIds(String userId) async {
    final snap =
        await _db.collection('blocks').where('userId', isEqualTo: userId).get();
    return snap.docs
        .map((d) => d.data()['blockedUserId'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<Map<String, dynamic>?> fetchDog(String dogId) async {
    if (dogId.isEmpty) return null;
    final snap = await _db.collection('dogs').doc(dogId).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchChat(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots();
  }
}
