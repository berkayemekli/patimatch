import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepository {
  BookingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<bool> hasWalkConflict({
    required String walkerId,
    required DateTime preferredAt,
  }) async {
    final start = Timestamp.fromDate(preferredAt.subtract(const Duration(minutes: 59)));
    final end = Timestamp.fromDate(preferredAt.add(const Duration(minutes: 59)));
    final snap = await _db
        .collection('walk_requests')
        .where('walkerId', isEqualTo: walkerId)
        .where('status', whereIn: <String>['pending', 'accepted'])
        .where('preferredAt', isGreaterThanOrEqualTo: start)
        .where('preferredAt', isLessThanOrEqualTo: end)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> hasBnbConflict({
    required String hostId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final start = Timestamp.fromDate(checkIn);
    final end = Timestamp.fromDate(checkOut);
    final snap = await _db
        .collection('bnb_requests')
        .where('hostId', isEqualTo: hostId)
        .where('status', whereIn: <String>['pending', 'accepted'])
        .where('checkIn', isLessThanOrEqualTo: end)
        .where('checkOut', isGreaterThanOrEqualTo: start)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
