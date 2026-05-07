import 'package:flutter/material.dart';

class PatiBnbPage extends StatelessWidget {
  const PatiBnbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionTitle('One Cikan Bakicilar'),
        SizedBox(height: 8),
        _SimpleCard(
          title: 'Can B. - Istanbul',
          subtitle: '4.9 puan ? 850 TL/gece ? Bahceli ev',
          badge: 'Dogrulanmis',
        ),
        SizedBox(height: 10),
        _SimpleCard(
          title: 'Aylin S. - Ankara',
          subtitle: '4.8 puan ? 620 TL/gece ? Daire',
          badge: 'Hizli Donus',
        ),
        SizedBox(height: 16),
        _SectionTitle('Hafta Sonu Uygun'),
        SizedBox(height: 8),
        _SimpleCard(
          title: 'Nisa Y. - Bursa',
          subtitle: '5.0 puan ? 780 TL/gece ? Premium',
          badge: 'One Cikan',
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
        leading: const CircleAvatar(child: Icon(Icons.home_work_outlined)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
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
