import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleMembershipRepository {
  ModuleMembershipRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> syncMemberships({
    required String userId,
    required Map<String, Set<String>> moduleRoles,
  }) async {
    final batch = _firestore.batch();
    const knownRoles = <String>['customer', 'provider'];

    for (final entry in moduleRoles.entries) {
      for (final role in knownRoles) {
        final membershipId = '${userId}_${entry.key}_$role';
        final reference = _firestore
            .collection('module_memberships')
            .doc(membershipId);
        if (entry.value.contains(role)) {
          batch.set(reference, {
            'membershipId': membershipId,
            'userId': userId,
            'module': entry.key,
            'role': role,
            'status': 'active',
            'plan': 'standard',
            'source': 'role_selection',
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          batch.delete(reference);
        }
      }
    }
    await batch.commit();
  }
}
