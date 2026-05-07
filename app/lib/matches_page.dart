import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'blocked_users_page.dart';
import 'chat_page.dart';
import 'data/app_providers.dart';
import 'data/matches_repository.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final MatchesRepository _matchesRepository = AppProviders.matchesRepository;
  final Map<String, Future<Map<String, dynamic>?>> _dogFutureCache =
      <String, Future<Map<String, dynamic>?>>{};
  final Map<String, Future<Set<String>>> _blockedFutureCache =
      <String, Future<Set<String>>>{};

  Future<Map<String, dynamic>?> _fetchDog(String dogId) {
    if (dogId.isEmpty) return Future.value(null);
    return _dogFutureCache.putIfAbsent(
      dogId,
      () => _matchesRepository.fetchDog(dogId),
    );
  }

  Future<Set<String>> _fetchBlockedOwnerIds(String myUserId) {
    return _blockedFutureCache.putIfAbsent(
      myUserId,
      () => _matchesRepository.fetchBlockedOwnerIds(myUserId),
    );
  }

  String _buildUnreadBadgeText(Map<String, dynamic> chatData, String myUserId) {
    final lastSenderUserId = chatData['lastSenderUserId'] as String? ?? '';
    if (lastSenderUserId.isEmpty || lastSenderUserId == myUserId) return '';

    final lastMessageAt = chatData['lastMessageAt'];
    if (lastMessageAt is! Timestamp) return '';

    final lastReadBy = chatData['lastReadBy'] as Map<String, dynamic>? ?? {};
    final lastRead = lastReadBy[myUserId];
    if (lastRead is Timestamp && lastRead.compareTo(lastMessageAt) >= 0) {
      return '';
    }
    return '1';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.userNotFound)),
      );
    }

    final matchesStream = _matchesRepository.watchMatchesForUser(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.matchesTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersPage()),
              );
            },
            icon: const Icon(Icons.block),
          ),
        ],
      ),
      body: FutureBuilder<Set<String>>(
        future: _fetchBlockedOwnerIds(user.uid),
        builder: (context, blockedSnap) {
          if (blockedSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final blockedOwnerIds = blockedSnap.data ?? <String>{};

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: matchesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }

              final allDocs = snapshot.data?.docs ?? [];
              final docs = allDocs.where((doc) {
                final ownerIds =
                    (doc.data()['ownerIds'] as List<dynamic>? ?? <dynamic>[])
                        .whereType<String>()
                        .toList();
                final otherOwnerId = ownerIds.firstWhere(
                  (id) => id != user.uid,
                  orElse: () => '',
                );
                return otherOwnerId.isEmpty ||
                    !blockedOwnerIds.contains(otherOwnerId);
              }).toList();

              if (docs.isEmpty) {
                return const Center(child: Text(AppStrings.matchesNone));
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final dogAId = data['dogAId'] as String? ?? '';
                  final dogBId = data['dogBId'] as String? ?? '';
                  final matchId = data['matchId'] as String? ?? docs[index].id;

                  return FutureBuilder<List<Map<String, dynamic>?>>(
                    future: Future.wait([
                      _fetchDog(dogAId),
                      _fetchDog(dogBId),
                    ]),
                    builder: (context, dogSnap) {
                      final dogA = dogSnap.data != null ? dogSnap.data![0] : null;
                      final dogB = dogSnap.data != null ? dogSnap.data![1] : null;
                      final nameA = dogA?['name'] as String? ?? dogAId;
                      final nameB = dogB?['name'] as String? ?? dogBId;
                      final photosA =
                          (dogA?['photoUrls'] as List<dynamic>? ?? <dynamic>[])
                              .whereType<String>()
                              .toList();
                      final photosB =
                          (dogB?['photoUrls'] as List<dynamic>? ?? <dynamic>[])
                              .whereType<String>()
                              .toList();
                      final imageUrl = photosA.isNotEmpty
                          ? photosA.first
                          : (photosB.isNotEmpty ? photosB.first : null);

                      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: _matchesRepository.watchChat(matchId),
                        builder: (context, chatSnap) {
                          final chatData =
                              chatSnap.data?.data() ?? <String, dynamic>{};
                          final unreadText =
                              _buildUnreadBadgeText(chatData, user.uid);

                          return ListTile(
                            leading: CircleAvatar(
                              child: imageUrl == null
                                  ? const Icon(Icons.pets)
                                  : ClipOval(
                                      child: Image.network(
                                        imageUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, size: 18),
                                      ),
                                    ),
                            ),
                            title: Text('$nameA <3 $nameB'),
                            subtitle: Text(
                              (chatData['lastMessage'] as String? ?? '')
                                  .trim()
                                  .isEmpty
                                  ? AppStrings.matchesStartChat
                                  : chatData['lastMessage'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: unreadText.isEmpty
                                ? const Icon(Icons.chat_bubble_outline)
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      unreadText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    chatId: matchId,
                                    title: '${AppStrings.matchesChatTitlePrefix}$nameA${AppStrings.matchesChatTitleSep}$nameB${AppStrings.matchesChatTitleSuffix}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
