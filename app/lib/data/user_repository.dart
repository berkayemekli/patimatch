import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<Set<String>> fetchBlockedOwnerIds(String userId) async {
    final snap =
        await _db.collection('blocks').where('userId', isEqualTo: userId).get();
    return snap.docs
        .map((d) => d.data()['blockedUserId'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> fetchMyDogDoc(
    String ownerId,
  ) async {
    final q = await _db
        .collection('dogs')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first;
  }
}
