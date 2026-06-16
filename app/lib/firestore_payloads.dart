import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePayloads {
  static Map<String, dynamic> swipe({
    required String swipeId,
    required String fromDogId,
    required String fromOwnerId,
    required String toDogId,
    required String toOwnerId,
    required bool liked,
  }) {
    return {
      'swipeId': swipeId,
      'fromDogId': fromDogId,
      'fromOwnerId': fromOwnerId,
      'toDogId': toDogId,
      'toOwnerId': toOwnerId,
      'decision': liked ? 'like' : 'pass',
      'liked': liked,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> match({
    required String matchId,
    required List<String> dogIdsSorted,
    required String ownerAId,
    required String ownerBId,
  }) {
    return {
      'matchId': matchId,
      'dogAId': dogIdsSorted[0],
      'dogBId': dogIdsSorted[1],
      'dogIds': dogIdsSorted,
      'ownerIds': <String>[ownerAId, ownerBId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };
  }

  static Map<String, dynamic> chatSeed({
    required String chatId,
    required List<String> participantDogIds,
    required String ownerAId,
    required String ownerBId,
  }) {
    return {
      'chatId': chatId,
      'matchId': chatId,
      'participantDogIds': participantDogIds,
      'participantOwnerIds': <String>[ownerAId, ownerBId],
      'lastMessage': 'Eslesme olustu. Sohbete baslayin.',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };
  }

  static Map<String, dynamic> block({
    required String blockId,
    required String userId,
    required String blockedUserId,
    required String reason,
  }) {
    return {
      'blockId': blockId,
      'userId': userId,
      'blockedUserId': blockedUserId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> reportUserOrDog({
    required String reportId,
    required String reporterUserId,
    required String reportedUserId,
    required String reportedDogId,
    required String reasonCode,
    required String description,
  }) {
    return {
      'reportId': reportId,
      'reporterUserId': reporterUserId,
      'reportedUserId': reportedUserId,
      'reportedDogId': reportedDogId,
      'status': 'open',
      'reasonCode': reasonCode,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> reportChatMessage({
    required String reportId,
    required String reporterUserId,
    required String reportedUserId,
    required String chatId,
    required String messageId,
    required String reportedMessageText,
  }) {
    return {
      'reportId': reportId,
      'reporterUserId': reporterUserId,
      'reportedUserId': reportedUserId,
      'chatId': chatId,
      'messageId': messageId,
      'reportedMessageText': reportedMessageText,
      'status': 'open',
      'reasonCode': 'chat_message',
      'description': 'Message report from chat',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> walkRequest({
    required String requestId,
    required String requesterUserId,
    required String requesterDogId,
    required String walkerId,
    required String walkerOwnerUserId,
    required String walkerName,
    required DateTime preferredAt,
    required String note,
  }) {
    return {
      'requestId': requestId,
      'requesterUserId': requesterUserId,
      'requesterDogId': requesterDogId,
      'walkerId': walkerId,
      'walkerOwnerUserId': walkerOwnerUserId,
      'walkerName': walkerName,
      'preferredAt': Timestamp.fromDate(preferredAt),
      'note': note,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> bnbRequest({
    required String requestId,
    required String requesterUserId,
    required String requesterDogId,
    required String hostId,
    required String hostOwnerUserId,
    required String hostName,
    required DateTime checkIn,
    required DateTime checkOut,
    required String note,
  }) {
    return {
      'requestId': requestId,
      'requesterUserId': requesterUserId,
      'requesterDogId': requesterDogId,
      'hostId': hostId,
      'hostOwnerUserId': hostOwnerUserId,
      'hostName': hostName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'note': note,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> adoptionApplication({
    required String applicationId,
    required String requesterUserId,
    required String requesterDogId,
    required String postId,
    required String ownerUserId,
    required String dogName,
    required String note,
  }) {
    return {
      'applicationId': applicationId,
      'requesterUserId': requesterUserId,
      'requesterDogId': requesterDogId,
      'postId': postId,
      'ownerUserId': ownerUserId,
      'dogName': dogName,
      'note': note,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
