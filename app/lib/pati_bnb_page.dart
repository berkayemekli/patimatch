import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';
import 'data/services_repository.dart';
import 'data/user_repository.dart';
import 'login_page.dart';
import 'widgets/no_results_rescue_card.dart';
import 'widgets/smart_pet_image.dart';

class PatiBnbPage extends StatefulWidget {
  const PatiBnbPage({super.key});

  @override
  State<PatiBnbPage> createState() => _PatiBnbPageState();
}

class _PatiBnbPageState extends State<PatiBnbPage> {
  bool _filtersOpen = false;
  String _city = 'İstanbul';
  String _district = 'Tüm ilçeler';
  String _animalType = 'K\u00f6pek';
  String _breed = 'Tüm cinsler';
  String _ageRange = 'Tüm yaşlar';
  String _sex = 'Fark etmez';
  String _vaccineStatus = 'Fark etmez';
  String _searchQuery = '';
  List<String> _cities = const ['İstanbul', 'Ankara', 'İzmir'];
  List<String> _districts = const [];
  Map<String, List<String>> _breedsByType = const {};
  List<Map<String, dynamic>> _publishedStays = const <Map<String, dynamic>>[];

  static const List<Map<String, dynamic>> _demoStays = [
    {
      'host': 'Can B.',
      'city': 'İstanbul',
      'district': 'Kadıköy',
      'ageRange': '1-3 yaş',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'nightlyPrice': 850,
      'rating': 4.93,
      'reviews': 128,
      'type': 'Bahçeli Ev',
      'badge': 'Super Host',
      'trustBadges': ['Kimlik doğrulandı', 'Ev ön kontrolü'],
      'petTypes': ['K\u00f6pek', 'Kedi'],
      'breeds': [
        'Golden Retriever',
        'Labrador Retriever',
        'British Shorthair',
        'Tekir',
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Aylin S.',
      'city': 'Ankara',
      'district': 'Çankaya',
      'ageRange': '0-1 yaş',
      'sex': 'Dişi',
      'vaccineStatus': 'Tam',
      'nightlyPrice': 620,
      'rating': 4.81,
      'reviews': 96,
      'type': 'Modern Daire',
      'badge': 'Verified',
      'trustBadges': ['Kimlik doğrulandı', 'Güvenli rezervasyon'],
      'petTypes': ['Kedi'],
      'breeds': [
        'British Shorthair',
        'Scottish Fold',
        'Tekir',
        'Sarman',
        'Van Kedisi',
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Nisa Y.',
      'city': 'Bursa',
      'district': 'Nilüfer',
      'ageRange': '1-3 yaş',
      'sex': 'Erkek',
      'vaccineStatus': 'Tam',
      'nightlyPrice': 780,
      'rating': 4.97,
      'reviews': 154,
      'type': 'Premium Home',
      'badge': 'Top Rated',
      'trustBadges': ['Kimlik doğrulandı', 'Ev ön kontrolü'],
      'petTypes': ['K\u00f6pek'],
      'breeds': ['Poodle', 'Maltese', 'Pomeranian', 'Cocker Spaniel'],
      'imageUrl':
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Deniz K.',
      'city': 'İzmir',
      'district': 'Karşıyaka',
      'ageRange': '3-7 yaş',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'nightlyPrice': 690,
      'rating': 4.88,
      'reviews': 110,
      'type': 'Loft Daire',
      'badge': 'Verified',
      'trustBadges': ['Kimlik doğrulandı'],
      'petTypes': ['Kedi'],
      'breeds': [
        'Siamese',
        'Persian',
        'Maine Coon',
        'Ragdoll',
        'Scottish Straight',
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Pelin A.',
      'city': 'Antalya',
      'district': 'Muratpaşa',
      'ageRange': '3-7 yaş',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Tam',
      'nightlyPrice': 920,
      'rating': 4.95,
      'reviews': 182,
      'type': 'Deniz Manzarali Ev',
      'badge': 'Top Rated',
      'trustBadges': ['Kimlik doğrulandı', 'Ev ön kontrolü'],
      'petTypes': ['K\u00f6pek', 'Kedi'],
      'breeds': [
        'Kangal',
        'Border Collie',
        'Golden Retriever',
        'Maine Coon',
        'Bengal',
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Emre T.',
      'city': 'İstanbul',
      'district': 'Beşiktaş',
      'ageRange': '0-1 yaş',
      'sex': 'Erkek',
      'vaccineStatus': 'Eksik',
      'nightlyPrice': 740,
      'rating': 4.84,
      'reviews': 99,
      'type': 'Şehir Evi',
      'badge': 'Super Host',
      'trustBadges': ['Kimlik doğrulandı', 'Güvenli rezervasyon'],
      'petTypes': ['K\u00f6pek'],
      'breeds': ['Beagle', 'French Bulldog', 'Pug', 'Shih Tzu'],
      'imageUrl':
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Sibel N.',
      'city': 'Muğla',
      'district': 'Bodrum',
      'ageRange': '7+ yaş',
      'sex': 'Dişi',
      'vaccineStatus': 'Fark etmez',
      'nightlyPrice': 980,
      'rating': 4.96,
      'reviews': 205,
      'type': 'Tas Villa',
      'badge': 'Top Rated',
      'trustBadges': ['Kimlik doğrulandı', 'Ev ön kontrolü'],
      'petTypes': ['Kedi'],
      'breeds': [
        'Van Kedisi',
        'Ankara Kedisi',
        'Russian Blue',
        'Norwegian Forest Cat',
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Barış L.',
      'city': 'İzmir',
      'district': 'Bornova',
      'ageRange': '1-3 yaş',
      'sex': 'Fark etmez',
      'vaccineStatus': 'Bilinmiyor',
      'nightlyPrice': 670,
      'rating': 4.79,
      'reviews': 88,
      'type': 'Bahçe Kat',
      'badge': 'Verified',
      'trustBadges': ['Kimlik doğrulandı'],
      'petTypes': ['K\u00f6pek', 'Kedi'],
      'breeds': ['K\u0131rma', 'Melez', 'Sokak kedisi', 'Tekir'],
      'imageUrl':
          'https://images.unsplash.com/photo-1572120360610-d971b9b63956?auto=format&fit=crop&w=1400&q=80',
    },
    {
      'host': 'Cansu P.',
      'city': 'İstanbul',
      'district': 'Şişli',
      'ageRange': '3-7 yaş',
      'sex': 'Dişi',
      'vaccineStatus': 'Tam',
      'nightlyPrice': 810,
      'rating': 4.91,
      'reviews': 141,
      'type': 'Teraslı Ev',
      'badge': 'Super Host',
      'trustBadges': ['Kimlik doğrulandı', 'Güvenli rezervasyon'],
      'petTypes': ['Kedi'],
      'breeds': ['Sphynx', 'Bengal', 'Scottish Fold', 'Domestic Shorthair'],
      'imageUrl':
          'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1400&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFilterData();
    _loadPublishedStays();
  }

  Future<void> _loadPublishedStays() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('bnb_hosts')
          .where('status', isEqualTo: 'active')
          .get();
      if (!mounted || snap.docs.isEmpty) return;
      final published = snap.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'host': data['name'] as String? ?? 'PatiBnB host',
          'id': doc.id,
          'ownerUserId': data['ownerUserId'] as String? ?? doc.id,
          'city': data['city'] as String? ?? '',
          'district': data['district'] as String? ?? '',
          'ageRange': 'T\u{00FC}m ya\u{015F}lar',
          'sex': 'Fark etmez',
          'vaccineStatus': 'Fark etmez',
          'nightlyPrice': data['nightlyPrice'] as int? ?? 0,
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'reviews': data['reviewCount'] as int? ?? 0,
          'type':
              data['homeType'] as String? ??
              (data['yard'] == true ? 'Bah\u{00E7}eli Ev' : 'Ev Konaklama'),
          'badge': data['verificationStatus'] == 'verified'
              ? 'Kimlik do\u{011F}ruland\u{0131}'
              : 'Telefon onayl\u{0131}',
          'trustBadges':
              (data['trustBadges'] as List<dynamic>? ??
                      const <dynamic>['Telefon onayl\u{0131}'])
                  .map((e) => e.toString())
                  .toList(),
          'petTypes':
              (data['petTypes'] as List<dynamic>? ??
                      const <dynamic>['K\u{00F6}pek', 'Kedi'])
                  .map((e) => e.toString())
                  .toList(),
          'breeds':
              (data['breeds'] as List<dynamic>? ??
                      const <dynamic>['K\u{0131}rma', 'Melez', 'Tekir'])
                  .map((e) => e.toString())
                  .toList(),
          'bio': data['bio'] as String? ?? '',
          'houseRules':
              (data['houseRules'] as List<dynamic>? ?? const <dynamic>[])
                  .map((e) => e.toString())
                  .toList(),
          'safetyFeatures':
              (data['safetyFeatures'] as List<dynamic>? ?? const <dynamic>[])
                  .map((e) => e.toString())
                  .toList(),
          'dailyRoutine': data['dailyRoutine'] as String? ?? '',
          'responseTime':
              data['responseTime'] as String? ?? '2 saat i\u{00E7}inde',
          'acceptedPetSize':
              data['acceptedPetSize'] as String? ??
              'K\u{00FC}\u{00E7}\u{00FC}k ve orta',
          'imageUrl':
              data['imageUrl'] as String? ??
              'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1400&q=80',
        };
      }).toList();
      setState(() => _publishedStays = published);
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
      _district = 'Tüm ilçeler';
      _districts = districts;
    });
  }

  void _setAnimalType(String type) {
    setState(() {
      _animalType = type;
      _breed = 'Tüm cinsler';
    });
  }

  Future<void> _clearFilters() async {
    final districts = await MasterDataRepository.loadDistricts('İstanbul');
    if (!mounted) return;
    setState(() {
      _filtersOpen = false;
      _city = 'Ä°stanbul';
      _district = 'Tüm ilçeler';
      _animalType = 'Köpek';
      _breed = 'Tüm cinsler';
      _ageRange = 'Tüm yaşlar';
      _sex = 'Fark etmez';
      _vaccineStatus = 'Fark etmez';
      _searchQuery = '';
      _districts = districts;
    });
  }

  void _showFlexibleStays() {
    setState(() {
      _filtersOpen = false;
      _district = 'Tüm ilçeler';
      _breed = 'Tüm cinsler';
      _ageRange = 'Tüm yaşlar';
      _sex = 'Fark etmez';
      _vaccineStatus = 'Fark etmez';
      _searchQuery = '';
    });
  }

  String _stayBio(Map<String, dynamic> stay) {
    final existing = stay['bio']?.toString().trim() ?? '';
    if (existing.isNotEmpty) return existing;
    final host = stay['host']?.toString() ?? 'Host';
    final city = stay['city']?.toString() ?? 'şehir';
    final type = stay['type']?.toString() ?? 'ev';
    return '$host, $city içinde pet misafirleri için sakin, temiz ve rutin odaklı bir $type deneyimi sunuyor. İlk tanışmada beslenme, uyku ve oyun alışkanlıkları birlikte netleştiriliyor.';
  }

  String _stayRoutine(Map<String, dynamic> stay) {
    final existing = stay['dailyRoutine']?.toString().trim() ?? '';
    if (existing.isNotEmpty) return existing;
    return 'Sabah kısa adaptasyon yürüyüşü, gün içinde fotoğraflı durum paylaşımı, akşam sakin oyun ve beslenme kontrolü.';
  }

  List<String> _stayRules(Map<String, dynamic> stay) {
    final existing = (stay['houseRules'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (existing.isNotEmpty) return existing;
    return const [
      'Aşı kartı ve temel sağlık bilgisi istenir',
      'İlk rezervasyonda kısa tanışma görüşmesi yapılır',
      'Beslenme ve ilaç rutini yazılı alınır',
    ];
  }

  List<String> _staySafety(Map<String, dynamic> stay) {
    final existing =
        (stay['safetyFeatures'] as List<dynamic>? ?? const <dynamic>[])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
    if (existing.isNotEmpty) return existing;
    return const [
      'Ayrı dinlenme alanı',
      'Güvenli kapı ve pencere kontrolü',
      'Yakın veteriner planı',
    ];
  }

  String _stayResponseTime(Map<String, dynamic> stay) {
    final existing = stay['responseTime']?.toString().trim() ?? '';
    return existing.isEmpty ? '2 saat içinde' : existing;
  }

  String _stayAcceptedPetSize(Map<String, dynamic> stay) {
    final existing = stay['acceptedPetSize']?.toString().trim() ?? '';
    return existing.isEmpty ? 'Küçük ve orta' : existing;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 860 ? 3 : (width > 560 ? 2 : 1);
    final sourceStays = <Map<String, dynamic>>[
      ..._publishedStays,
      ..._demoStays,
    ];
    final filteredStays = sourceStays.where((stay) {
      final petTypes = (stay['petTypes'] as List<dynamic>).cast<String>();
      final breeds = (stay['breeds'] as List<dynamic>).cast<String>();
      final cityOk = _city == 'All' || stay['city'] == _city;
      final districtOk =
          _district == 'Tüm ilçeler' || stay['district'] == _district;
      final animalOk = petTypes.contains(_animalType);
      final breedOk = _breed == 'Tüm cinsler' || breeds.contains(_breed);
      final ageOk = _ageRange == 'Tüm yaşlar' || stay['ageRange'] == _ageRange;
      final sexOk = _sex == 'Fark etmez' || stay['sex'] == _sex;
      final vaccineOk =
          _vaccineStatus == 'Fark etmez' ||
          stay['vaccineStatus'] == _vaccineStatus;
      final query = _searchQuery.trim().toLowerCase();
      final searchOk =
          query.isEmpty ||
          [
            stay['host'],
            stay['city'],
            stay['district'],
            stay['type'],
            stay['badge'],
            stay['ageRange'],
            stay['sex'],
            stay['vaccineStatus'],
            stay['nightlyPrice'],
            ...petTypes,
            ...breeds,
          ].any((value) => value.toString().toLowerCase().contains(query));
      return cityOk &&
          districtOk &&
          animalOk &&
          breedOk &&
          ageOk &&
          sexOk &&
          vaccineOk &&
          searchOk;
    }).toList();

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
            onSearchChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 24),
          if (filteredStays.isEmpty)
            _EmptyStayState(
              onClearFilters: _clearFilters,
              onShowFlexible: _showFlexibleStays,
            )
          else
            GridView.builder(
              itemCount: filteredStays.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: width > 860 ? 0.76 : 0.82,
              ),
              itemBuilder: (context, index) {
                final stay = filteredStays[index];
                return _StayCard(
                  hostId: stay['id'] as String? ?? 'demo-host-$index',
                  hostOwnerUserId:
                      stay['ownerUserId'] as String? ?? 'demo-host-owner',
                  host: stay['host'] as String,
                  city: stay['city'] as String,
                  nightlyPrice: stay['nightlyPrice'] as int,
                  rating: stay['rating'] as double,
                  reviews: stay['reviews'] as int,
                  type: stay['type'] as String,
                  badge: stay['badge'] as String,
                  petTypes: (stay['petTypes'] as List<dynamic>).cast<String>(),
                  breeds: (stay['breeds'] as List<dynamic>).cast<String>(),
                  trustBadges: (stay['trustBadges'] as List<dynamic>)
                      .cast<String>(),
                  bio: _stayBio(stay),
                  houseRules: _stayRules(stay),
                  safetyFeatures: _staySafety(stay),
                  dailyRoutine: _stayRoutine(stay),
                  responseTime: _stayResponseTime(stay),
                  acceptedPetSize: _stayAcceptedPetSize(stay),
                  imageUrl: stay['imageUrl'] as String,
                );
              },
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
            _BnbSearchField(
              value: searchQuery,
              hintText: 'Ev sahibi, şehir, ev tipi veya cins ara',
              onChanged: onSearchChanged,
            ),
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
                      : 'Tüm ilçeler',
                  items: ['Tüm ilçeler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _BnbDrop(
                  label: 'Kedi / K\u00f6pek',
                  value: animalType,
                  items: const ['K\u00f6pek', 'Kedi'],
                  onChanged: onAnimalTypeChanged,
                ),
                _BnbDrop(
                  label: '$animalType cinsi',
                  value: breeds.contains(breed) ? breed : 'Tüm cinsler',
                  items: ['Tüm cinsler', ...breeds],
                  onChanged: onBreedChanged,
                ),
                _BnbDrop(
                  label: 'Yaş',
                  value: ageRange,
                  items: const [
                    'Tüm yaşlar',
                    '0-1 yaş',
                    '1-3 yaş',
                    '3-7 yaş',
                    '7+ yaş',
                  ],
                  onChanged: onAgeChanged,
                ),
                _BnbDrop(
                  label: 'Cinsiyet',
                  value: sex,
                  items: const ['Fark etmez', 'Dişi', 'Erkek'],
                  onChanged: onSexChanged,
                ),
                _BnbDrop(
                  label: 'Aşı',
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

class _BnbSearchField extends StatelessWidget {
  const _BnbSearchField({
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
      key: const ValueKey('bnb-filter-search'),
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
        key: ValueKey('$label-$value-${items.length}'),
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

class _EmptyStayState extends StatelessWidget {
  const _EmptyStayState({
    required this.onClearFilters,
    required this.onShowFlexible,
  });

  final VoidCallback onClearFilters;
  final VoidCallback onShowFlexible;

  @override
  Widget build(BuildContext context) {
    return NoResultsRescueCard(
      title: 'Bu filtrelerle uygun konaklama bulamad?k',
      message:
          'Pet t?r?, cins veya konum filtresini yumu?atarak daha fazla g?venilir host g?sterebiliriz.',
      suggestion:
          '?neri: ?lk aramada t?m cinsler ve t?m il?elerle bak; ev kurallar? ve uygunlu?u detay panelinde kar??la?t?r.',
      primaryActionLabel: 'Filtreleri temizle',
      onPrimaryAction: onClearFilters,
      secondaryActionLabel: 'Esnek konaklamalar? g?ster',
      onSecondaryAction: onShowFlexible,
      accentColor: const Color(0xFFF97316),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({
    required this.hostId,
    required this.hostOwnerUserId,
    required this.host,
    required this.city,
    required this.nightlyPrice,
    required this.rating,
    required this.reviews,
    required this.type,
    required this.badge,
    required this.petTypes,
    required this.breeds,
    required this.trustBadges,
    required this.bio,
    required this.houseRules,
    required this.safetyFeatures,
    required this.dailyRoutine,
    required this.responseTime,
    required this.acceptedPetSize,
    required this.imageUrl,
  });

  final String hostId;
  final String hostOwnerUserId;
  final String host;
  final String city;
  final int nightlyPrice;
  final double rating;
  final int reviews;
  final String type;
  final String badge;
  final List<String> petTypes;
  final List<String> breeds;
  final List<String> trustBadges;
  final String bio;
  final List<String> houseRules;
  final List<String> safetyFeatures;
  final String dailyRoutine;
  final String responseTime;
  final String acceptedPetSize;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _openStayDetails(context),
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
                  SmartPetImage(source: imageUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC111827)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _CardTrustBadge(label: badge),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          host,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$type · $city',
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
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        ' ($reviews yorum)',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$nightlyPrice TL/gece',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio.trim().isEmpty ? dailyRoutine : bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniTrustChip(label: acceptedPetSize),
                      if (petTypes.isNotEmpty)
                        _MiniTrustChip(label: petTypes.join(' + ')),
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

  void _openStayDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7ED),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SmartPetImage(source: imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x22000000), Color(0xEE111827)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CardTrustBadge(label: badge),
                          const SizedBox(height: 12),
                          Text(
                            host,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$type · $city',
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BnbBookingPanel(
                      price: nightlyPrice,
                      responseTime: responseTime,
                      acceptedPetSize: acceptedPetSize,
                      onRequest: (checkIn, checkOut) =>
                          _sendBnbRequest(context, checkIn, checkOut),
                    ),
                    const SizedBox(height: 14),
                    _BnbProfileSection(
                      title: 'Ev güven profili',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: trustBadges
                            .map((label) => _MiniTrustChip(label: label))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BnbProfileSection(
                      title: 'Host açıklaması',
                      child: Text(
                        bio.trim().isEmpty
                            ? 'Host henüz detaylı açıklama eklemedi.'
                            : bio,
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF334155),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BnbProfileSection(
                      title: 'Günlük rutin',
                      child: Text(
                        dailyRoutine.trim().isEmpty
                            ? 'Beslenme, yürüyüş ve dinlenme rutini talepte netleştirilir.'
                            : dailyRoutine,
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF334155),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BnbProfileSection(
                      title: 'Ev kuralları',
                      child: Column(
                        children:
                            (houseRules.isEmpty
                                    ? const [
                                        'Ön görüşme ile kabul',
                                        'Aşı kartı istenir',
                                        'Günlük fotoğraf paylaşımı',
                                      ]
                                    : houseRules)
                                .map((item) => _BnbChecklistRow(text: item))
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BnbProfileSection(
                      title: 'Güvenlik özellikleri',
                      child: Column(
                        children:
                            (safetyFeatures.isEmpty
                                    ? const [
                                        'Ayrı dinlenme alanı',
                                        'Acil veteriner iletişimi',
                                        'Güvenli kapı/pencere kontrolü',
                                      ]
                                    : safetyFeatures)
                                .map((item) => _BnbChecklistRow(text: item))
                                .toList(),
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

  Future<void> _sendBnbRequest(
    BuildContext context,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    try {
      final dogDoc = await UserRepository().fetchMyDogDoc(user.uid);
      if (dogDoc == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talep için önce pet profilini oluşturmalısın.'),
          ),
        );
        return;
      }
      await ServicesRepository().createBnbRequest(
        requesterUserId: user.uid,
        requesterDogId: dogDoc.id,
        hostId: hostId,
        hostOwnerUserId: hostOwnerUserId,
        hostName: host,
        checkIn: checkIn,
        checkOut: checkOut,
        note: 'PatiParent üzerinden konaklama talebi.',
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konaklama talebi gönderildi.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Talep gönderilemedi: $e')));
    }
  }
}

class _BnbBookingPanel extends StatefulWidget {
  const _BnbBookingPanel({
    required this.price,
    required this.responseTime,
    required this.acceptedPetSize,
    required this.onRequest,
  });
  final int price;
  final String responseTime;
  final String acceptedPetSize;
  final void Function(DateTime checkIn, DateTime checkOut) onRequest;

  @override
  State<_BnbBookingPanel> createState() => _BnbBookingPanelState();
}

class _BnbBookingPanelState extends State<_BnbBookingPanel> {
  late DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  late DateTime _checkOut = DateTime.now().add(const Duration(days: 8));

  int get _nights {
    final nights = _checkOut.difference(_checkIn).inDays;
    return nights < 1 ? 1 : nights;
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked.start;
        _checkOut = picked.end.isAfter(picked.start)
            ? picked.end
            : picked.start.add(const Duration(days: 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final checkInText = localizations.formatMediumDate(_checkIn);
    final checkOutText = localizations.formatMediumDate(_checkOut);
    final total = widget.price * _nights;
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
            children: [
              Text(
                '${widget.price} TL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              const Text('/ gece', style: TextStyle(color: Color(0xFFCBD5E1))),
              const Spacer(),
              const Icon(Icons.home_work_rounded, color: Color(0xFFFDBA74)),
            ],
          ),
          const SizedBox(height: 12),
          _BnbDateRangeTile(
            checkInText: checkInText,
            checkOutText: checkOutText,
            nights: _nights,
            onTap: _pickRange,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.acceptedPetSize} kabul • ${widget.responseTime} yanıt',
            style: const TextStyle(color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 4),
          Text(
            'Tahmini toplam: $total TL / $_nights gece',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFDBA74),
                foregroundColor: const Color(0xFF431407),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => widget.onRequest(_checkIn, _checkOut),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Rezervasyon talebi gönder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BnbDateRangeTile extends StatelessWidget {
  const _BnbDateRangeTile({
    required this.checkInText,
    required this.checkOutText,
    required this.nights,
    required this.onTap,
  });

  final String checkInText;
  final String checkOutText;
  final int nights;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: Color(0xFFFDBA74)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giriş - çıkış',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  '$checkInText → $checkOutText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$nights gece',
            style: const TextStyle(
              color: Color(0xFFFED7AA),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _BnbProfileSection extends StatelessWidget {
  const _BnbProfileSection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFED7AA)),
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

class _BnbChecklistRow extends StatelessWidget {
  const _BnbChecklistRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFF97316),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTrustBadge extends StatelessWidget {
  const _CardTrustBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_rounded,
              size: 14,
              color: Color(0xFF0F766E),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTrustChip extends StatelessWidget {
  const _MiniTrustChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC2410C),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
