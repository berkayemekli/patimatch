import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';

class PatiBnbPage extends StatefulWidget {
  const PatiBnbPage({super.key});

  @override
  State<PatiBnbPage> createState() => _PatiBnbPageState();
}

class _PatiBnbPageState extends State<PatiBnbPage> {
  bool _filtersOpen = false;
  String _city = 'Istanbul';
  String _district = 'Tum ilceler';
  String _animalType = 'K?pek';
  String _breed = 'Tum cinsler';
  String _ageRange = 'Tum yaslar';
  String _sex = 'Fark etmez';
  String _vaccineStatus = 'Fark etmez';
  List<String> _cities = const ['Istanbul', 'Ankara', 'Izmir'];
  List<String> _districts = const [];
  Map<String, List<String>> _breedsByType = const {};

  @override
  void initState() {
    super.initState();
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    final cities = await MasterDataRepository.loadCities();
    final breeds = await MasterDataRepository.loadAnimalBreeds();
    final districts = await MasterDataRepository.loadDistricts(_city);
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _breedsByType = breeds;
      _districts = districts;
    });
  }

  Future<void> _setCity(String city) async {
    final districts = city == 'All'
        ? <String>[]
        : await MasterDataRepository.loadDistricts(city);
    if (!mounted) return;
    setState(() {
      _city = city;
      _district = 'Tum ilceler';
      _districts = districts;
    });
  }

  void _setAnimalType(String type) {
    setState(() {
      _animalType = type;
      _breed = 'Tum cinsler';
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 860 ? 3 : (width > 560 ? 2 : 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BnbFilterBar(
            filtersOpen: _filtersOpen,
            city: _city,
            district: _district,
            animalType: _animalType,
            breed: _breed,
            ageRange: _ageRange,
            sex: _sex,
            vaccineStatus: _vaccineStatus,
            cities: _cities,
            districts: _districts,
            breeds: _breedsByType[_animalType] ?? const <String>[],
            onToggle: () => setState(() => _filtersOpen = !_filtersOpen),
            onCityChanged: _setCity,
            onDistrictChanged: (v) => setState(() => _district = v),
            onAnimalTypeChanged: _setAnimalType,
            onBreedChanged: (v) => setState(() => _breed = v),
            onAgeChanged: (v) => setState(() => _ageRange = v),
            onSexChanged: (v) => setState(() => _sex = v),
            onVaccineChanged: (v) => setState(() => _vaccineStatus = v),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.04,
            children: const [
              _StayCard(
                host: 'Can B.',
                city: 'Istanbul',
                nightlyPrice: 850,
                rating: 4.93,
                reviews: 128,
                type: 'Bahceli Ev',
                badge: 'Super Host',
                imageUrl:
                    'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Aylin S.',
                city: 'Ankara',
                nightlyPrice: 620,
                rating: 4.81,
                reviews: 96,
                type: 'Modern Daire',
                badge: 'Verified',
                imageUrl:
                    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Nisa Y.',
                city: 'Bursa',
                nightlyPrice: 780,
                rating: 4.97,
                reviews: 154,
                type: 'Premium Home',
                badge: 'Top Rated',
                imageUrl:
                    'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Deniz K.',
                city: 'Izmir',
                nightlyPrice: 690,
                rating: 4.88,
                reviews: 110,
                type: 'Loft Daire',
                badge: 'Verified',
                imageUrl:
                    'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Pelin A.',
                city: 'Antalya',
                nightlyPrice: 920,
                rating: 4.95,
                reviews: 182,
                type: 'Deniz Manzarali Ev',
                badge: 'Top Rated',
                imageUrl:
                    'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Emre T.',
                city: 'Istanbul',
                nightlyPrice: 740,
                rating: 4.84,
                reviews: 99,
                type: 'Sehir Evi',
                badge: 'Super Host',
                imageUrl:
                    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Sibel N.',
                city: 'Mugla',
                nightlyPrice: 980,
                rating: 4.96,
                reviews: 205,
                type: 'Tas Villa',
                badge: 'Top Rated',
                imageUrl:
                    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Baris L.',
                city: 'Izmir',
                nightlyPrice: 670,
                rating: 4.79,
                reviews: 88,
                type: 'Bahce Kat',
                badge: 'Verified',
                imageUrl:
                    'https://images.unsplash.com/photo-1572120360610-d971b9b63956?auto=format&fit=crop&w=1400&q=80',
              ),
              _StayCard(
                host: 'Cansu P.',
                city: 'Istanbul',
                nightlyPrice: 810,
                rating: 4.91,
                reviews: 141,
                type: 'Terasli Ev',
                badge: 'Super Host',
                imageUrl:
                    'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1400&q=80',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BnbFilterBar extends StatelessWidget {
  const _BnbFilterBar({
    required this.filtersOpen,
    required this.city,
    required this.district,
    required this.animalType,
    required this.breed,
    required this.ageRange,
    required this.sex,
    required this.vaccineStatus,
    required this.cities,
    required this.districts,
    required this.breeds,
    required this.onToggle,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onAnimalTypeChanged,
    required this.onBreedChanged,
    required this.onAgeChanged,
    required this.onSexChanged,
    required this.onVaccineChanged,
  });
  final bool filtersOpen;
  final String city;
  final String district;
  final String animalType;
  final String breed;
  final String ageRange;
  final String sex;
  final String vaccineStatus;
  final List<String> cities;
  final List<String> districts;
  final List<String> breeds;
  final VoidCallback onToggle;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;
  final ValueChanged<String> onAnimalTypeChanged;
  final ValueChanged<String> onBreedChanged;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String> onSexChanged;
  final ValueChanged<String> onVaccineChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(filtersOpen ? 28 : 999),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                const Icon(Icons.tune_rounded),
                const SizedBox(width: 8),
                const Text(
                  'Filtre',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: filtersOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),
          if (filtersOpen) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _BnbDrop(
                  label: 'Il',
                  value: city,
                  items: ['All', ...cities],
                  onChanged: onCityChanged,
                ),
                _BnbDrop(
                  label: 'Ilce',
                  value: districts.contains(district)
                      ? district
                      : 'Tum ilceler',
                  items: ['Tum ilceler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _BnbDrop(
                  label: 'Kedi / K?pek',
                  value: animalType,
                  items: const ['K?pek', 'Kedi'],
                  onChanged: onAnimalTypeChanged,
                ),
                _BnbDrop(
                  label: '$animalType cinsi',
                  value: breeds.contains(breed) ? breed : 'Tum cinsler',
                  items: ['Tum cinsler', ...breeds],
                  onChanged: onBreedChanged,
                ),
                _BnbDrop(
                  label: 'Yas',
                  value: ageRange,
                  items: const [
                    'Tum yaslar',
                    '0-1 yas',
                    '1-3 yas',
                    '3-7 yas',
                    '7+ yas',
                  ],
                  onChanged: onAgeChanged,
                ),
                _BnbDrop(
                  label: 'Cinsiyet',
                  value: sex,
                  items: const ['Fark etmez', 'Disi', 'Erkek'],
                  onChanged: onSexChanged,
                ),
                _BnbDrop(
                  label: 'Asi',
                  value: vaccineStatus,
                  items: const ['Fark etmez', 'Tam', 'Eksik', 'Bilinmiyor'],
                  onChanged: onVaccineChanged,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BnbDrop extends StatelessWidget {
  const _BnbDrop({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : items.first,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
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
    required this.imageUrl,
  });
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
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openStayDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
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
                          child: Text(
                            '$host â€¢ $city',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFF111827),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$type â€¢ $reviews yorum',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'â‚º$nightlyPrice / gece',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStayDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$type - $city',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Ev sahibi: $host',
              style: const TextStyle(color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Text(
              'â‚º$nightlyPrice / gece Â· $reviews yorum',
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}
