import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _calendarQueryLimit = 250;
  late Future<List<_CalendarEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<List<_CalendarEvent>> _loadEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const <_CalendarEvent>[];

    final db = FirebaseFirestore.instance;
    final snapshots = await Future.wait([
      db
          .collection('walk_requests')
          .where('requesterUserId', isEqualTo: user.uid)
          .limit(_calendarQueryLimit)
          .get(),
      db
          .collection('walk_requests')
          .where('walkerOwnerUserId', isEqualTo: user.uid)
          .limit(_calendarQueryLimit)
          .get(),
      db
          .collection('bnb_requests')
          .where('requesterUserId', isEqualTo: user.uid)
          .limit(_calendarQueryLimit)
          .get(),
      db
          .collection('bnb_requests')
          .where('hostOwnerUserId', isEqualTo: user.uid)
          .limit(_calendarQueryLimit)
          .get(),
    ]);

    final events = <_CalendarEvent>[];
    final seen = <String>{};
    for (final snap in snapshots) {
      for (final doc in snap.docs) {
        if (!seen.add(doc.reference.path)) continue;
        final data = doc.data();
        if (doc.reference.parent.id == 'walk_requests') {
          final start = (data['preferredAt'] as Timestamp?)?.toDate();
          if (start == null) continue;
          events.add(
            _CalendarEvent(
              id: doc.id,
              module: 'PatiGezdirme',
              title: data['walkerName'] as String? ?? 'Gezdirme talebi',
              subtitle: data['note'] as String? ?? '',
              status: data['status'] as String? ?? 'pending',
              start: start,
              end: start.add(const Duration(hours: 1)),
              color: const Color(0xFF0F766E),
              icon: Icons.directions_walk_rounded,
            ),
          );
        } else {
          final start = (data['checkIn'] as Timestamp?)?.toDate();
          final end = (data['checkOut'] as Timestamp?)?.toDate();
          if (start == null || end == null) continue;
          events.add(
            _CalendarEvent(
              id: doc.id,
              module: 'PatiBnB',
              title: data['hostName'] as String? ?? 'Konaklama talebi',
              subtitle: data['note'] as String? ?? '',
              status: data['status'] as String? ?? 'pending',
              start: start,
              end: end.isAfter(start)
                  ? end
                  : start.add(const Duration(days: 1)),
              color: const Color(0xFFF97316),
              icon: Icons.home_work_rounded,
            ),
          );
        }
      }
    }

    events.sort((a, b) => a.start.compareTo(b.start));
    return events;
  }

  void _refresh() {
    setState(() => _eventsFuture = _loadEvents());
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Takvim')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            icon: const Icon(Icons.login_rounded),
            label: const Text('Takvim için giriş yap'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Takvim'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<_CalendarEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Takvim yüklenemedi: ${snapshot.error}'));
          }
          final events = snapshot.data ?? const <_CalendarEvent>[];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  const _CalendarHero(),
                  const SizedBox(height: 14),
                  if (events.isEmpty)
                    const _EmptyCalendarState()
                  else ...[
                    _CalendarSummary(events: events),
                    const SizedBox(height: 14),
                    for (final event in events) ...[
                      _CalendarEventCard(event: event),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CalendarHero extends StatelessWidget {
  const _CalendarHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFDCFCE7),
            child: Icon(Icons.calendar_month_rounded, color: Color(0xFF166534)),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pati takvimin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Gezdirme ve konaklama taleplerini tek yerde takip et, uygun olanları Google Takvim’e ekle.',
                  style: TextStyle(color: Color(0xFFCBD5E1), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarSummary extends StatelessWidget {
  const _CalendarSummary({required this.events});

  final List<_CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final pending = events.where((event) => event.status == 'pending').length;
    final accepted = events.where((event) => event.status == 'accepted').length;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Toplam',
            value: '${events.length}',
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Bekleyen',
            value: '$pending',
            color: const Color(0xFFB45309),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Onaylı',
            value: '$accepted',
            color: const Color(0xFF0F766E),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({required this.event});

  final _CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: event.color.withValues(alpha: 0.12),
                child: Icon(event.icon, color: event.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${event.module} • ${_formatDateRange(event.start, event.end)}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: event.status),
            ],
          ),
          if (event.subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              event.subtitle,
              style: const TextStyle(color: Color(0xFF475569), height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openGoogleCalendar(context, event),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Google Takvim’e ekle'),
                ),
              ),
            ],
          ),
        ],
      ),
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
      'accepted' => 'Onaylı',
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

class _EmptyCalendarState extends StatelessWidget {
  const _EmptyCalendarState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'Henüz tarihli talebin yok. PatiGezdirme veya PatiBnB’de tarih seçerek talep oluşturduğunda burada görünecek.',
        style: TextStyle(color: Color(0xFF64748B), height: 1.4),
      ),
    );
  }
}

class _CalendarEvent {
  const _CalendarEvent({
    required this.id,
    required this.module,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.start,
    required this.end,
    required this.color,
    required this.icon,
  });

  final String id;
  final String module;
  final String title;
  final String subtitle;
  final String status;
  final DateTime start;
  final DateTime end;
  final Color color;
  final IconData icon;
}

Future<void> _openGoogleCalendar(
  BuildContext context,
  _CalendarEvent event,
) async {
  final uri = Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': '${event.module}: ${event.title}',
    'dates': '${_googleDate(event.start)}/${_googleDate(event.end)}',
    'details':
        '${event.module} rezervasyon/talep kaydı. Durum: ${event.status}. ${event.subtitle}',
    'sf': 'true',
    'output': 'xml',
  });

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google Takvim açılamadı.')));
  }
}

String _googleDate(DateTime date) {
  final utc = date.toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${utc.year}${two(utc.month)}${two(utc.day)}T'
      '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
}

String _formatDateRange(DateTime start, DateTime end) {
  final startText = _formatDateTime(start);
  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  if (sameDay) return '$startText - ${_formatTime(end)}';
  return '$startText - ${_formatDateTime(end)}';
}

String _formatDateTime(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year} '
      '${_formatTime(date)}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
