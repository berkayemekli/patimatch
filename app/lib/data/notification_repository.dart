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
}
