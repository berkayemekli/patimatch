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
  List<Map<String, dynamic>> _walkers = _defaultWalkers;

  static const List<Map<String, dynamic>> _defaultWalkers = [
    {
      'name': 'Ece Aras',
      'city': 'Istanbul',
      'district': 'Kadikoy',
      'breeds': ['Golden Retriever', 'Labrador Retriever', 'Kirma'],
      'ageRange': '1-3 yas',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'size': 'Orta',
      'rating': 4.9,
      'walks': 312,
      'price': 290,
      'badge': 'Verified',
      'badges': ['Kimlik dogrulandi', 'Canli takip'],
      'specialties': ['Orta boy kopek', 'Duzenli yuruyus'],
      'safety': ['Rota paylasimi', 'Su molasi raporu'],
      'imageUrl':
          'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Mert Kaya',
      'city': 'Istanbul',
      'district': 'Besiktas',
      'breeds': ['Poodle', 'Maltese', 'Pomeranian'],
      'ageRange': '0-1 yas',
      'sex': 'Erkek',
      'vaccineStatus': 'Tam',
      'size': 'Kucuk',
      'rating': 4.8,
      'walks': 188,
      'price': 250,
      'badge': 'Top Rated',
      'badges': ['Top rated', 'Telefon dogrulandi'],
      'specialties': ['Kucuk irklar', 'Aksam yuruyusu'],
      'safety': ['Canli konum', 'Fotografli rapor'],
      'imageUrl':
          'https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Sena Demir',
      'city': 'Ankara',
      'district': 'Cankaya',
      'breeds': ['Kangal', 'Golden Retriever', 'Melez'],
      'ageRange': '3-7 yas',
      'sex': 'Disi',
      'vaccineStatus': 'Fark etmez',
      'size': 'Buyuk',
      'rating': 4.7,
      'walks': 140,
      'price': 220,
      'badge': 'New',
      'badges': ['Yeni', 'Veteriner referansi'],
      'specialties': ['Buyuk irklar', 'Enerjik kopek'],
      'safety': ['Tasma kontrolu', 'Veteriner referansi'],
      'imageUrl':
          'https://images.unsplash.com/photo-1567225557594-88d73e55f2cb?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Bora Tunc',
      'city': 'Izmir',
      'district': 'Karsiyaka',
      'breeds': ['Beagle', 'Cocker Spaniel', 'French Bulldog'],
      'ageRange': '1-3 yas',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'size': 'Orta',
      'rating': 4.9,
      'walks': 276,
      'price': 300,
      'badge': 'Verified',
      'badges': ['Kimlik dogrulandi', 'Canli takip'],
      'specialties': ['Sahil rotasi', 'Sosyallesme yuruyusu'],
      'safety': ['Rota kaydi', 'Yuruyus ozeti'],
      'imageUrl':
          'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Duru Acar',
      'city': 'Istanbul',
      'district': 'Sisli',
      'breeds': ['Shih Tzu', 'Pug', 'Yorkshire Terrier'],
      'ageRange': '7+ yas',
      'sex': 'Disi',
      'vaccineStatus': 'Tam',
      'size': 'Kucuk',
      'rating': 4.8,
      'walks': 221,
      'price': 270,
      'badge': 'Top Rated',
      'badges': ['Top rated', 'Tekrar tercih'],
      'specialties': ['Yasli petler', 'Sakin tempo'],
      'safety': ['Kisa rota', 'Dinlenme molasi'],
      'imageUrl':
          'https://images.unsplash.com/photo-1525253086316-d0c936c814f8?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Kaan Yilmaz',
      'city': 'Ankara',
      'district': 'Kecioren',
      'breeds': ['Border Collie', 'Labrador Retriever', 'Melez'],
      'ageRange': '3-7 yas',
      'sex': 'Erkek',
      'vaccineStatus': 'Eksik',
      'size': 'Buyuk',
      'rating': 4.7,
      'walks': 169,
      'price': 240,
      'badge': 'Verified',
      'badges': ['Kimlik dogrulandi', 'Buyuk irk deneyimi'],
      'specialties': ['Enerji atma', 'Uzun rota'],
      'safety': ['Tasma kontrolu', 'Rota paylasimi'],
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
    final examples = await MasterDataRepository.loadMarketplaceExamples();
    final seedWalkers = _buildSeedWalkers(examples['walkers'] as List<dynamic>?);
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _breedsByType = breeds;
      _districts = districts;
      final seedNames = seedWalkers.map((walker) => walker['name']).toSet();
      final remainingDefaults = _defaultWalkers
          .where((walker) => !seedNames.contains(walker['name']))
          .toList();
      _walkers = <Map<String, dynamic>>[...seedWalkers, ...remainingDefaults];
    });
  }

  List<Map<String, dynamic>> _buildSeedWalkers(List<dynamic>? rawWalkers) {
    if (rawWalkers == null) return const [];
    return rawWalkers.whereType<Map<String, dynamic>>().map((walker) {
      final name = walker['name']?.toString() ?? 'Pati gezdirici';
      final badges = (walker['badges'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
      final specialties =
          (walker['specialties'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList();
      return <String, dynamic>{
        'name': name,
        'city': walker['city']?.toString() ?? 'Istanbul',
        'district': walker['district']?.toString() ?? 'Merkez',
        'breeds': _seedWalkerBreeds(specialties),
        'ageRange': '1-3 yas',
        'sex': 'Fark etmez',
        'vaccineStatus': 'Tam',
        'size': _seedWalkerSize(specialties),
        'rating': 4.9,
        'walks': 86,
        'price': walker['price'] as int? ?? 260,
        'badge': _primaryBadge(badges),
        'badges': badges.isEmpty ? ['Kimlik dogrulandi'] : badges,
        'specialties': specialties.isEmpty
            ? ['Duzenli yuruyus', 'Rota paylasimi']
            : specialties,
        'safety': const ['Canli takip', 'Yuruyus sonrasi rapor'],
        'imageUrl': _imageForSeedWalker(name),
      };
    }).toList();
  }

  List<String> _seedWalkerBreeds(List<String> specialties) {
    final joined = specialties.join(' ').toLowerCase();
    if (joined.contains('kucuk')) {
      return const ['Maltese', 'Poodle', 'Pomeranian'];
    }
    if (joined.contains('buyuk')) {
      return const ['Kangal', 'Golden Retriever', 'Labrador Retriever'];
    }
    return const ['Golden Retriever', 'Labrador Retriever', 'Kirma'];
  }

  String _seedWalkerSize(List<String> specialties) {
    final joined = specialties.join(' ').toLowerCase();
    if (joined.contains('kucuk')) return 'Kucuk';
    if (joined.contains('buyuk')) return 'Buyuk';
    return 'Orta';
  }

  String _primaryBadge(List<String> badges) {
    final joined = badges.join(' ').toLowerCase();
    if (joined.contains('top')) return 'Top Rated';
    if (joined.contains('yeni')) return 'New';
    return 'Verified';
  }

  String _imageForSeedWalker(String name) {
    switch (name) {
      case 'Ece Aras':
        return _defaultWalkers[0]['imageUrl'] as String;
      case 'Mert Kaya':
        return _defaultWalkers[1]['imageUrl'] as String;
      case 'Sena Demir':
        return _defaultWalkers[2]['imageUrl'] as String;
      default:
        return _defaultWalkers.first['imageUrl'] as String;
    }
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
      final breeds = (walker['breeds'] as List<dynamic>).cast<String>();
      final cityOk = _city == 'All' || walker['city'] == _city;
      final districtOk =
          _district == 'Tum ilceler' || walker['district'] == _district;
      final breedOk = _breed == 'Tum cinsler' || breeds.contains(_breed);
      final ageOk =
          _ageRange == 'Tum yaslar' || walker['ageRange'] == _ageRange;
      final sexOk = _sex == 'Fark etmez' || walker['sex'] == _sex;
      final vaccineOk =
          _vaccineStatus == 'Fark etmez' ||
          walker['vaccineStatus'] == _vaccineStatus;
      final sizeOk = _size == 'Tum boyutlar' || walker['size'] == _size;
      final badgeOk = _badgeFilter == 'All' || walker['badge'] == _badgeFilter;
      final query = _searchQuery.trim().toLowerCase();
      final searchOk =
          query.isEmpty ||
          [
            walker['name'],
            walker['city'],
            walker['district'],
            walker['badge'],
            walker['ageRange'],
            walker['sex'],
            walker['vaccineStatus'],
            walker['size'],
            walker['price'],
            walker['walks'],
            ...(walker['badges'] as List<dynamic>? ?? const []),
            ...(walker['specialties'] as List<dynamic>? ?? const []),
            ...(walker['safety'] as List<dynamic>? ?? const []),
            ...breeds,
          ].any((value) => value.toString().toLowerCase().contains(query));
      return cityOk &&
          districtOk &&
          breedOk &&
          ageOk &&
          sexOk &&
          vaccineOk &&
          sizeOk &&
          badgeOk &&
          searchOk;
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
            breeds: _breedsByType['K\u00f6pek'] ?? const <String>[],
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
          if (filtered.isEmpty)
            const _EmptyWalkerState()
          else
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
                  badges: (walker['badges'] as List<dynamic>).cast<String>(),
                  specialties:
                      (walker['specialties'] as List<dynamic>).cast<String>(),
                  safety: (walker['safety'] as List<dynamic>).cast<String>(),
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
                  label: 'Ilce',
                  value: districts.contains(district)
                      ? district
                      : 'Tum ilceler',
                  items: ['Tum ilceler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _FilterDropdown(
                  label: 'Kopek cinsi',
                  value: breeds.contains(breed) ? breed : 'Tum cinsler',
                  items: ['Tum cinsler', ...breeds],
                  onChanged: onBreedChanged,
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
      key: const ValueKey('filter-search'),
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

class _EmptyWalkerState extends StatelessWidget {
  const _EmptyWalkerState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: const Text(
        'Bu filtrelere uygun gezdirici henuz yok. Sehir, ilce veya cinsi degistirerek tekrar deneyebilirsin.',
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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
    required this.badges,
    required this.specialties,
    required this.safety,
    required this.imageUrl,
  });

  final String name;
  final String city;
  final int price;
  final double rating;
  final int walks;
  final String badge;
  final List<String> badges;
  final List<String> specialties;
  final List<String> safety;
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
                      child: _WalkerPill(label: badge, emphasized: true),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _WalkerPill(label: safety.first),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const Icon(Icons.star_rounded, size: 16),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$city - $walks yuruyus',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: specialties
                          .take(2)
                          .map((item) => _WalkerPill(label: item))
                          .toList(),
                    ),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map((item) => _WalkerPill(label: item, emphasized: true))
                  .toList(),
            ),
            const SizedBox(height: 18),
            _WalkerDetailSection(title: 'Uzmanlik', items: specialties),
            const SizedBox(height: 14),
            _WalkerDetailSection(title: 'Guvenli yuruyus', items: safety),
          ],
        ),
      ),
    );
  }
}

class _WalkerPill extends StatelessWidget {
  const _WalkerPill({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFE7F7F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized ? const Color(0xFFBFE7DD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: emphasized ? const Color(0xFF0F766E) : const Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WalkerDetailSection extends StatelessWidget {
  const _WalkerDetailSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
