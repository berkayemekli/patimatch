import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';
import 'data/services_repository.dart';
import 'data/user_repository.dart';
import 'login_page.dart';

class PatiGezdirmePage extends StatefulWidget {
  const PatiGezdirmePage({super.key});

  @override
  State<PatiGezdirmePage> createState() => _PatiGezdirmePageState();
}

class _PatiGezdirmePageState extends State<PatiGezdirmePage> {
  bool _filtersOpen = false;
  String _city = '\u0130stanbul';
  String _district = 'T\u{00FC}m il\u{00E7}eler';
  String _breed = 'T\u{00FC}m cinsler';
  String _ageRange = 'T\u{00FC}m ya\u{015F}lar';
  String _sex = 'Fark etmez';
  String _vaccineStatus = 'Fark etmez';
  String _size = 'T\u{00FC}m boyutlar';
  String _badgeFilter = 'All';
  String _searchQuery = '';
  List<String> _cities = const ['\u0130stanbul', 'Ankara', '\u0130zmir'];
  List<String> _districts = const [];
  Map<String, List<String>> _breedsByType = const {};
  List<Map<String, dynamic>> _publishedWalkers = const <Map<String, dynamic>>[];

  static const List<Map<String, dynamic>> _demoWalkers = [
    {
      'name': 'Ece Aras',
      'city': '\u0130stanbul',
      'district': 'Kad\u0131k\u00f6y',
      'breeds': ['Golden Retriever', 'Labrador Retriever', 'Kirma'],
      'ageRange': '1-3 yas',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'size': 'Orta',
      'rating': 4.9,
      'walks': 312,
      'price': 290,
      'badge': 'Verified',
      'imageUrl':
          'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Mert Kaya',
      'city': '\u0130stanbul',
      'district': 'Be\u015fikta\u015f',
      'breeds': ['Poodle', 'Maltese', 'Pomeranian'],
      'ageRange': '0-1 yas',
      'sex': 'Erkek',
      'vaccineStatus': 'Tam',
      'size': 'K\u{00FC}\u{00E7}\u{00FC}k',
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
      'district': '\u00c7ankaya',
      'breeds': ['Kangal', 'Golden Retriever', 'Melez'],
      'ageRange': '3-7 yas',
      'sex': 'Di\u{015F}i',
      'vaccineStatus': 'Fark etmez',
      'size': 'B\u{00FC}y\u{00FC}k',
      'rating': 4.7,
      'walks': 140,
      'price': 220,
      'badge': 'New',
      'imageUrl':
          'https://images.unsplash.com/photo-1567225557594-88d73e55f2cb?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Bora Tunc',
      'city': '\u0130zmir',
      'district': 'Kar\u015f\u0131yaka',
      'breeds': ['Beagle', 'Cocker Spaniel', 'French Bulldog'],
      'ageRange': '1-3 yas',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'size': 'Orta',
      'rating': 4.9,
      'walks': 276,
      'price': 300,
      'badge': 'Verified',
      'imageUrl':
          'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'name': 'Duru Acar',
      'city': '\u0130stanbul',
      'district': '\u015ei\u015fli',
      'breeds': ['Shih Tzu', 'Pug', 'Yorkshire Terrier'],
      'ageRange': '7+ yas',
      'sex': 'Di\u{015F}i',
      'vaccineStatus': 'Tam',
      'size': 'K\u{00FC}\u{00E7}\u{00FC}k',
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
      'district': 'Ke\u00e7i\u00f6ren',
      'breeds': ['Border Collie', 'Labrador Retriever', 'Melez'],
      'ageRange': '3-7 yas',
      'sex': 'Erkek',
      'vaccineStatus': 'Eksik',
      'size': 'B\u{00FC}y\u{00FC}k',
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
    _loadPublishedWalkers();
  }

  Future<void> _loadPublishedWalkers() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('walkers')
          .where('status', isEqualTo: 'active')
          .get();
      if (!mounted || snap.docs.isEmpty) return;
      final published = snap.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'name': data['name'] as String? ?? 'PatiParent gezdirici',
          'id': doc.id,
          'ownerUserId': data['ownerUserId'] as String? ?? doc.id,
          'city': data['city'] as String? ?? '',
          'district': data['district'] as String? ?? '',
          'breeds': const <String>['Kirma', 'Melez'],
          'ageRange': 'T\u{00FC}m ya\u{015F}lar',
          'sex': 'Fark etmez',
          'vaccineStatus': 'Fark etmez',
          'size': 'T\u{00FC}m boyutlar',
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'walks': data['walkCount'] as int? ?? 0,
          'price': data['pricePerHour'] as int? ?? 0,
          'badge': data['verificationStatus'] == 'verified'
              ? 'Kimlik do\u{011F}ruland\u{0131}'
              : 'Telefon onayl\u{0131}',
          'badges': (data['trustBadges'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(),
          'availability': data['availability'] as String? ?? '',
          'bio': data['bio'] as String? ?? '',
          'reviewCount': data['reviewCount'] as int? ?? 0,
          'responseTime': data['responseTime'] as String? ?? '2 saat i\u{00E7}inde',
          'repeatClientRate': data['repeatClientRate'] as int? ?? 72,
          'specialties': (data['specialties'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(),
          'safetyChecklist': (data['safetyChecklist'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(),
          'routeStyle': data['routeStyle'] as String? ?? 'Mahalle park\u{0131} ve sakin rota',
          'cancellationPolicy': data['cancellationPolicy'] as String? ?? '24 saat \u{00F6}nce \u{00FC}cretsiz iptal',
          'imageUrl': data['imageUrl'] as String? ??
              'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80',
        };
      }).toList();
      setState(() => _publishedWalkers = published);
    } catch (_) {
      // Demo listeyle devam edilir.
    }
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
      _district = 'T\u{00FC}m il\u{00E7}eler';
      _districts = districts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width > 860 ? 3 : (width > 560 ? 2 : 1);
    final sourceWalkers = _publishedWalkers.isEmpty ? _demoWalkers : _publishedWalkers;
    final filtered = sourceWalkers.where((walker) {
      final breeds = (walker['breeds'] as List<dynamic>).cast<String>();
      final cityOk = _city == 'All' || walker['city'] == _city;
      final districtOk =
          _district == 'T\u{00FC}m il\u{00E7}eler' || walker['district'] == _district;
      final breedOk = _breed == 'T\u{00FC}m cinsler' || breeds.contains(_breed);
      final ageOk =
          _ageRange == 'T\u{00FC}m ya\u{015F}lar' || walker['ageRange'] == _ageRange;
      final sexOk = _sex == 'Fark etmez' || walker['sex'] == _sex;
      final vaccineOk =
          _vaccineStatus == 'Fark etmez' ||
          walker['vaccineStatus'] == _vaccineStatus;
      final sizeOk = _size == 'T\u{00FC}m boyutlar' || walker['size'] == _size;
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
            breeds: _dogBreedOptions,
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
            'PatiGezdirme y\u{00FC}r\u{00FC}y\u{00FC}\u{015F} partnerleri',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Do\u011frulanm\u0131\u015f profiller, net uygunluk ve g\u{00FC}venli y\u{00FC}r\u{00FC}y\u{00FC}\u{015F} deneyimi.',
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
                childAspectRatio: width > 860 ? 0.74 : 0.78,
              ),
              itemBuilder: (context, index) {
                final walker = filtered[index];
                return _WalkerCard(
                  walkerId: walker['id'] as String? ?? 'demo-walker-',
                  walkerOwnerUserId: walker['ownerUserId'] as String? ?? 'demo-walker-owner',
                  name: walker['name'] as String,
                  city: walker['city'] as String,
                  district: walker['district'] as String? ?? '',
                  price: walker['price'] as int,
                  rating: walker['rating'] as double,
                  walks: walker['walks'] as int,
                  badge: walker['badge'] as String,
                  badges: (walker['badges'] as List<dynamic>? ?? const <dynamic>[])
                      .whereType<String>()
                      .toList(),
                  availability: walker['availability'] as String? ?? '',
                  bio: walker['bio'] as String? ?? '',
                  reviewCount: walker['reviewCount'] as int? ?? 0,
                  responseTime: walker['responseTime'] as String? ?? '2 saat i\u{00E7}inde',
                  repeatClientRate: walker['repeatClientRate'] as int? ?? 72,
                  specialties: (walker['specialties'] as List<dynamic>? ?? const <dynamic>[])
                      .whereType<String>()
                      .toList(),
                  safetyChecklist: (walker['safetyChecklist'] as List<dynamic>? ?? const <dynamic>[])
                      .whereType<String>()
                      .toList(),
                  routeStyle: walker['routeStyle'] as String? ?? 'Mahalle park\u{0131} ve sakin rota',
                  cancellationPolicy: walker['cancellationPolicy'] as String? ?? '24 saat \u{00F6}nce \u{00FC}cretsiz iptal',
                  imageUrl: walker['imageUrl'] as String,
                );
              },
            ),
        ],
      ),
    );
  }

  List<String> get _dogBreedOptions {
    if (_breedsByType.isEmpty) return const <String>[];
    for (final entry in _breedsByType.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('k\u00f6pek') || key.contains('kopek') || key.contains('pek')) {
        return entry.value;
      }
    }
    return _breedsByType.values.first;
  }
}

class _BadgeFilters extends StatelessWidget {
  const _BadgeFilters({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = ['All', 'Kimlik do\u{011F}ruland\u{0131}', 'Telefon onayl\u{0131}'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final active = item == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item == 'All' ? 'T\u{00FC}m\u{00FC}' : item),
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
              hintText: 'Gezdirici, \u{015E}ehir, rozet veya fiyat ara',
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FilterDropdown(
                  label: '\u{0130}l',
                  value: city,
                  items: ['All', ...cities],
                  labels: const {'All': 'T\u{00FC}m iller'},
                  onChanged: onCityChanged,
                ),
                _FilterDropdown(
                  label: '\u0130l\u00e7e',
                  value: districts.contains(district)
                      ? district
                      : 'T\u{00FC}m il\u{00E7}eler',
                  items: ['T\u{00FC}m il\u{00E7}eler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _FilterDropdown(
                  label: 'K\u{00F6}pek cinsi',
                  value: breeds.contains(breed) ? breed : 'T\u{00FC}m cinsler',
                  items: ['T\u{00FC}m cinsler', ...breeds],
                  onChanged: onBreedChanged,
                ),
                _FilterDropdown(
                  label: 'Yas',
                  value: ageRange,
                  items: const [
                    'T\u{00FC}m ya\u{015F}lar',
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
                  items: const ['Fark etmez', 'Di\u{015F}i', 'Erkek'],
                  onChanged: onSexChanged,
                ),
                _FilterDropdown(
                  label: 'A\u{015F}\u{0131} durumu',
                  value: vaccineStatus,
                  items: const ['Fark etmez', 'Tam', 'Eksik', 'Bilinmiyor'],
                  onChanged: onVaccineStatusChanged,
                ),
                _FilterDropdown(
                  label: 'Boyut',
                  value: size,
                  items: const ['T\u{00FC}m boyutlar', 'K\u{00FC}\u{00E7}\u{00FC}k', 'Orta', 'B\u{00FC}y\u{00FC}k'],
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
        'Bu filtrelere uygun gezdirici hen\u{00FC}z yok. \u{015E}ehir, il\u{00E7}e veya cinsi de\u{011F}i\u{015F}tirerek tekrar deneyebilirsin.',
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  const _WalkerCard({
    required this.walkerId,
    required this.walkerOwnerUserId,
    required this.name,
    required this.city,
    required this.district,
    required this.price,
    required this.rating,
    required this.walks,
    required this.badge,
    required this.badges,
    required this.availability,
    required this.bio,
    required this.reviewCount,
    required this.responseTime,
    required this.repeatClientRate,
    required this.specialties,
    required this.safetyChecklist,
    required this.routeStyle,
    required this.cancellationPolicy,
    required this.imageUrl,
  });

  final String walkerId;
  final String walkerOwnerUserId;
  final String name;
  final String city;
  final String district;
  final int price;
  final double rating;
  final int walks;
  final String badge;
  final List<String> badges;
  final String availability;
  final String bio;
  final int reviewCount;
  final String responseTime;
  final int repeatClientRate;
  final List<String> specialties;
  final List<String> safetyChecklist;
  final String routeStyle;
  final String cancellationPolicy;
  final String imageUrl;

  String get _location => [city, if (district.trim().isNotEmpty) district].join(' / ');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _openDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC0F172A)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _TrustPill(
                      icon: Icons.verified_rounded,
                      label: badge,
                      foreground: const Color(0xFF065F46),
                      background: const Color(0xFFE7F7F2),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _TrustPill(
                      icon: Icons.bolt_rounded,
                      label: responseTime,
                      foreground: const Color(0xFF92400E),
                      background: const Color(0xFFFFF7ED),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _location,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        ' ($reviewCount yorum)',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '$price TL/saat',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio.trim().isEmpty ? routeStyle : bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF475569), height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniChip(label: '$walks y\u{00FC}r\u{00FC}y\u{00FC}\u{015F}'),
                      _MiniChip(label: '%$repeatClientRate tekrar'),
                      if (specialties.isNotEmpty) _MiniChip(label: specialties.first),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.92;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, controller) => Container(
          constraints: BoxConstraints(maxHeight: sheetHeight),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              _ProfileHero(
                imageUrl: imageUrl,
                name: name,
                location: _location,
                badge: badge,
                rating: rating,
                reviewCount: reviewCount,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BookingPanel(
                      price: price,
                      availability: availability,
                      responseTime: responseTime,
                      cancellationPolicy: cancellationPolicy,
                      onRequest: () => _sendWalkRequest(context),
                    ),
                    const SizedBox(height: 14),
                    _ProfileSection(
                      title: 'Neden g\u{00FC}ven veriyor?',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in badges)
                            _TrustPill(
                              icon: Icons.verified_user_rounded,
                              label: item,
                              foreground: const Color(0xFF0F766E),
                              background: const Color(0xFFE7F7F2),
                            ),
                          _TrustPill(
                            icon: Icons.repeat_rounded,
                            label: '%$repeatClientRate tekrar eden m\u{00FC}\u{015F}teri',
                            foreground: const Color(0xFF1D4ED8),
                            background: const Color(0xFFEFF6FF),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileSection(
                      title: 'Profil \u{00F6}zeti',
                      child: Text(
                        bio.trim().isEmpty ? 'Bu gezdirici hen\u{00FC}z detayl\u{0131} a\u{00E7}\u{0131}klama eklemedi.' : bio,
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF334155),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileSection(
                      title: 'Y\u00fcr\u00fcy\u00fc\u015f yakla\u{015F}\u{0131}m\u{0131}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(icon: Icons.route_rounded, title: 'Rota', value: routeStyle),
                          _InfoRow(icon: Icons.schedule_rounded, title: 'Uygunluk', value: availability),
                          _InfoRow(icon: Icons.chat_bubble_rounded, title: 'Yan\u{0131}t', value: responseTime),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileSection(
                      title: 'Uzmanl\u{0131}klar',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: specialties.isEmpty
                            ? const [_MiniChip(label: 'Genel y\u{00FC}r\u{00FC}y\u{00FC}\u{015F}')]
                            : specialties.map((item) => _MiniChip(label: item)).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileSection(
                      title: 'G\u00fcvenlik checklist\u2019i',
                      child: Column(
                        children: (safetyChecklist.isEmpty
                                ? const ['Canl\u{0131} konum payla\u{015F}\u{0131}m\u{0131}', 'Su molas\u{0131} takibi', 'Y\u00fcr\u00fcy\u00fc\u015f sonras\u{0131} \u{00F6}zet']
                                : safetyChecklist)
                            .map((item) => _ChecklistRow(text: item))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: rating.toStringAsFixed(1),
                            label: 'puan',
                            icon: Icons.star_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            value: '$walks',
                            label: 'y\u{00FC}r\u{00FC}y\u{00FC}\u{015F}',
                            icon: Icons.directions_walk_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            value: '%$repeatClientRate',
                            label: 'tekrar',
                            icon: Icons.favorite_rounded,
                          ),
                        ),
                      ],
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

  Future<void> _sendWalkRequest(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    try {
      final dogDoc = await UserRepository().fetchMyDogDoc(user.uid);
      if (dogDoc == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talep i\u{00E7}in \u{00F6}nce pet profilini olu\u{015F}turmal\u{0131}s\u{0131}n.'),
          ),
        );
        return;
      }

      await ServicesRepository().createWalkRequest(
        requesterUserId: user.uid,
        requesterDogId: dogDoc.id,
        walkerId: walkerId,
        walkerOwnerUserId: walkerOwnerUserId,
        walkerName: name,
        preferredAt: DateTime.now().add(const Duration(days: 1)),
        note: 'PatiParent \u{00FC}zerinden gezdirme talebi.',
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gezdirme talebi g\u{00F6}nderildi.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep g\u{00F6}nderilemedi: $e')),
      );
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.badge,
    required this.rating,
    required this.reviewCount,
  });

  final String imageUrl;
  final String name;
  final String location;
  final String badge;
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xEE0F172A)],
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrustPill(
                  icon: Icons.verified_rounded,
                  label: badge,
                  foreground: const Color(0xFF065F46),
                  background: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${rating.toStringAsFixed(1)} puan',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      ' ? $reviewCount yorum',
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingPanel extends StatelessWidget {
  const _BookingPanel({
    required this.price,
    required this.availability,
    required this.responseTime,
    required this.cancellationPolicy,
    required this.onRequest,
  });

  final int price;
  final String availability;
  final String responseTime;
  final String cancellationPolicy;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$price TL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('/ saat', style: TextStyle(color: Color(0xFFCBD5E1))),
              ),
              const Spacer(),
              const Icon(Icons.shield_rounded, color: Color(0xFF86EFAC)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            availability.trim().isEmpty ? 'Uygunluk bilgisi profil sahibinden istenir.' : availability,
            style: const TextStyle(color: Color(0xFFE2E8F0), height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            '$responseTime yan\u{0131}t ? $cancellationPolicy',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF86EFAC),
                foregroundColor: const Color(0xFF052E16),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onRequest,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Gezdirme talebi g\u{00F6}nder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? 'Profil sahibinden teyit edilir.' : value,
                  style: const TextStyle(color: Color(0xFF475569), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}