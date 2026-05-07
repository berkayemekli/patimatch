import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  Future<String> _resolveUserLabel(String userId) async {
    if (userId.isEmpty) return '-';
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = snap.data() ?? <String, dynamic>{};
    final name = (data['displayName'] as String? ?? '').trim();
    final phone = (data['phone'] as String? ?? '').trim();
    if (name.isNotEmpty) return name;
    if (phone.isNotEmpty) return phone;
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kullanici bulunamadi.')));
    }

    final blocksStream = FirebaseFirestore.instance
        .collection('blocks')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Engellenenler')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: blocksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Engellenen kullanici yok.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final blockedUserId = data['blockedUserId'] as String? ?? '';
              return FutureBuilder<String>(
                future: _resolveUserLabel(blockedUserId),
                builder: (context, labelSnap) {
                  final label = labelSnap.data ?? blockedUserId;
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.block)),
                    title: Text(label.isEmpty ? '-' : label),
                    subtitle: Text('ID: $blockedUserId'),
                    trailing: TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('blocks')
                            .doc(docs[index].id)
                            .delete();
                      },
                      child: const Text('Engeli Kaldir'),
                    ),
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
