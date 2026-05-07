import 'package:flutter/material.dart';

class PatiGezdirmePage extends StatefulWidget {
  const PatiGezdirmePage({super.key});

  @override
  State<PatiGezdirmePage> createState() => _PatiGezdirmePageState();
}

class _PatiGezdirmePageState extends State<PatiGezdirmePage> {
  String _city = 'Tum Sehirler';
  final Set<String> _features = <String>{};
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('Filtreler'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _city,
          decoration: const InputDecoration(labelText: 'Sehir', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'Tum Sehirler', child: Text('Tum Sehirler')),
            DropdownMenuItem(value: 'Istanbul', child: Text('Istanbul')),
            DropdownMenuItem(value: 'Ankara', child: Text('Ankara')),
            DropdownMenuItem(value: 'Izmir', child: Text('Izmir')),
          ],
          onChanged: (v) => setState(() => _city = v ?? 'Tum Sehirler'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Asili', 'Egitimli', 'Kamerali Takip', 'Acil Destek'].map((f) {
            return FilterChip(
              label: Text(f),
              selected: _features.contains(f),
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _features.add(f);
                  } else {
                    _features.remove(f);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
          child: Text('Konum altyapisi hazir: ${_latController.text.isEmpty ? "-" : _latController.text}, ${_lngController.text.isEmpty ? "-" : _lngController.text}'),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('One Cikan Gezdiriciler'),
        SizedBox(height: 8),
        const _SimpleCard(
          title: 'Ece A. - Istanbul',
          subtitle: '312 yuruyus • 290 TL/saat',
          badge: 'Aninda Musait',
          rating: 4.9,
        ),
        SizedBox(height: 10),
        const _SimpleCard(
          title: 'Mert K. - Istanbul',
          subtitle: '188 yuruyus • 250 TL/saat',
          badge: 'Aksam Slotu',
          rating: 4.8,
        ),
        SizedBox(height: 16),
        const _SectionTitle('Yeni Katilanlar'),
        SizedBox(height: 8),
        const _SimpleCard(
          title: 'Sena D. - Ankara',
          subtitle: '140 yuruyus • 220 TL/saat',
          badge: 'Yeni',
          rating: 4.7,
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
    required this.rating,
  });

  final String title;
  final String subtitle;
  final String badge;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.directions_walk)),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                ...List<Widget>.generate(5, (i) {
                  final isFilled = rating >= i + 1;
                  return Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: const Color(0xFFF59E0B),
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
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
