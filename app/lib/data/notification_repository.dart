import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> createInAppNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    final ref = _db.collection('notifications').doc();
    await ref.set(<String, dynamic>{
      'notificationId': ref.id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload ?? <String, dynamic>{},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> watchNotificationsForUser(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
              .toList()
            ..sort((a, b) {
              final aTs = a['createdAt'];
              final bTs = b['createdAt'];
              if (aTs is! Timestamp && bTs is! Timestamp) return 0;
              if (aTs is! Timestamp) return 1;
              if (bTs is! Timestamp) return -1;
              return bTs.compareTo(aTs);
            }),
        );
  }

  Future<void> markRead({
    required String notificationId,
  }) async {
    await _db.collection('notifications').doc(notificationId).set(
      <String, dynamic>{
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
