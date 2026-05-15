import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_strings.dart';
import 'data/analytics/analytics_repository.dart';
import 'data/master_data/master_data_repository.dart';
import 'main_shell_page.dart';
import 'pet_taxonomy.dart';

class DogProfilePage extends StatefulWidget {
  const DogProfilePage({super.key});

  @override
  State<DogProfilePage> createState() => _DogProfilePageState();
}

class _PetProfileSnapshot {
  const _PetProfileSnapshot({required this.id, required this.data});

  final String? id;
  final Map<String, dynamic> data;
}

class _DogProfilePageState extends State<DogProfilePage> {
  final _accountNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _passportCodeController = TextEditingController();
  final _microchipController = TextEditingController();
  final _colorController = TextEditingController();
  final _temperamentController = TextEditingController();
  final _healthNotesController = TextEditingController();
  String _animalCategory = 'Kopek';
  bool _manualDistrict = false;
  String _sex = 'female';
  String _activityLevel = 'medium';
  bool _isNeutered = false;
  bool _isVaccinated = false;
  bool _friendlyWithDogs = true;
  bool _friendlyWithKids = true;
  bool _saving = false;
  Uint8List? _imageBytes;
  String _status = '';
  bool _loading = true;
  String? _existingDogId;
  String? _existingPhotoUrl;
  String? _starterPhotoAsset;
  String _accountEmail = '';
  final List<String> _cityOptions = PetTaxonomy.turkiyeSehirleri;
  List<String> _dynamicCityOptions = <String>[];
  List<String> _dynamicDistrictOptions = <String>[];
  Map<String, List<String>> _dynamicBreeds = <String, List<String>>{};
  Map<String, List<String>> _vaccines = <String, List<String>>{};
  final Set<String> _selectedVaccines = <String>{};
  String _vaccineStatus = 'Bilinmiyor';
  String _normalizeCategory(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized == 'kopek' || normalized.endsWith('pek')) return 'Kopek';
    if (normalized == 'kedi') return 'Kedi';
    return input;
  }
  final Set<String> _selectedTraits = <String>{};
  final List<String> _traitOptions = const <String>[
    'Oyuncu', 'Sakin', 'Sosyal', 'Egitilebilir', 'Koruyucu', 'Enerjik'
  ];

  List<String> _missingFields() {
    final missing = <String>[];
    if (_nameController.text.trim().isEmpty) missing.add('Ad');
    if (_breedController.text.trim().isEmpty) missing.add('Irk');
    if ((int.tryParse(_ageController.text.trim()) ?? 0) <= 0) missing.add('Yas');
    if ((int.tryParse(_weightController.text.trim()) ?? 0) <= 0) missing.add('Kilo');
    if (_cityController.text.trim().isEmpty) missing.add('Sehir');
    if (_passportCodeController.text.trim().isEmpty) missing.add('Pasaport');
    if ((_imageBytes == null) &&
        (_existingPhotoUrl == null) &&
        (_starterPhotoAsset == null)) {
      missing.add('Fotograf');
    }
    return missing;
  }

  int _profileCompletionPercent() {
    const total = 12;
    int filled = 0;
    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_breedController.text.trim().isNotEmpty) filled++;
    if ((int.tryParse(_ageController.text.trim()) ?? 0) > 0) filled++;
    if ((int.tryParse(_weightController.text.trim()) ?? 0) > 0) filled++;
    if (_cityController.text.trim().isNotEmpty) filled++;
    if (_passportCodeController.text.trim().isNotEmpty) filled++;
    if (_microchipController.text.trim().isNotEmpty) filled++;
    if (_colorController.text.trim().isNotEmpty) filled++;
    if (_temperamentController.text.trim().isNotEmpty) filled++;
    if (_healthNotesController.text.trim().isNotEmpty) filled++;
    if (_sex.isNotEmpty) filled++;
    if ((_imageBytes != null) ||
        (_existingPhotoUrl != null) ||
        (_starterPhotoAsset != null)) {
      filled++;
    }
    return ((filled / total) * 100).round().clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    _loadAccountInfo();
    _loadExistingDogProfile();
  }

  Future<void> _loadMasterData() async {
    final cities = await MasterDataRepository.loadCities();
    final breeds = await MasterDataRepository.loadAnimalBreeds();
    final vaccines = await MasterDataRepository.loadVaccines();
    if (!mounted) return;
    setState(() {
      _dynamicCityOptions = cities;
      _dynamicBreeds = breeds;
      _vaccines = vaccines;
    });
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _passportCodeController.dispose();
    _microchipController.dispose();
    _colorController.dispose();
    _temperamentController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _accountNameController.text = user.displayName ?? '';
    _accountEmail = user.email ?? user.phoneNumber ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        final savedName = data['displayName'] as String? ?? '';
        final savedEmail =
            data['email'] as String? ?? data['phone'] as String? ?? '';
        if (savedName.trim().isNotEmpty) {
          _accountNameController.text = savedName;
        }
        if (savedEmail.trim().isNotEmpty) {
          _accountEmail = savedEmail;
        }
      }
    } catch (_) {
      // Hesap bilgisi yuklenemezse Auth uzerindeki bilgi gosterilir.
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadExistingDogProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _status = AppStrings.userNotFound;
        _loading = false;
      });
      return;
    }

    try {
      final existing = await _fetchExistingPetProfile(user.uid);
      if (existing != null) {
        await _applyExistingPetProfile(existing);
      } else {
        _applyRonyStarterProfile();
        _dynamicDistrictOptions =
            await MasterDataRepository.loadDistricts(_cityController.text);
      }
    } catch (e) {
      _status = '${AppStrings.profileLoadFailedPrefix}$e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<_PetProfileSnapshot?> _fetchExistingPetProfile(String userId) async {
    final dogs = FirebaseFirestore.instance.collection('dogs');
    final ownerQuery = await dogs
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .get();
    if (ownerQuery.docs.isNotEmpty) {
      final doc = ownerQuery.docs.first;
      return _PetProfileSnapshot(id: doc.id, data: doc.data());
    }

    final userQuery = await dogs.where('userId', isEqualTo: userId).limit(1).get();
    if (userQuery.docs.isNotEmpty) {
      final doc = userQuery.docs.first;
      return _PetProfileSnapshot(id: doc.id, data: doc.data());
    }

    final directDogDoc = await dogs.doc(userId).get();
    final directDogData = directDogDoc.data();
    if (directDogDoc.exists && directDogData != null) {
      return _PetProfileSnapshot(id: directDogDoc.id, data: directDogData);
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final userData = userDoc.data();
    if (userData == null) return null;
    final nestedPet = userData['dogProfile'] ?? userData['petProfile'];
    if (nestedPet is Map<String, dynamic>) {
      return _PetProfileSnapshot(id: null, data: nestedPet);
    }
    if (userData.containsKey('dogName') ||
        userData.containsKey('petName') ||
        userData.containsKey('dogBreed')) {
      return _PetProfileSnapshot(id: null, data: userData);
    }
    return null;
  }

  Future<void> _applyExistingPetProfile(_PetProfileSnapshot profile) async {
    final data = profile.data;
    _existingDogId = profile.id;
    _nameController.text = _firstText(data, const ['name', 'dogName', 'petName']);
    _breedController.text = _firstText(data, const ['breed', 'dogBreed', 'petBreed']);
    _ageController.text = _firstValue(data, const ['ageMonths', 'age', 'petAge']);
    _weightController.text = _firstValue(data, const ['weightKg', 'weight', 'petWeight']);
    _cityController.text = _firstText(data, const ['city', 'petCity']);
    final category =
        _firstText(data, const ['animalCategory', 'type', 'animalType', 'petType']);
    final vaccineStatus =
        _firstText(data, const ['vaccineStatus', 'vaccinationStatus']);
    _animalCategory = _normalizeCategory(category.isEmpty ? 'Kopek' : category);
    _vaccineStatus = vaccineStatus.isEmpty ? 'Bilinmiyor' : vaccineStatus;
    _selectedVaccines
      ..clear()
      ..addAll((data['vaccines'] as List<dynamic>? ?? <dynamic>[]).whereType<String>());
    _districtController.text = _firstText(data, const ['district', 'petDistrict']);
    if (_cityController.text.isNotEmpty) {
      _dynamicDistrictOptions =
          await MasterDataRepository.loadDistricts(_cityController.text);
    }
    _passportCodeController.text = _firstText(data, const ['passportCode', 'passport']);
    _microchipController.text = _firstText(data, const ['microchipNo', 'microchip']);
    _colorController.text = _firstText(data, const ['color', 'petColor']);
    final sex = _firstText(data, const ['sex', 'gender']);
    final activityLevel = _firstText(data, const ['activityLevel', 'energyLevel']);
    _sex = sex.isEmpty ? 'female' : sex;
    _activityLevel = activityLevel.isEmpty ? 'medium' : activityLevel;
    _isNeutered = data['isNeutered'] == true || data['neutered'] == true;
    _isVaccinated = data['isVaccinated'] == true || data['vaccinated'] == true;
    _friendlyWithDogs = data['friendlyWithDogs'] != false;
    _friendlyWithKids = data['friendlyWithKids'] != false;
    final rawTemperament = data['temperamentTags'] is List<dynamic>
        ? data['temperamentTags'] as List<dynamic>
        : data['traits'] is List<dynamic>
            ? data['traits'] as List<dynamic>
            : <dynamic>[];
    final temperamentTags = rawTemperament.whereType<String>().toList();
    _temperamentController.text = temperamentTags.join(', ');
    _selectedTraits
      ..clear()
      ..addAll(temperamentTags.where(_traitOptions.contains));
    _healthNotesController.text =
        _firstText(data, const ['healthNotes', 'bio', 'notes']);
    final photos = (data['photoUrls'] as List<dynamic>? ?? <dynamic>[])
        .whereType<String>()
        .toList();
    _existingPhotoUrl = photos.isNotEmpty
        ? photos.first
        : _firstText(data, const ['photoUrl', 'imageUrl']);
    if (_existingPhotoUrl != null && _existingPhotoUrl!.isEmpty) {
      _existingPhotoUrl = null;
    }
  }

  String _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  String _firstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  void _applyRonyStarterProfile() {
    _nameController.text = 'Rony';
    _animalCategory = 'Kopek';
    _breedController.text = 'Maltese';
    _ageController.text = '10';
    _weightController.text = '4';
    _cityController.text = 'Istanbul';
    _districtController.text = 'Kadikoy';
    _passportCodeController.text = 'RONY-DEMO';
    _colorController.text = 'Beyaz';
    _sex = 'female';
    _activityLevel = 'medium';
    _isVaccinated = true;
    _vaccineStatus = 'Tam';
    _friendlyWithDogs = true;
    _friendlyWithKids = true;
    _selectedTraits
      ..clear()
      ..addAll(const ['Sakin', 'Sosyal', 'Oyuncu']);
    _temperamentController.text = _selectedTraits.join(', ');
    _healthNotesController.text =
        'Rony icin baslangic profili. Bilgileri kendi petine gore duzenleyebilirsin.';
    _starterPhotoAsset = 'assets/images/rony_login_story.jpg';
    _status = 'Rony taslagi yuklendi. Kaydetmeden once bilgileri duzenleyebilirsin.';
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.single.bytes;
    if (bytes == null) return;
    setState(() => _imageBytes = bytes);
  }

  Future<void> _saveDogProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _status = AppStrings.userNotFound);
      return;
    }

    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();
    final ageMonths = int.tryParse(_ageController.text.trim()) ?? 0;
    final weightKg = int.tryParse(_weightController.text.trim()) ?? 0;
    final city = _cityController.text.trim();
    final district = _districtController.text.trim();
    final accountName = _accountNameController.text.trim();
    final passportCode = _passportCodeController.text.trim();
    final microchipNo = _microchipController.text.trim();
    final color = _colorController.text.trim();
    final temperamentTags = _temperamentController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final mergedTraits = <String>{...temperamentTags, ..._selectedTraits}.toList();
    final healthNotes = _healthNotesController.text.trim();

    if (name.isEmpty ||
        breed.isEmpty ||
        ageMonths <= 0 ||
        weightKg <= 0 ||
        city.isEmpty ||
        passportCode.isEmpty) {
      setState(() => _status = AppStrings.profileAllFieldsRequired);
      return;
    }
    if (_imageBytes == null &&
        _existingPhotoUrl == null &&
        _starterPhotoAsset == null) {
      setState(() => _status = AppStrings.profileNeedPhoto);
      return;
    }

    setState(() {
      _saving = true;
      _status = '';
    });

    try {
      final dogs = FirebaseFirestore.instance.collection('dogs');
      final docRef = _existingDogId == null ? dogs.doc() : dogs.doc(_existingDogId);

      if (accountName.isNotEmpty) {
        await user.updateDisplayName(accountName);
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'displayName': accountName,
        'email': user.email,
        'phone': user.phoneNumber,
        'city': city,
        'district': district,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      var imageUrl = _existingPhotoUrl;
      if (_imageBytes != null) {
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('dog_photos')
            .child('${docRef.id}.jpg');
        await imageRef.putData(
          _imageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await imageRef.getDownloadURL();
      } else if (_starterPhotoAsset != null && imageUrl == null) {
        final assetData = await rootBundle.load(_starterPhotoAsset!);
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('dog_photos')
            .child('${docRef.id}.jpg');
        await imageRef.putData(
          assetData.buffer.asUint8List(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await imageRef.getDownloadURL();
      }

      final payload = <String, dynamic>{
        'dogId': docRef.id,
        'ownerId': user.uid,
        'name': name,
        'animalCategory': _animalCategory,
        'breed': breed,
        'passportCode': passportCode,
        'ageMonths': ageMonths,
        'weightKg': weightKg,
        'microchipNo': microchipNo,
        'color': color,
        'sex': _sex,
        'temperamentTags': mergedTraits,
        'activityLevel': _activityLevel,
        'healthNotes': healthNotes,
        'isNeutered': _isNeutered,
        'isVaccinated': _isVaccinated,
        'vaccines': _selectedVaccines.toList(),
        'vaccineStatus': _vaccineStatus,
        'friendlyWithDogs': _friendlyWithDogs,
        'friendlyWithKids': _friendlyWithKids,
        'bio': healthNotes,
        'photoUrls': imageUrl == null ? <String>[] : <String>[imageUrl],
        'city': city,
        'district': district,
        'isProfileComplete': true,
        'verificationStatus': 'unverified',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_existingDogId == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }
      await docRef.set(payload, SetOptions(merge: true));
      await AnalyticsRepository().trackEvent(
        userId: user.uid,
        eventName: 'pet_profile_saved',
        module: 'profile',
        entityType: 'dog',
        entityId: docRef.id,
        properties: {
          'animalCategory': _animalCategory,
          'breed': breed,
          'city': city,
          'district': district,
          'isNew': _existingDogId == null,
        },
      );

      _existingDogId = docRef.id;
      _existingPhotoUrl = imageUrl;

      if (!mounted) return;
      setState(() {
        _status =
            'Kaydedildi: ${city.isEmpty ? "-" : city}/${district.isEmpty ? "-" : district}';
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellPage()),
      );
    } catch (e) {
      setState(() => _status = '${AppStrings.profileSaveFailedPrefix}$e');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingDogId == null ? AppStrings.profileCreateTitle : AppStrings.profileEditTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Hesap Bilgileri',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _accountNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_accountEmail.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'E-posta / Telefon',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_accountEmail),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final percent = _profileCompletionPercent();
                final missing = _missingFields();
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Profil Tamamlama: %$percent',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: percent / 100),
                      const SizedBox(height: 8),
                      if (missing.isNotEmpty)
                        Text(
                          'Eksik alanlar: ${missing.join(', ')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      if (missing.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: null,
                          child: const Text('Once zorunlu alanlari tamamla'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileNameLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _animalCategory,
              items: (_dynamicBreeds.keys.isEmpty ? PetTaxonomy.animalCategories : _dynamicBreeds.keys.toList())
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _animalCategory = value;
                  _breedController.text = '';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Hayvan Türü',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _breedController.text.isEmpty ? null : _breedController.text,
              items: ((_dynamicBreeds[_animalCategory] ??
                      (_animalCategory == 'Kopek' ? PetTaxonomy.kopekIrklari : PetTaxonomy.kediIrklari)))
                  .map((b) => DropdownMenuItem<String>(value: b, child: Text(b)))
                  .toList(),
              onChanged: (value) => setState(() => _breedController.text = value ?? ''),
              decoration: const InputDecoration(
                labelText: AppStrings.profileBreedLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileAgeLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileWeightLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _cityController.text.isEmpty ? null : _cityController.text,
              isExpanded: true,
              items: (_dynamicCityOptions.isEmpty ? _cityOptions : _dynamicCityOptions)
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) async {
                if (value == null) return;
                final districts = await MasterDataRepository.loadDistricts(value);
                if (!mounted) return;
                setState(() {
                  _cityController.text = value;
                  _districtController.text = '';
                  _manualDistrict = false;
                  _dynamicDistrictOptions = districts;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Sehir',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final ilceler = _dynamicDistrictOptions.isNotEmpty
                    ? _dynamicDistrictOptions
                    : (PetTaxonomy.ilceMap[_cityController.text] ?? const <String>[]);
                if (ilceler.isNotEmpty && !_manualDistrict) {
                  final safeDistrict = ilceler.contains(_districtController.text)
                      ? _districtController.text
                      : null;
                  return DropdownButtonFormField<String>(
                    initialValue: safeDistrict,
                    isExpanded: true,
                    items: ilceler
                        .map((d) => DropdownMenuItem<String>(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _districtController.text = v ?? ''),
                    decoration: InputDecoration(
                      labelText: 'Ilce',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: 'Elle gir',
                        onPressed: () => setState(() => _manualDistrict = true),
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  );
                }
                if (_manualDistrict || ilceler.isEmpty) {
                  return TextField(
                    controller: _districtController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Ilce',
                      border: const OutlineInputBorder(),
                      suffixIcon: ilceler.isNotEmpty
                          ? IconButton(
                              tooltip: 'Listeden sec',
                              onPressed: () => setState(() => _manualDistrict = false),
                              icon: const Icon(Icons.list),
                            )
                          : null,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passportCodeController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profilePassportLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _microchipController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileMicrochipLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileColorLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _sex,
              decoration: const InputDecoration(
                labelText: AppStrings.profileSexLabel,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'female', child: Text(AppStrings.profileSexFemale)),
                DropdownMenuItem(value: 'male', child: Text(AppStrings.profileSexMale)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sex = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _activityLevel,
              decoration: const InputDecoration(
                labelText: AppStrings.profileActivityLevel,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text(AppStrings.profileActivityLow),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text(AppStrings.profileActivityMedium),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text(AppStrings.profileActivityHigh),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _activityLevel = value);
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isNeutered,
              title: const Text(AppStrings.profileNeutered),
              onChanged: (v) => setState(() => _isNeutered = v),
            ),
            SwitchListTile(
              value: _isVaccinated,
              title: const Text(AppStrings.profileVaccinated),
              onChanged: (v) => setState(() => _isVaccinated = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _vaccineStatus,
              decoration: const InputDecoration(
                labelText: 'Aşı Durumu',
                border: OutlineInputBorder(),
              ),
              items: (_vaccines['Durum'] ?? const <String>['Bilinmiyor'])
                  .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _vaccineStatus = v ?? 'Bilinmiyor'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_vaccines[_normalizeCategory(_animalCategory)] ?? const <String>[])
                  .map((a) => FilterChip(
                        label: Text(a),
                        selected: _selectedVaccines.contains(a),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedVaccines.add(a);
                            } else {
                              _selectedVaccines.remove(a);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            SwitchListTile(
              value: _friendlyWithDogs,
              title: const Text(AppStrings.profileFriendlyDogs),
              onChanged: (v) => setState(() => _friendlyWithDogs = v),
            ),
            SwitchListTile(
              value: _friendlyWithKids,
              title: const Text(AppStrings.profileFriendlyKids),
              onChanged: (v) => setState(() => _friendlyWithKids = v),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _traitOptions.map((trait) {
                final selected = _selectedTraits.contains(trait);
                return FilterChip(
                  label: Text(trait),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedTraits.add(trait);
                      } else {
                        _selectedTraits.remove(trait);
                      }
                      _temperamentController.text = _selectedTraits.join(', ');
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _temperamentController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileTemperamentLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _healthNotesController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.profileHealthNotesLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _saving ? null : _pickImage,
              child: Text(
                _imageBytes == null ? AppStrings.profilePickPhoto : AppStrings.profileChangePhoto,
              ),
            ),
            const SizedBox(height: 8),
            if (_imageBytes != null)
              SizedBox(
                height: 160,
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              ),
            if (_imageBytes == null && _existingPhotoUrl != null)
              SizedBox(
                height: 160,
                child: Image.network(_existingPhotoUrl!, fit: BoxFit.cover),
              ),
            if (_imageBytes == null &&
                _existingPhotoUrl == null &&
                _starterPhotoAsset != null)
              SizedBox(
                height: 160,
                child: Image.asset(_starterPhotoAsset!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saving ? null : _saveDogProfile,
              child: Text(_existingDogId == null ? AppStrings.profileSave : AppStrings.profileSaveChanges),
            ),
            const SizedBox(height: 12),
            Text(_status),
          ],
        ),
            ),
    );
  }
}
