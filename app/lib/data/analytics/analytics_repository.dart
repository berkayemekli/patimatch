import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsRepository {
  AnalyticsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> trackEvent({
    required String userId,
    required String eventName,
    required String module,
    String entityType = '',
    String entityId = '',
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) async {
    if (userId.isEmpty || eventName.isEmpty || module.isEmpty) return;
    final ref = _db.collection('analytics_events').doc();
    await ref.set({
      'eventId': ref.id,
      'userId': userId,
      'eventName': eventName,
      'module': module,
      'entityType': entityType,
      'entityId': entityId,
      'properties': properties,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
