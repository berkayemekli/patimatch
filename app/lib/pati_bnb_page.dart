import 'package:flutter/material.dart';

class PatiBnbPage extends StatelessWidget {
  const PatiBnbPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100 ? 3 : (width > 760 ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _SearchBar(),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.86,
          children: const [
            _StayCard(
              host: 'Can B.',
              city: 'Istanbul',
              nightlyPrice: 850,
              rating: 4.93,
              reviews: 128,
              type: 'Bahceli Ev',
              badge: 'Super Host',
            ),
            _StayCard(
              host: 'Aylin S.',
              city: 'Ankara',
              nightlyPrice: 620,
              rating: 4.81,
              reviews: 96,
              type: 'Daire',
              badge: 'Verified',
            ),
            _StayCard(
              host: 'Nisa Y.',
              city: 'Bursa',
              nightlyPrice: 780,
              rating: 4.97,
              reviews: 154,
              type: 'Premium Home',
              badge: 'Top Rated',
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Nereye?  •  Giris/Cikis  •  Dost Boyutu', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF111827),
            ),
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({
    required this.host,
    required this.city,
    required this.nightlyPrice,
    required this.rating,
    required this.reviews,
    required this.type,
    required this.badge,
  });

  final String host;
  final String city;
  final int nightlyPrice;
  final double rating;
  final int reviews;
  final String type;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      colors: [Color(0xFFEAF2FF), Color(0xFFF8FAFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.home_work_outlined, size: 44, color: Color(0xFF64748B)),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                    ),
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
                    Expanded(
                      child: Text('$host · $city', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    ),
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFF111827)),
                    const SizedBox(width: 2),
                    Text(rating.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$type · $reviews degerlendirme', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Text('₺$nightlyPrice / gece', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
