import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_payloads.dart';

class ServicesRepository {
  ServicesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<Map<String, dynamic>>> watchWalkers() {
    return _db
        .collection('walkers')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList();
      if (items.isNotEmpty) return items;
      return _demoWalkers;
    });
  }

  Stream<List<Map<String, dynamic>>> watchBnbHosts() {
    return _db
        .collection('bnb_hosts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList();
      if (items.isNotEmpty) return items;
      return _demoBnbHosts;
    });
  }

  Stream<List<Map<String, dynamic>>> watchAdoptionPosts() {
    return _db
        .collection('adoption_posts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList();
      if (items.isNotEmpty) return items;
      return _demoAdoptionPosts;
    });
  }

  Future<void> createWalkRequest({
    required String requesterUserId,
    required String requesterDogId,
    required String walkerId,
    required String walkerName,
    required DateTime preferredAt,
    String note = '',
  }) async {
    final ref = _db.collection('walk_requests').doc();
    await ref.set(
      FirestorePayloads.walkRequest(
        requestId: ref.id,
        requesterUserId: requesterUserId,
        requesterDogId: requesterDogId,
        walkerId: walkerId,
        walkerName: walkerName,
        preferredAt: preferredAt,
        note: note,
      ),
      SetOptions(merge: true),
    );
  }

  Future<void> createBnbRequest({
    required String requesterUserId,
    required String requesterDogId,
    required String hostId,
    required String hostName,
    required DateTime checkIn,
    required DateTime checkOut,
    String note = '',
  }) async {
    final ref = _db.collection('bnb_requests').doc();
    await ref.set(
      FirestorePayloads.bnbRequest(
        requestId: ref.id,
        requesterUserId: requesterUserId,
        requesterDogId: requesterDogId,
        hostId: hostId,
        hostName: hostName,
        checkIn: checkIn,
        checkOut: checkOut,
        note: note,
      ),
      SetOptions(merge: true),
    );
  }

  Future<void> createAdoptionApplication({
    required String requesterUserId,
    required String requesterDogId,
    required String postId,
    required String dogName,
    required String ownerUserId,
    String note = '',
  }) async {
    final ref = _db.collection('adoption_applications').doc();
    await ref.set(
      FirestorePayloads.adoptionApplication(
        applicationId: ref.id,
        requesterUserId: requesterUserId,
        requesterDogId: requesterDogId,
        postId: postId,
        ownerUserId: ownerUserId,
        dogName: dogName,
        note: note,
      ),
      SetOptions(merge: true),
    );
  }
}

final List<Map<String, dynamic>> _demoWalkers = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'demo-walker-1',
    'name': 'Ece A.',
    'city': 'Istanbul',
    'rating': 4.9,
    'walkCount': 312,
    'pricePerHour': 290,
    'instantBooking': true,
    'bio': 'Veteriner teknikeriyim. Enerjik kopeklerle iyi anlasirim.',
    'status': 'active',
  },
  <String, dynamic>{
    'id': 'demo-walker-2',
    'name': 'Mert K.',
    'city': 'Istanbul',
    'rating': 4.8,
    'walkCount': 188,
    'pricePerHour': 250,
    'instantBooking': false,
    'bio': 'Aksam saatlerinde duzenli gezdirme destegi veriyorum.',
    'status': 'active',
  },
];

final List<Map<String, dynamic>> _demoBnbHosts = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'demo-host-1',
    'name': 'Can B.',
    'city': 'Istanbul',
    'rating': 4.9,
    'nightlyPrice': 850,
    'verified': true,
    'yard': true,
    'bio': 'Bahceli evde az sayida kopek kabul ediyorum.',
    'status': 'active',
  },
  <String, dynamic>{
    'id': 'demo-host-2',
    'name': 'Aylin S.',
    'city': 'Ankara',
    'rating': 4.8,
    'nightlyPrice': 620,
    'verified': true,
    'yard': false,
    'bio': 'Ev ortaminda sakin ve guvenli konaklama.',
    'status': 'active',
  },
];

final List<Map<String, dynamic>> _demoAdoptionPosts = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'demo-adoption-1',
    'dogName': 'Mavi',
    'city': 'Istanbul',
    'ageMonths': 10,
    'size': 'Kucuk',
    'vaccinated': true,
    'bio': 'Evde bakilmis, oyuncu ve insan odakli bir yavru.',
    'ownerNote': 'Sakin bir ev ve duzenli takip istiyoruz.',
    'ownerUserId': 'demo-owner-1',
    'status': 'active',
  },
  <String, dynamic>{
    'id': 'demo-adoption-2',
    'dogName': 'Tarcin',
    'city': 'Ankara',
    'ageMonths': 18,
    'size': 'Orta',
    'vaccinated': true,
    'bio': 'Temel komutlari biliyor, cocuklarla iyi anlasiyor.',
    'ownerNote': 'Bahceli ev olursa daha iyi adapte olur.',
    'ownerUserId': 'demo-owner-2',
    'status': 'active',
  },
];
