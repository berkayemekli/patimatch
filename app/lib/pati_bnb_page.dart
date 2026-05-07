import 'package:flutter/material.dart';

class PatiBnbPage extends StatelessWidget {
  const PatiBnbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SimpleCard(
          title: 'Can B. - Istanbul',
          subtitle: '4.9 puan • 850 TL/gece • Bahceli ev',
        ),
        SizedBox(height: 10),
        _SimpleCard(
          title: 'Aylin S. - Ankara',
          subtitle: '4.8 puan • 620 TL/gece • Daire',
        ),
      ],
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.home_work_outlined)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(onPressed: null, child: Text('Talep')),
      ),
    );
  }
}
