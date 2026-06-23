import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';
import 'login_page.dart';

class ServiceConversationsPage extends StatelessWidget {
  const ServiceConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hizmet Mesajları')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoginPage())),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Giriş yap'),
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('chats')
        .where('participantOwnerIds', arrayContains: user.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Hizmet Mesajları')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Mesajlar yüklenemedi: ${snapshot.error}'));
          }
          final docs = (snapshot.data?.docs ?? const [])
              .where((doc) => doc.data()['conversationType'] == 'service')
              .toList()
            ..sort((a, b) {
              final aTime = a.data()['lastMessageAt'];
              final bTime = b.data()['lastMessageAt'];
              final aMs = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
              final bMs = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
              return bMs.compareTo(aMs);
            });
          if (docs.isEmpty) {
            return const _EmptyServiceConversations();
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final module = data['serviceModule'] as String? ?? 'service';
                  final title = data['title'] as String? ?? 'Hizmet konuşması';
                  final message = data['lastMessage'] as String? ?? '';
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        backgroundColor: _moduleColor(module).withValues(alpha: 0.12),
                        child: Icon(_moduleIcon(module), color: _moduleColor(module)),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          message.isEmpty ? 'Konuşmayı başlat' : message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            chatId: doc.id,
                            title: title,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyServiceConversations extends StatelessWidget {
  const _EmptyServiceConversations();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Henüz kabul edilmiş bir hizmet talebin yok. Talep kabul edildiğinde konuşma burada açılacak.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

IconData _moduleIcon(String module) => switch (module) {
  'pati_gezdirme' => Icons.directions_walk_rounded,
  'pati_bnb' => Icons.home_work_rounded,
  'pati_family' => Icons.pets_rounded,
  _ => Icons.handshake_rounded,
};

Color _moduleColor(String module) => switch (module) {
  'pati_gezdirme' => const Color(0xFF0F766E),
  'pati_bnb' => const Color(0xFFF97316),
  'pati_family' => const Color(0xFF4F46E5),
  _ => const Color(0xFF2563EB),
};
