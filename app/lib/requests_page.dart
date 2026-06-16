import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String _view = 'incoming';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Taleplerim')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.login_rounded),
            label: const Text('Giriş yap'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Taleplerim')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'incoming',
                    icon: Icon(Icons.inbox_rounded),
                    label: Text('Bana gelen'),
                  ),
                  ButtonSegment(
                    value: 'outgoing',
                    icon: Icon(Icons.outbox_rounded),
                    label: Text('Gönderdiklerim'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (values) {
                  setState(() => _view = values.first);
                },
              ),
              const SizedBox(height: 16),
              _RequestSection(
                title: 'PatiGezdirme',
                icon: Icons.directions_walk_rounded,
                color: const Color(0xFF0F766E),
                collection: 'walk_requests',
                userId: user.uid,
                view: _view,
              ),
              const SizedBox(height: 16),
              _RequestSection(
                title: 'PatiBnB',
                icon: Icons.home_work_rounded,
                color: const Color(0xFFF97316),
                collection: 'bnb_requests',
                userId: user.uid,
                view: _view,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestSection extends StatelessWidget {
  const _RequestSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.collection,
    required this.userId,
    required this.view,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String collection;
  final String userId;
  final String view;

  String get _ownerField =>
      collection == 'walk_requests' ? 'walkerOwnerUserId' : 'hostOwnerUserId';

  @override
  Widget build(BuildContext context) {
    final field = view == 'incoming' ? _ownerField : 'requesterUserId';
    final query = FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: userId)
        .limit(30);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              view == 'incoming'
                  ? 'Hizmet veren profilin için gelen talepler'
                  : 'Bu modülde gönderdiğin talepler',
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Talepler yüklenemedi: ${snapshot.error}'),
                );
              }
              final docs = snapshot.data?.docs ?? const [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Henüz talep yok.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                );
              }
              final sortedDocs = docs.toList()
                ..sort((a, b) {
                  final aTime = _timestampMillis(a.data()['createdAt']);
                  final bTime = _timestampMillis(b.data()['createdAt']);
                  return bTime.compareTo(aTime);
                });
              return Column(
                children: sortedDocs
                    .map(
                      (doc) => _RequestTile(
                        doc: doc,
                        collection: collection,
                        incoming: view == 'incoming',
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatefulWidget {
  const _RequestTile({
    required this.doc,
    required this.collection,
    required this.incoming,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String collection;
  final bool incoming;

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _saving = false;

  Future<void> _setStatus(String status) async {
    setState(() => _saving = true);
    try {
      await widget.doc.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data();
    final isWalk = widget.collection == 'walk_requests';
    final name = isWalk
        ? (data['walkerName'] as String? ?? 'Gezdirici')
        : (data['hostName'] as String? ?? 'Host');
    final status = data['status'] as String? ?? 'pending';
    final note = data['note'] as String? ?? '';
    final when = isWalk
        ? _formatTimestamp(data['preferredAt'])
        : '${_formatTimestamp(data['checkIn'])} - ${_formatTimestamp(data['checkOut'])}';

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(when),
                if (note.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(note),
                ],
              ],
            ),
          ),
        ),
        if (widget.incoming && status == 'pending')
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : () => _setStatus('rejected'),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reddet'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _setStatus('accepted'),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Kabul et'),
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'accepted' => const Color(0xFF0F766E),
      'rejected' => const Color(0xFFB91C1C),
      _ => const Color(0xFFB45309),
    };
    final label = switch (status) {
      'accepted' => 'Kabul edildi',
      'rejected' => 'Reddedildi',
      _ => 'Bekliyor',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _formatTimestamp(dynamic value) {
  if (value is! Timestamp) return 'Tarih seçilmedi';
  final date = value.toDate();
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

int _timestampMillis(dynamic value) {
  if (value is! Timestamp) return 0;
  return value.millisecondsSinceEpoch;
}
