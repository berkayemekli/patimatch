import 'package:flutter/material.dart';

class PatiGezdirmePage extends StatefulWidget {
  const PatiGezdirmePage({super.key});

  @override
  State<PatiGezdirmePage> createState() => _PatiGezdirmePageState();
}

class _PatiGezdirmePageState extends State<PatiGezdirmePage> {
  String _city = 'Istanbul';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width > 1080 ? 3 : (width > 740 ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _TopFilter(city: _city, onCityChanged: (v) => setState(() => _city = v)),
        const SizedBox(height: 16),
        const Text(
          'Guvenilir gezdiricilerden sec',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Dogrulanmis profiller, sicak yorumlar ve premium deneyim.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: crossCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.80,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _WalkerTile(
              name: 'Ece Aras',
              city: 'Istanbul',
              rating: 4.9,
              walks: 312,
              price: 290,
              imageUrl: 'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=900&q=80',
              badge: 'Verified',
            ),
            _WalkerTile(
              name: 'Mert Kaya',
              city: 'Istanbul',
              rating: 4.8,
              walks: 188,
              price: 250,
              imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=900&q=80',
              badge: 'Top Rated',
            ),
            _WalkerTile(
              name: 'Sena Demir',
              city: 'Ankara',
              rating: 4.7,
              walks: 140,
              price: 220,
              imageUrl: 'https://images.unsplash.com/photo-1542204625-de293a4f7a9b?auto=format&fit=crop&w=900&q=80',
              badge: 'New',
            ),
          ],
        ),
      ],
    );
  }
}

class _TopFilter extends StatelessWidget {
  const _TopFilter({required this.city, required this.onCityChanged});
  final String city;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          const Text('Sehir', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: city,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Istanbul', child: Text('Istanbul')),
                  DropdownMenuItem(value: 'Ankara', child: Text('Ankara')),
                  DropdownMenuItem(value: 'Izmir', child: Text('Izmir')),
                ],
                onChanged: (v) {
                  if (v != null) onCityChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkerTile extends StatelessWidget {
  const _WalkerTile({
    required this.name,
    required this.city,
    required this.rating,
    required this.walks,
    required this.price,
    required this.imageUrl,
    required this.badge,
  });

  final String name;
  final String city;
  final double rating;
  final int walks;
  final int price;
  final String imageUrl;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A))),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                      const Icon(Icons.star_rounded, size: 16),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('$city · $walks yuruyus', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('₺$price / saat', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: null,
                    child: const Text('Yuruyus Planla'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
