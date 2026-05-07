import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_payloads.dart';

class SwipeRepository {
  SwipeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<bool> writeSwipeAndMaybeCreateMatch({
    required String myDogId,
    required String myOwnerId,
    required String targetDogId,
    required String targetOwnerId,
    required bool liked,
  }) async {
    final swipeId = '${myDogId}_$targetDogId';
    final swipeRef = _db.collection('swipes').doc(swipeId);
    final reverseSwipeRef = _db.collection('swipes').doc('${targetDogId}_$myDogId');
    var didCreateMatch = false;

    await _db.runTransaction((tx) async {
      tx.set(
        swipeRef,
        FirestorePayloads.swipe(
          swipeId: swipeId,
          fromDogId: myDogId,
          fromOwnerId: myOwnerId,
          toDogId: targetDogId,
          toOwnerId: targetOwnerId,
          liked: liked,
        ),
        SetOptions(merge: true),
      );

      if (!liked) return;

      final reverseSnap = await tx.get(reverseSwipeRef);
      final reverseData = reverseSnap.data();
      final reverseLiked = reverseData != null && reverseData['liked'] == true;
      if (!reverseLiked) return;

      final sorted = <String>[myDogId, targetDogId]..sort();
      final matchId = '${sorted[0]}_${sorted[1]}';
      final matchRef = _db.collection('matches').doc(matchId);
      final chatRef = _db.collection('chats').doc(matchId);

      tx.set(
        matchRef,
        FirestorePayloads.match(
          matchId: matchId,
          dogIdsSorted: sorted,
          ownerAId: myOwnerId,
          ownerBId: targetOwnerId,
        ),
        SetOptions(merge: true),
      );
      tx.set(
        chatRef,
        FirestorePayloads.chatSeed(
          chatId: matchId,
          participantDogIds: sorted,
          ownerAId: myOwnerId,
          ownerBId: targetOwnerId,
        ),
        SetOptions(merge: true),
      );
      didCreateMatch = true;
    });

    return didCreateMatch;
  }

  Future<void> undoLastSwipe({
    required String myDogId,
    required String targetDogId,
    required bool liked,
  }) async {
    final swipeRef = _db.collection('swipes').doc('${myDogId}_$targetDogId');
    await _db.runTransaction((tx) async {
      tx.delete(swipeRef);
      if (!liked) return;

      final sorted = <String>[myDogId, targetDogId]..sort();
      final matchId = '${sorted[0]}_${sorted[1]}';
      tx.delete(_db.collection('matches').doc(matchId));
      tx.delete(_db.collection('chats').doc(matchId));
    });
  }
}
