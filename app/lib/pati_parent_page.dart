import 'package:flutter/material.dart';

class PatiParentPage extends StatelessWidget {
  const PatiParentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionTitle('Sahiplendirme Ilanlari'),
        SizedBox(height: 8),
        _SimpleCard(
          title: 'Mavi - Istanbul',
          subtitle: '10 ay ? Kucuk ? Asili ? Oyuncu karakter',
          badge: 'Acil Yuva',
        ),
        SizedBox(height: 10),
        _SimpleCard(
          title: 'Tarcin - Ankara',
          subtitle: '18 ay ? Orta ? Asili ? Cocuklarla uyumlu',
          badge: 'Dogrulanmis',
        ),
        SizedBox(height: 16),
        _SectionTitle('Yeni Ilanlar'),
        SizedBox(height: 8),
        _SimpleCard(
          title: 'Boncuk - Bursa',
          subtitle: '14 ay ? Kucuk ? Sakin ev ortami sever',
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
        leading: const CircleAvatar(child: Icon(Icons.pets)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            ElevatedButton(onPressed: null, child: const Text('Basvur')),
          ],
        ),
      ),
    );
  }
}
