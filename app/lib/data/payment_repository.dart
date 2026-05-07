import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRepository {
  PaymentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String> createPaymentIntent({
    required String userId,
    required String requestId,
    required String module,
    required int amountTry,
  }) async {
    final ref = _db.collection('payments').doc();
    await ref.set(<String, dynamic>{
      'paymentId': ref.id,
      'userId': userId,
      'requestId': requestId,
      'module': module,
      'amountTry': amountTry,
      'currency': 'TRY',
      'provider': 'manual_stub',
      'status': 'pending',
      'checkoutUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return ref.id;
  }

  Stream<List<Map<String, dynamic>>> watchPaymentsForUser(String userId) {
    return _db
        .collection('payments')
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

  Future<void> markPaymentCompleted({
    required String paymentId,
    required String userId,
  }) async {
    final ref = _db.collection('payments').doc(paymentId);
    await ref.set(<String, dynamic>{
      'status': 'paid',
      'paidAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': userId,
    }, SetOptions(merge: true));
  }
}
