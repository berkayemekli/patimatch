import 'package:flutter/material.dart';

class PatiBnbPage extends StatelessWidget {
  const PatiBnbPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 3 : (width > 820 ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _SearchBar(),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.82,
          children: const [
            _StayCard(host: 'Can B.', city: 'Istanbul', nightlyPrice: 850, rating: 4.93, reviews: 128, type: 'Bahceli Ev', badge: 'Super Host', imageUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=1200&q=80'),
            _StayCard(host: 'Aylin S.', city: 'Ankara', nightlyPrice: 620, rating: 4.81, reviews: 96, type: 'Modern Daire', badge: 'Verified', imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80'),
            _StayCard(host: 'Nisa Y.', city: 'Bursa', nightlyPrice: 780, rating: 4.97, reviews: 154, type: 'Premium Home', badge: 'Top Rated', imageUrl: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?auto=format&fit=crop&w=1200&q=80'),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 8),
          Icon(Icons.search_rounded, color: Color(0xFF64748B)),
          SizedBox(width: 10),
          Expanded(child: Text('Nereye? • Giris/Cikis • Dost Boyutu', style: TextStyle(color: Color(0xFF64748B)))),
          Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({required this.host, required this.city, required this.nightlyPrice, required this.rating, required this.reviews, required this.type, required this.badge, required this.imageUrl});
  final String host;
  final String city;
  final int nightlyPrice;
  final double rating;
  final int reviews;
  final String type;
  final String badge;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 14, offset: Offset(0, 6))],
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
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                      child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
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
                      Expanded(child: Text('$host • $city', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFF111827)),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$type • $reviews yorum', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Text('₺$nightlyPrice / gece', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF111827))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
