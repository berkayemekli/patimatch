import 'package:flutter/material.dart';

class PatiParentPage extends StatelessWidget {
  const PatiParentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SimpleCard(
          title: 'Mavi - Istanbul',
          subtitle: '10 ay • Kucuk • Asili',
        ),
        SizedBox(height: 10),
        _SimpleCard(
          title: 'Tarcin - Ankara',
          subtitle: '18 ay • Orta • Asili',
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
        leading: const CircleAvatar(child: Icon(Icons.pets)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(onPressed: null, child: Text('Basvur')),
      ),
    );
  }
}
