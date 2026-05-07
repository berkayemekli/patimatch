import 'package:flutter/material.dart';

class PatiGezdirmePage extends StatefulWidget {
  const PatiGezdirmePage({super.key});

  @override
  State<PatiGezdirmePage> createState() => _PatiGezdirmePageState();
}

class _PatiGezdirmePageState extends State<PatiGezdirmePage> {
  String _city = 'Istanbul';
  final Set<String> _filters = <String>{'Asili', 'Dogrulandi'};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Hero(city: _city),
        const SizedBox(height: 14),
        const _TrustLayer(),
        const SizedBox(height: 14),
        _FilterBar(
          city: _city,
          filters: _filters,
          onCityChanged: (v) => setState(() => _city = v),
          onFilterToggle: (name, selected) {
            setState(() {
              if (selected) {
                _filters.add(name);
              } else {
                _filters.remove(name);
              }
            });
          },
        ),
        const SizedBox(height: 14),
        const _WalkerCard(
          name: 'Ece Aras',
          city: 'Istanbul',
          rating: 4.9,
          walks: 312,
          pricePerHour: 290,
          availability: 'Aninda Musait',
          verified: true,
        ),
        const SizedBox(height: 10),
        const _WalkerCard(
          name: 'Mert Kaya',
          city: 'Istanbul',
          rating: 4.8,
          walks: 188,
          pricePerHour: 250,
          availability: 'Aksam Slotu',
          verified: true,
        ),
        const SizedBox(height: 10),
        const _WalkerCard(
          name: 'Sena Demir',
          city: 'Ankara',
          rating: 4.7,
          walks: 140,
          pricePerHour: 220,
          availability: 'Yeni',
          verified: false,
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4F7FB), Color(0xFFEAF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PatiGezdirme',
            style: TextStyle(color: Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '$city icin premium gezdiriciler',
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.city,
    required this.filters,
    required this.onCityChanged,
    required this.onFilterToggle,
  });

  final String city;
  final Set<String> filters;
  final ValueChanged<String> onCityChanged;
  final void Function(String name, bool selected) onFilterToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: city,
            decoration: const InputDecoration(labelText: 'Sehir', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Istanbul', child: Text('Istanbul')),
              DropdownMenuItem(value: 'Ankara', child: Text('Ankara')),
              DropdownMenuItem(value: 'Izmir', child: Text('Izmir')),
            ],
            onChanged: (v) {
              if (v != null) onCityChanged(v);
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Asili', 'Dogrulandi', 'Acil Destek', 'Kamerali Takip'].map((item) {
              return FilterChip(
                label: Text(item),
                selected: filters.contains(item),
                onSelected: (v) => onFilterToggle(item, v),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TrustLayer extends StatelessWidget {
  const _TrustLayer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _TrustCard(
            icon: Icons.verified_user_outlined,
            title: 'Verified Walkers',
            subtitle: 'Kimlik ve profil dogrulama',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _TrustCard(
            icon: Icons.location_searching_outlined,
            title: 'Live Tracking',
            subtitle: 'Canli rota ve durum takibi',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _TrustCard(
            icon: Icons.health_and_safety_outlined,
            title: 'Emergency Support',
            subtitle: 'Acil destek protokolu',
          ),
        ),
      ],
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0A84FF)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  const _WalkerCard({
    required this.name,
    required this.city,
    required this.rating,
    required this.walks,
    required this.pricePerHour,
    required this.availability,
    required this.verified,
  });

  final String name;
  final String city;
  final double rating;
  final int walks;
  final int pricePerHour;
  final String availability;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 22, child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        if (verified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, size: 18, color: Color(0xFF0A84FF)),
                        ],
                      ],
                    ),
                    Text(city, style: const TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              _Badge(text: availability),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Metric(icon: Icons.star_rounded, label: 'Puan', value: rating.toStringAsFixed(1))),
              Expanded(child: _Metric(icon: Icons.route_rounded, label: 'Yuruyus', value: '$walks')),
              Expanded(child: _Metric(icon: Icons.payments_rounded, label: 'Saatlik', value: '₺$pricePerHour')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF111827),
                disabledForegroundColor: Colors.white,
              ),
              child: const Text('Guvenli Yuruyus Planla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0A84FF)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF1E3A8A)),
      ),
    );
  }
}
