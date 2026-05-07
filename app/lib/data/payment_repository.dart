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
}
