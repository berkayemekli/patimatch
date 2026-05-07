import 'package:flutter/material.dart';

class PatiGezdirmePage extends StatelessWidget {
  const PatiGezdirmePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SimpleCard(
          title: 'Ece A. - Istanbul',
          subtitle: '4.9 puan • 312 yuruyus • 290 TL/saat',
        ),
        SizedBox(height: 10),
        _SimpleCard(
          title: 'Mert K. - Istanbul',
          subtitle: '4.8 puan • 188 yuruyus • 250 TL/saat',
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
        leading: const CircleAvatar(child: Icon(Icons.directions_walk)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(onPressed: null, child: Text('Talep')),
      ),
    );
  }
}
