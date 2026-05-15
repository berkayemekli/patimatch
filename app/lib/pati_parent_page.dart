import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';

class PatiParentPage extends StatefulWidget {
  const PatiParentPage({super.key});

  @override
  State<PatiParentPage> createState() => _PatiParentPageState();
}

class _PatiParentPageState extends State<PatiParentPage> {
  bool _filtersOpen = false;
  String _city = 'Istanbul';
  String _district = 'Tum ilceler';
  String _animalType = 'K\u00f6pek';
  String _breed = 'Tum cinsler';
  String _ageRange = 'Tum yaslar';
  String _sex = 'Fark etmez';
  String _vaccineStatus = 'Fark etmez';
  String _size = 'Tum boyutlar';
  String _searchQuery = '';
  List<String> _cities = const ['Istanbul', 'Ankara', 'Izmir'];
  List<String> _districts = const [];
  Map<String, List<String>> _breedsByType = const {};
  List<Map<String, String>> _familyPets = _defaultFamilyPets;

  static const List<Map<String, String>> _defaultFamilyPets = [
    {
      'title': 'Mavi - Istanbul',
      'subtitle': '10 ay - Kucuk - Asili - Oyuncu karakter',
      'badge': 'Acil Yuva',
      'city': 'Istanbul',
      'district': 'Kadikoy',
      'animalType': 'K\u00f6pek',
      'breed': 'Maltese',
      'ageRange': '0-1 yas',
      'sex': 'Disi',
      'vaccineStatus': 'Tam',
      'size': 'Kucuk',
      'urgency': 'Acil yuva',
      'ownerType': 'Gecici yuva',
      'trust': 'Asili, kimlik dogrulandi',
      'fit': 'Apartman yasamina uygun',
    },
    {
      'title': 'Tarcin - Ankara',
      'subtitle': '18 ay - Orta - Asili - Cocuklarla uyumlu',
      'badge': 'Dogrulanmis',
      'city': 'Ankara',
      'district': 'Cankaya',
      'animalType': 'K\u00f6pek',
      'breed': 'Golden Retriever',
      'ageRange': '1-3 yas',
      'sex': 'Erkek',
      'vaccineStatus': 'Tam',
      'size': 'Orta',
      'urgency': 'Aile araniyor',
      'ownerType': 'Bireysel ilan',
      'trust': 'Veteriner referansi, takip gorusmesi',
      'fit': 'Cocuklarla uyumlu',
    },
    {
      'title': 'Boncuk - Bursa',
      'subtitle': '14 ay - Kucuk - Sakin ev ortami sever',
      'badge': 'Yeni',
      'city': 'Bursa',
      'district': 'Nilufer',
      'animalType': 'Kedi',
      'breed': 'Tekir',
      'ageRange': '1-3 yas',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Bilinmiyor',
      'size': 'Kucuk',
      'urgency': 'Gecici yuva',
      'ownerType': 'Gonullu ilan',
      'trust': 'Sahiplendirme formu',
      'fit': 'Sakin ev ortami',
    },
    {
      'title': 'Luna - Izmir',
      'subtitle': '2 yas - Orta - Tuvalet egitimli',
      'badge': 'Uygun',
      'city': 'Izmir',
      'district': 'Karsiyaka',
      'animalType': 'Kedi',
      'breed': 'Scottish Fold',
      'ageRange': '1-3 yas',
      'sex': 'Disi',
      'vaccineStatus': 'Eksik',
      'size': 'Orta',
      'urgency': 'Uygun aile',
      'ownerType': 'Bireysel ilan',
      'trust': 'Tuvalet egitimi, takip gorusmesi',
      'fit': 'Ev egitimli',
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
    final seedPets = _buildSeedFamilyPets(
      examples['familyListings'] as List<dynamic>?,
    );
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _breedsByType = breeds;
      _districts = districts;
      final seedTitles = seedPets.map((pet) => pet['title']).toSet();
      final remainingDefaults = _defaultFamilyPets
          .where((pet) => !seedTitles.contains(pet['title']))
          .toList();
      _familyPets = <Map<String, String>>[...seedPets, ...remainingDefaults];
    });
  }

  List<Map<String, String>> _buildSeedFamilyPets(List<dynamic>? rawListings) {
    if (rawListings == null) return const [];
    return rawListings.whereType<Map<String, dynamic>>().map((pet) {
      final petName = pet['petName']?.toString() ?? 'Yeni ilan';
      final city = pet['city']?.toString() ?? 'Istanbul';
      final type = _normalizePetType(pet['type']?.toString() ?? 'K\u00f6pek');
      final breed = pet['breed']?.toString() ?? 'K\u0131rma';
      final urgency = pet['urgency']?.toString() ?? 'Aile araniyor';
      final badges = (pet['badges'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
      return <String, String>{
        'title': '$petName - $city',
        'subtitle': '$breed - $urgency - ${badges.take(2).join(', ')}',
        'badge': urgency,
        'city': city,
        'district': _seedDistrict(city),
        'animalType': type,
        'breed': breed,
        'ageRange': type == 'Kedi' ? '1-3 yas' : '0-1 yas',
        'sex': 'Fark etmez',
        'vaccineStatus': badges.any(
          (badge) => badge.toLowerCase().contains('asi'),
        )
            ? 'Tam'
            : 'Fark etmez',
        'size': 'Kucuk',
        'urgency': urgency,
        'ownerType': urgency.toLowerCase().contains('gecici')
            ? 'Gecici yuva'
            : 'Sahiplendirme',
        'trust': badges.isEmpty ? 'Sahiplendirme formu' : badges.join(', '),
        'fit': type == 'Kedi' ? 'Sakin ev ortami' : 'Apartman yasamina uygun',
      };
    }).toList();
  }

  String _normalizePetType(String value) {
    final lower = value.toLowerCase();
    if (lower == 'kopek' || lower == 'k\u00f6pek') return 'K\u00f6pek';
    if (lower == 'kedi') return 'Kedi';
    return value;
  }

  String _seedDistrict(String city) {
    switch (city) {
      case 'Istanbul':
        return 'Kadikoy';
      case 'Bursa':
        return 'Nilufer';
      default:
        return 'Merkez';
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

  void _setAnimalType(String type) {
    setState(() {
      _animalType = type;
      _breed = 'Tum cinsler';
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredPets = _familyPets.where((pet) {
      final cityOk = _city == 'All' || pet['city'] == _city;
      final districtOk =
          _district == 'Tum ilceler' || pet['district'] == _district;
      final animalOk = pet['animalType'] == _animalType;
      final breedOk = _breed == 'Tum cinsler' || pet['breed'] == _breed;
      final ageOk = _ageRange == 'Tum yaslar' || pet['ageRange'] == _ageRange;
      final sexOk = _sex == 'Fark etmez' || pet['sex'] == _sex;
      final vaccineOk =
          _vaccineStatus == 'Fark etmez' ||
          pet['vaccineStatus'] == _vaccineStatus;
      final sizeOk = _size == 'Tum boyutlar' || pet['size'] == _size;
      final searchOk =
          query.isEmpty ||
          pet.values.any((value) => value.toLowerCase().contains(query));
      return cityOk &&
          districtOk &&
          animalOk &&
          breedOk &&
          ageOk &&
          sexOk &&
          vaccineOk &&
          sizeOk &&
          searchOk;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FamilyFilterBar(
            filtersOpen: _filtersOpen,
            city: _city,
            district: _district,
            animalType: _animalType,
            breed: _breed,
            ageRange: _ageRange,
            sex: _sex,
            vaccineStatus: _vaccineStatus,
            size: _size,
            searchQuery: _searchQuery,
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
            onSizeChanged: (v) => setState(() => _size = v),
            onSearchChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 16),
          const Text(
            'PatiFamily ilanlari',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (filteredPets.isEmpty)
            const _EmptyFamilyState()
          else
            for (final pet in filteredPets) ...[
              _FamilyListingCard(
                title: pet['title']!,
                subtitle: pet['subtitle']!,
                badge: pet['badge']!,
                urgency: pet['urgency']!,
                ownerType: pet['ownerType']!,
                trust: pet['trust']!,
                fit: pet['fit']!,
                city: pet['city']!,
                district: pet['district']!,
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _FamilyFilterBar extends StatelessWidget {
  const _FamilyFilterBar({
    required this.filtersOpen,
    required this.city,
    required this.district,
    required this.animalType,
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
    required this.onAnimalTypeChanged,
    required this.onBreedChanged,
    required this.onAgeChanged,
    required this.onSexChanged,
    required this.onVaccineChanged,
    required this.onSizeChanged,
    required this.onSearchChanged,
  });

  final bool filtersOpen;
  final String city;
  final String district;
  final String animalType;
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
  final ValueChanged<String> onAnimalTypeChanged;
  final ValueChanged<String> onBreedChanged;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String> onSexChanged;
  final ValueChanged<String> onVaccineChanged;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<String> onSearchChanged;

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
            _FamilySearchField(
              value: searchQuery,
              hintText: 'Ilan, sehir, karakter veya durum ara',
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FamilyDrop(
                  label: 'Il',
                  value: city,
                  items: ['All', ...cities],
                  onChanged: onCityChanged,
                ),
                _FamilyDrop(
                  label: 'Ilce',
                  value: districts.contains(district)
                      ? district
                      : 'Tum ilceler',
                  items: ['Tum ilceler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _FamilyDrop(
                  label: 'Kedi / K\u00f6pek',
                  value: animalType,
                  items: const ['K\u00f6pek', 'Kedi'],
                  onChanged: onAnimalTypeChanged,
                ),
                _FamilyDrop(
                  label: '$animalType cinsi',
                  value: breeds.contains(breed) ? breed : 'Tum cinsler',
                  items: ['Tum cinsler', ...breeds],
                  onChanged: onBreedChanged,
                ),
                _FamilyDrop(
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
                _FamilyDrop(
                  label: 'Cinsiyet',
                  value: sex,
                  items: const ['Fark etmez', 'Disi', 'Erkek'],
                  onChanged: onSexChanged,
                ),
                _FamilyDrop(
                  label: 'Asi',
                  value: vaccineStatus,
                  items: const ['Fark etmez', 'Tam', 'Eksik', 'Bilinmiyor'],
                  onChanged: onVaccineChanged,
                ),
                _FamilyDrop(
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

class _FamilySearchField extends StatelessWidget {
  const _FamilySearchField({
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
      key: const ValueKey('family-filter-search'),
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

class _FamilyDrop extends StatelessWidget {
  const _FamilyDrop({
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
        key: ValueKey('$label-$value-${items.length}'),
        initialValue: items.contains(value) ? value : items.first,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _EmptyFamilyState extends StatelessWidget {
  const _EmptyFamilyState();

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
        'Bu filtrelere uygun ilan henuz yok. Tur, cins veya konum filtresini degistirebilirsin.',
        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FamilyListingCard extends StatelessWidget {
  const _FamilyListingCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.urgency,
    required this.ownerType,
    required this.trust,
    required this.fit,
    required this.city,
    required this.district,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String urgency;
  final String ownerType;
  final String trust;
  final String fit;
  final String city;
  final String district;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _openDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7ECF3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _FamilyPill(label: badge, emphasized: true),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _FamilyPill(label: ownerType),
                      _FamilyPill(label: fit),
                      _FamilyPill(label: '$city / $district'),
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
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FamilyPill(label: urgency, emphasized: true),
                _FamilyPill(label: ownerType),
                _FamilyPill(label: '$city / $district'),
              ],
            ),
            const SizedBox(height: 18),
            _FamilyDetailLine(icon: Icons.verified_rounded, text: trust),
            const SizedBox(height: 10),
            _FamilyDetailLine(icon: Icons.home_rounded, text: fit),
            const SizedBox(height: 10),
            const _FamilyDetailLine(
              icon: Icons.assignment_turned_in_rounded,
              text: 'Sahiplendirme formu ve takip gorusmesi onerilir',
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyPill extends StatelessWidget {
  const _FamilyPill({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFFFEEF3) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized ? const Color(0xFFFBC7D3) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: emphasized ? const Color(0xFFE11D48) : const Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FamilyDetailLine extends StatelessWidget {
  const _FamilyDetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE11D48)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
