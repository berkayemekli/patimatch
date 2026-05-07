import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'data/app_providers.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _formatTimestamp(dynamic ts) {
    if (ts is! Timestamp) return '-';
    final dt = ts.toDate();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$day.$month.${dt.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.userNotFound)),
      );
    }

    final repo = AppProviders.notificationRepository;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimlerim'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: repo.watchNotificationsForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final items = snapshot.data ?? <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(
              child: Text('Henuz bildirimin bulunmuyor.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['notificationId'] as String? ?? item['id'] as String? ?? '';
              final title = item['title'] as String? ?? '-';
              final body = item['body'] as String? ?? '';
              final isRead = item['isRead'] == true;
              final createdAt = item['createdAt'];

              return Card(
                color: isRead ? null : const Color(0xFFEFF8FF),
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(body),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    if (isRead) return;
                    await repo.markRead(notificationId: id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
