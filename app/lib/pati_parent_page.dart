import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';
import 'data/services_repository.dart';
import 'data/user_repository.dart';
import 'login_page.dart';

class PatiParentPage extends StatefulWidget {
  const PatiParentPage({super.key});

  @override
  State<PatiParentPage> createState() => _PatiParentPageState();
}

class _PatiParentPageState extends State<PatiParentPage> {
  bool _filtersOpen = false;
  String _city = '\u0130stanbul';
  String _district = 'T\u00FCm il\u00E7eler';
  String _animalType = 'K\u00F6pek';
  String _breed = 'T\u00FCm cinsler';
  String _ageRange = 'T\u00FCm ya\u015Flar';
  String _sex = 'Fark etmez';
  String _vaccineStatus = 'Fark etmez';
  String _size = 'T\u00FCm boyutlar';
  String _searchQuery = '';
  List<String> _cities = const ['\u0130stanbul', 'Ankara', '\u0130zmir'];
  List<String> _districts = const [];
  Map<String, List<String>> _breedsByType = const {};
  List<Map<String, dynamic>> _publishedPosts = const <Map<String, dynamic>>[];

  static const List<Map<String, dynamic>> _familyPets = [
    {
      'id': 'family_demo_01',
      'dogName': 'Mavi',
      'city': '\u0130stanbul',
      'district': 'Kad\u0131k\u00F6y',
      'animalType': 'K\u00F6pek',
      'breed': 'Maltese',
      'ageMonths': 10,
      'ageRange': '0-1 ya\u015F',
      'sex': 'Di\u015Fi',
      'vaccineStatus': 'Tam',
      'size': 'K\u00FC\u00E7\u00FCk',
      'badge': 'Acil yuva',
      'bio':
          'Ev ortam\u0131na al\u0131\u015Fk\u0131n, oyuncu ve insan odakl\u0131 bir yavru. Sakin bir ailede h\u0131zla g\u00FCven kurar.',
      'ownerNote':
          'D\u00FCzenli veteriner takibi ve ilk ay yak\u0131n ileti\u015Fim bizim i\u00E7in \u00F6nemli.',
      'imageUrl': 'https://placedog.net/900/700?id=81',
      'ownerUserId': 'demo-family-owner-1',
      'trustBadges': ['A\u015F\u0131 kart\u0131', 'Sahip do\u011Fruland\u0131'],
      'careNeeds': [
        'G\u00FCnl\u00FCk k\u0131sa y\u00FCr\u00FCy\u00FC\u015F',
        'Sakin ev',
        '\u0130lk ay takip',
      ],
    },
    {
      'id': 'family_demo_02',
      'dogName': 'Tar\u00E7\u0131n',
      'city': 'Ankara',
      'district': '\u00C7ankaya',
      'animalType': 'K\u00F6pek',
      'breed': 'Golden Retriever',
      'ageMonths': 18,
      'ageRange': '1-3 ya\u015F',
      'sex': 'Erkek',
      'vaccineStatus': 'Tam',
      'size': 'Orta',
      'badge': 'Do\u011Frulanm\u0131\u015F',
      'bio':
          'Temel komutlar\u0131 biliyor, \u00E7ocuklarla kontroll\u00FC \u015Fekilde iyi anla\u015F\u0131yor. D\u00FCzenli y\u00FCr\u00FCy\u00FC\u015F ister.',
      'ownerNote':
          'Bah\u00E7eli ev tercihimiz var ama en \u00F6nemlisi sabit rutin ve sevgi dolu ortam.',
      'imageUrl': 'https://placedog.net/900/700?id=82',
      'ownerUserId': 'demo-family-owner-2',
      'trustBadges': ['A\u015F\u0131 kart\u0131', 'Sahiplendirme formu'],
      'careNeeds': [
        'Uzun y\u00FCr\u00FCy\u00FC\u015F',
        'Oyun rutini',
        'Deneyimli aile',
      ],
    },
    {
      'id': 'family_demo_03',
      'dogName': 'Boncuk',
      'city': '\u0130stanbul',
      'district': 'Be\u015Fikta\u015F',
      'animalType': 'Kedi',
      'breed': 'Tekir',
      'ageMonths': 14,
      'ageRange': '1-3 ya\u015F',
      'sex': 'Di\u015Fi',
      'vaccineStatus': 'Tam',
      'size': 'K\u00FC\u00E7\u00FCk',
      'badge': 'Ge\u00E7ici yuva',
      'bio':
          'Ev i\u00E7i ya\u015Fama al\u0131\u015Fk\u0131n, sakin ve insan\u0131n\u0131 se\u00E7ince \u00E7ok sevgi dolu bir Tekir. Sessiz bir evde h\u0131zl\u0131 uyum sa\u011Flar.',
      'ownerNote':
          'Cam ve balkon g\u00FCvenli\u011Fi olan, ilk hafta sab\u0131rl\u0131 yakla\u015Fabilecek bir aile ar\u0131yoruz.',
      'imageUrl':
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=1200&q=80',
      'ownerUserId': 'demo-family-owner-3',
      'trustBadges': [
        'A\u015F\u0131 kart\u0131',
        'K\u0131s\u0131r',
        'Sahiplendirme formu',
      ],
      'careNeeds': [
        'Cam/balkon g\u00FCvenli\u011Fi',
        'Sakin adaptasyon',
        'Kum rutini',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFilterData();
    _loadPublishedPosts();
  }

  Future<void> _loadPublishedPosts() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('adoption_posts')
          .where('status', isEqualTo: 'active')
          .get();
      if (!mounted || snap.docs.isEmpty) return;
      final posts = snap.docs.map((doc) {
        final data = doc.data();
        final ageMonths = data['ageMonths'] as int? ?? 0;
        return <String, dynamic>{
          'id': doc.id,
          'dogName': data['dogName'] as String? ?? 'Pati',
          'city': data['city'] as String? ?? '',
          'district': data['district'] as String? ?? '',
          'animalType': data['animalType'] as String? ?? 'K\u00F6pek',
          'breed': data['breed'] as String? ?? 'Melez',
          'ageMonths': ageMonths,
          'ageRange': _ageRangeFor(ageMonths),
          'sex': data['sex'] as String? ?? 'Fark etmez',
          'vaccineStatus': data['vaccinated'] == true ? 'Tam' : 'Bilinmiyor',
          'size': data['size'] as String? ?? 'Orta',
          'badge':
              data['urgency'] as String? ??
              (data['featured'] == true
                  ? 'Do\u011Frulanm\u0131\u015F'
                  : 'Yeni'),
          'bio': data['bio'] as String? ?? '',
          'ownerNote': data['ownerNote'] as String? ?? '',
          'ownerUserId': data['ownerUserId'] as String? ?? 'demo-owner',
          'imageUrl':
              data['imageUrl'] as String? ??
              'https://placedog.net/900/700?id=${doc.id.hashCode.abs() % 100}',
          'trustBadges':
              (data['trustBadges'] as List<dynamic>? ??
                      const <dynamic>[
                        'A\u015F\u0131 kart\u0131',
                        'Sahiplendirme formu',
                      ])
                  .whereType<String>()
                  .toList(),
          'careNeeds':
              (data['careNeeds'] as List<dynamic>? ??
                      const <dynamic>[
                        '\u0130lk ay takip',
                        'Sabit rutin',
                        'Veteriner kontrol\u00FC',
                      ])
                  .whereType<String>()
                  .toList(),
        };
      }).toList();
      setState(() => _publishedPosts = posts);
    } catch (_) {
      // Demo listeyle devam edilir.
    }
  }

  static String _ageRangeFor(int ageMonths) {
    if (ageMonths <= 12) return '0-1 ya\u015F';
    if (ageMonths <= 36) return '1-3 ya\u015F';
    if (ageMonths <= 84) return '3-7 ya\u015F';
    return '7+ ya\u015F';
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
      _district = 'T\u00FCm il\u00E7eler';
      _districts = districts;
    });
  }

  void _setAnimalType(String type) {
    setState(() {
      _animalType = type;
      _breed = 'T\u00FCm cinsler';
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final source = <Map<String, dynamic>>[..._publishedPosts, ..._familyPets];
    final filteredPets = source.where((pet) {
      final values = pet.values
          .map((v) => v.toString().toLowerCase())
          .join(' ');
      return (_city == 'All' || pet['city'] == _city) &&
          (_district == 'T\u00FCm il\u00E7eler' ||
              pet['district'] == _district) &&
          pet['animalType'] == _animalType &&
          (_breed == 'T\u00FCm cinsler' || pet['breed'] == _breed) &&
          (_ageRange == 'T\u00FCm ya\u015Flar' ||
              pet['ageRange'] == _ageRange) &&
          (_sex == 'Fark etmez' || pet['sex'] == _sex) &&
          (_vaccineStatus == 'Fark etmez' ||
              pet['vaccineStatus'] == _vaccineStatus) &&
          (_size == 'T\u00FCm boyutlar' || pet['size'] == _size) &&
          (query.isEmpty || values.contains(query));
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 860 ? 3 : (width > 560 ? 2 : 1);

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
            'PatiFamily yuva adaylar\u0131',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sahiplendirme s\u00FCreci i\u00E7in g\u00FCven, bak\u0131m ihtiyac\u0131 ve aile uyumu tek profilde.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          if (filteredPets.isEmpty)
            const _EmptyFamilyState()
          else
            GridView.builder(
              itemCount: filteredPets.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: width > 860 ? 0.78 : 0.86,
              ),
              itemBuilder: (context, index) =>
                  _FamilyPetCard(pet: filteredPets[index]),
            ),
        ],
      ),
    );
  }
}

class _FamilyPetCard extends StatelessWidget {
  const _FamilyPetCard({required this.pet});
  final Map<String, dynamic> pet;

  @override
  Widget build(BuildContext context) {
    final dogName = pet['dogName'] as String;
    final city = pet['city'] as String;
    final imageUrl = pet['imageUrl'] as String;
    final badge = pet['badge'] as String;
    final bio = pet['bio'] as String? ?? '';
    final ageMonths = pet['ageMonths'] as int? ?? 0;
    final size = pet['size'] as String? ?? 'Orta';
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
                        colors: [Colors.transparent, Color(0xCC1F2937)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _FamilyBadge(label: badge),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dogName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '$city · $size · $ageMonths ay',
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
                  Text(
                    bio,
                    maxLines: 3,
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
                      _FamilyChip(label: pet['breed'] as String? ?? 'Melez'),
                      _FamilyChip(
                        label: pet['vaccineStatus'] as String? ?? 'Bilinmiyor',
                      ),
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
    final trust = (pet['trustBadges'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList();
    final needs = (pet['careNeeds'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList();
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
            color: Color(0xFFFFFBEB),
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
                    Image.network(pet['imageUrl'] as String, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x22000000), Color(0xEE1F2937)],
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
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FamilyBadge(label: pet['badge'] as String),
                          const SizedBox(height: 12),
                          Text(
                            pet['dogName'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${pet['city']} · ${pet['breed']} · ${pet['ageMonths']} ay',
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
                    _FamilyActionPanel(
                      onApply: () => _sendApplication(context),
                    ),
                    const SizedBox(height: 14),
                    _FamilySection(
                      title: 'Yuva hikayesi',
                      child: Text(
                        pet['bio'] as String? ?? '',
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF334155),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FamilySection(
                      title: 'Sahip notu',
                      child: Text(
                        pet['ownerNote'] as String? ?? '',
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF334155),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FamilySection(
                      title: 'G\u00FCven sinyalleri',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: trust
                            .map((e) => _FamilyChip(label: e))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FamilySection(
                      title: 'Bak\u0131m ihtiya\u00E7lar\u0131',
                      child: Column(
                        children: needs
                            .map((e) => _FamilyChecklistRow(text: e))
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

  Future<void> _sendApplication(BuildContext context) async {
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
            content: Text(
              'Ba\u015Fvuru i\u00E7in \u00F6nce pet profilini olu\u015Fturmal\u0131s\u0131n.',
            ),
          ),
        );
        return;
      }
      await ServicesRepository().createAdoptionApplication(
        requesterUserId: user.uid,
        requesterDogId: dogDoc.id,
        postId: pet['id'] as String,
        dogName: pet['dogName'] as String,
        ownerUserId: pet['ownerUserId'] as String? ?? 'demo-owner',
        note: 'PatiFamily \u00FCzerinden sahiplenme ba\u015Fvurusu.',
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sahiplenme ba\u015Fvurusu g\u00F6nderildi.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ba\u015Fvuru g\u00F6nderilemedi: $e')),
      );
    }
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
              hintText: '\u0130lan, \u015Fehir, karakter veya durum ara',
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FamilyDrop(
                  label: '\u0130l',
                  value: city,
                  items: ['All', ...cities],
                  onChanged: onCityChanged,
                ),
                _FamilyDrop(
                  label: '\u0130l\u00E7e',
                  value: districts.contains(district)
                      ? district
                      : 'T\u00FCm il\u00E7eler',
                  items: ['T\u00FCm il\u00E7eler', ...districts],
                  onChanged: onDistrictChanged,
                ),
                _FamilyDrop(
                  label: 'Kedi / K\u00F6pek',
                  value: animalType,
                  items: const ['K\u00F6pek', 'Kedi'],
                  onChanged: onAnimalTypeChanged,
                ),
                _FamilyDrop(
                  label: '$animalType cinsi',
                  value: breeds.contains(breed) ? breed : 'T\u00FCm cinsler',
                  items: ['T\u00FCm cinsler', ...breeds],
                  onChanged: onBreedChanged,
                ),
                _FamilyDrop(
                  label: 'Ya\u015F',
                  value: ageRange,
                  items: const [
                    'T\u00FCm ya\u015Flar',
                    '0-1 ya\u015F',
                    '1-3 ya\u015F',
                    '3-7 ya\u015F',
                    '7+ ya\u015F',
                  ],
                  onChanged: onAgeChanged,
                ),
                _FamilyDrop(
                  label: 'Cinsiyet',
                  value: sex,
                  items: const ['Fark etmez', 'Di\u015Fi', 'Erkek'],
                  onChanged: onSexChanged,
                ),
                _FamilyDrop(
                  label: 'A\u015F\u0131',
                  value: vaccineStatus,
                  items: const ['Fark etmez', 'Tam', 'Eksik', 'Bilinmiyor'],
                  onChanged: onVaccineChanged,
                ),
                _FamilyDrop(
                  label: 'Boyut',
                  value: size,
                  items: const [
                    'T\u00FCm boyutlar',
                    'K\u00FC\u00E7\u00FCk',
                    'Orta',
                    'B\u00FCy\u00FCk',
                  ],
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
  Widget build(BuildContext context) => TextFormField(
    key: const ValueKey('family-filter-search'),
    initialValue: value,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search_rounded),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
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
  Widget build(BuildContext context) => SizedBox(
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

class _EmptyFamilyState extends StatelessWidget {
  const _EmptyFamilyState();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE7ECF3)),
    ),
    child: const Text(
      'Bu filtrelere uygun ilan hen\u00FCz yok. T\u00FCr, cins veya konum filtresini de\u011Fi\u015Ftirebilirsin.',
      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
    ),
  );
}

class _FamilyActionPanel extends StatelessWidget {
  const _FamilyActionPanel({required this.onApply});
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yuva ba\u015Fvurusu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ba\u015Fvurudan sonra sahip notlar\u0131 ve uyum s\u00FCreci Taleplerim ekran\u0131nda takip edilebilir.',
          style: TextStyle(color: Color(0xFFE2E8F0), height: 1.35),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFDE68A),
              foregroundColor: const Color(0xFF422006),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onApply,
            icon: const Icon(Icons.favorite_rounded),
            label: const Text('Sahiplenme ba\u015Fvurusu g\u00F6nder'),
          ),
        ),
      ],
    ),
  );
}

class _FamilySection extends StatelessWidget {
  const _FamilySection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFFDE68A)),
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

class _FamilyChecklistRow extends StatelessWidget {
  const _FamilyChecklistRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFFEAB308),
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

class _FamilyBadge extends StatelessWidget {
  const _FamilyBadge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFE11D48)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF881337),
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _FamilyChip extends StatelessWidget {
  const _FamilyChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFFFDE68A)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFF92400E),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
