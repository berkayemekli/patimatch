import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';

class PatiGezdirmePage extends StatefulWidget {
  const PatiGezdirmePage({super.key});

  @override
  State<PatiGezdirmePage> createState() => _PatiGezdirmePageState();
}

class _PatiGezdirmePageState extends State<PatiGezdirmePage> {
  bool _filtersOpen = false;
  String _city = 'Istanbul';
  String _district = 'Tum ilceler';
  String _breed = 'Tum cinsler';
  String _ageRange = 'Tum yaslar';
  String _sex = 'Fark etmez';
  String _vaccineStatus = 'Fark etmez';
  String _size = 'Tum boyutlar';
  String _badgeFilter = 'All';
  String _searchQuery = '';
  List<String> _cities = const ['Istanbul', 'Ankara', 'Izmir'];
  List<String> _districts = const [];
  Map<String, List<String>> _breedsByType = const {};

  static const List<Map<String, dynamic>> _walkers = [
    {
      'name': 'Ece Aras',
      'city': 'Istanbul',
      'rating': 4.9,
      'walks': 312,
      'price': 290,
      'badge': 'Verified',
      'imageUrl':
          'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Mert Kaya',
      'city': 'Istanbul',
      'rating': 4.8,
      'walks': 188,
      'price': 250,
      'badge': 'Top Rated',
      'imageUrl':
          'https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Sena Demir',
      'city': 'Ankara',
      'rating': 4.7,
      'walks': 140,
      'price': 220,
      'badge': 'New',
      'imageUrl':
          'https://images.unsplash.com/photo-1567225557594-88d73e55f2cb?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Bora Tunc',
      'city': 'Izmir',
      'rating': 4.9,
      'walks': 276,
      'price': 300,
      'badge': 'Verified',
      'imageUrl':
          'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Duru Acar',
      'city': 'Istanbul',
      'rating': 4.8,
      'walks': 221,
      'price': 270,
      'badge': 'Top Rated',
      'imageUrl':
          'https://images.unsplash.com/photo-1525253086316-d0c936c814f8?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Kaan Yilmaz',
      'city': 'Ankara',
      'rating': 4.7,
      'walks': 169,
      'price': 240,
      'badge': 'Verified',
      'imageUrl':
          'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&w=1200&q=80',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width > 860 ? 3 : (width > 560 ? 2 : 1);
    final filtered = _walkers.where((walker) {
      final cityOk = _city == 'All' || walker['city'] == _city;
      final badgeOk = _badgeFilter == 'All' || walker['badge'] == _badgeFilter;
      final query = _searchQuery.trim().toLowerCase();
      final searchOk =
          query.isEmpty ||
          [
            walker['name'],
            walker['city'],
            walker['badge'],
            walker['price'],
            walker['walks'],
          ].any((value) => value.toString().toLowerCase().contains(query));
      return cityOk && badgeOk && searchOk;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopFilter(
            filtersOpen: _filtersOpen,
            city: _city,
            district: _district,
            breed: _breed,
            ageRange: _ageRange,
            sex: _sex,
            vaccineStatus: _vaccineStatus,
            size: _size,
            searchQuery: _searchQuery,
            cities: _cities,
            districts: _districts,
            breeds: _breedsByType['Köpek'] ?? const <String>[],
            onToggle: () => setState(() => _filtersOpen = !_filtersOpen),
            onCityChanged: _setCity,
            onDistrictChanged: (v) => setState(() => _district = v),
            onBreedChanged: (v) => setState(() => _breed = v),
            onAgeRangeChanged: (v) => setState(() => _ageRange = v),
            onSexChanged: (v) => setState(() => _sex = v),
            onVaccineStatusChanged: (v) => setState(() => _vaccineStatus = v),
            onSizeChanged: (v) => setState(() => _size = v),
            onSearchChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 18),
          _BadgeFilters(
            selected: _badgeFilter,
            onChanged: (value) => setState(() => _badgeFilter = value),
          ),
          const SizedBox(height: 18),
          const Text(
            'Istanbul ve cevresindeki yuruyus partnerleri',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dogrulanmis profiller, sicak yorumlar ve guvenli yuruyus deneyimi.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final walker = filtered[index];
              return _WalkerCard(
                name: walker['name'] as String,
                city: walker['city'] as String,
                price: walker['price'] as int,
                rating: walker['rating'] as double,
                walks: walker['walks'] as int,
                badge: walker['badge'] as String,
                imageUrl: walker['imageUrl'] as String,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeFilters extends StatelessWidget {
  const _BadgeFilters({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = ['All', 'New', 'Verified', 'Top Rated'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final active = item == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item),
              selected: active,
              onSelected: (_) => onChanged(item),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF111827),
              ),
              selectedColor: const Color(0xFF111827),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: active
                    ? const Color(0xFF111827)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TopFilter extends StatelessWidget {
  const _TopFilter({
    required this.filtersOpen,
    required this.city,
    required this.district,
    required this.breed,
    required this.ageRange,
    required this.sex,
    required this.vaccineStatus,
    required this.size,
    required this.searchQuery,
    required this.cities,
    required this.districts,
    required this.breeds,
    required this.onToggle,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onBreedChanged,
    required this.onAgeRangeChanged,
    required this.onSexChanged,
    required this.onVaccineStatusChanged,
    required this.onSizeChanged,
    required this.onSearchChanged,
  });

  final bool filtersOpen;
  final String city;
  final String district;
  final String breed;
  final String ageRange;
  final String sex;
  final String vaccineStatus;
  final String size;
  final String searchQuery;
  final List<String> cities;
  final List<String> districts;
  final List<String> breeds;
  final VoidCallback onToggle;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;
  final ValueChanged<String> onBreedChanged;
  final ValueChanged<String> onAgeRangeChanged;
  final ValueChanged<String> onSexChanged;
  final ValueChanged<String> onVaccineStatusChanged;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(filtersOpen ? 28 : 999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
            _FilterSearchField(
              value: searchQuery,
              hintText: 'Gezdirici, sehir, rozet veya fiyat ara',
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FilterDropdown(
                  label: 'Il',
                  value: city,
                  items: ['All', ...cities],
                  labels: const {'All': 'Tum iller'},
                  onChanged: onCityChanged,
                ),
                _FilterDropdown(
                  label: 'Köpek cinsi',
                  value: breeds.contains(breed) ? breed : 'Tum cinsler',
                  items: ['Tum cinsler', ...breeds],
                  onChanged: onBreedChanged,
                ),
                _FilterDropdown(
                  label: 'Ilce',
                  value: districts.contains(district)
                      ? district
                      : 'Tum ilceler',
                  items: ['Tum ilceler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _FilterDropdown(
                  label: 'Yas',
                  value: ageRange,
                  items: const [
                    'Tum yaslar',
                    '0-1 yas',
                    '1-3 yas',
                    '3-7 yas',
                    '7+ yas',
                  ],
                  onChanged: onAgeRangeChanged,
                ),
                _FilterDropdown(
                  label: 'Cinsiyet',
                  value: sex,
                  items: const ['Fark etmez', 'Disi', 'Erkek'],
                  onChanged: onSexChanged,
                ),
                _FilterDropdown(
                  label: 'Asi durumu',
                  value: vaccineStatus,
                  items: const ['Fark etmez', 'Tam', 'Eksik', 'Bilinmiyor'],
                  onChanged: onVaccineStatusChanged,
                ),
                _FilterDropdown(
                  label: 'Boyut',
                  value: size,
                  items: const ['Tum boyutlar', 'Kucuk', 'Orta', 'Buyuk'],
                  onChanged: onSizeChanged,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterSearchField extends StatelessWidget {
  const _FilterSearchField({
    required this.value,
    required this.hintText,
    required this.onChanged,
  });

  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('filter-search-$value'),
      initialValue: value,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labels = const {},
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final safeItems = items.toSet().toList();
    final safeValue = safeItems.contains(value) ? value : safeItems.first;
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: safeItems
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(labels[item] ?? item),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  const _WalkerCard({
    required this.name,
    required this.city,
    required this.price,
    required this.rating,
    required this.walks,
    required this.badge,
    required this.imageUrl,
  });

  final String name;
  final String city;
  final int price;
  final double rating;
  final int walks;
  final String badge;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openDetails(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white,
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Icon(Icons.star_rounded, size: 16),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$city - $walks yuruyus'),
                    const SizedBox(height: 6),
                    Text(
                      '$price TL / saat',
                      style: const TextStyle(fontWeight: FontWeight.w800),
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

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('$city - $walks yuruyus - $price TL/saat'),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.map_rounded),
              title: Text('Canli konum paylasimi'),
            ),
            const ListTile(
              leading: Icon(Icons.verified_user_rounded),
              title: Text('Dogrulanmis profil'),
            ),
          ],
        ),
      ),
    );
  }
}
