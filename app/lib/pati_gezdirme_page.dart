import 'package:flutter/material.dart';

class PatiGezdirmePage extends StatelessWidget {
  const PatiGezdirmePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionTitle('One Cikan Gezdiriciler'),
        SizedBox(height: 8),
        _SimpleCard(
          title: 'Ece A. - Istanbul',
          subtitle: '4.9 puan ? 312 yuruyus ? 290 TL/saat',
          badge: 'Aninda Musait',
        ),
        SizedBox(height: 10),
        _SimpleCard(
          title: 'Mert K. - Istanbul',
          subtitle: '4.8 puan ? 188 yuruyus ? 250 TL/saat',
          badge: 'Aksam Slotu',
        ),
        SizedBox(height: 16),
        _SectionTitle('Yeni Katilanlar'),
        SizedBox(height: 8),
        _SimpleCard(
          title: 'Sena D. - Ankara',
          subtitle: '4.7 puan ? 140 yuruyus ? 220 TL/saat',
          badge: 'Yeni',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.directions_walk)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            ElevatedButton(onPressed: null, child: const Text('Talep')),
          ],
        ),
      ),
    );
  }
}
