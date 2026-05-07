import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'main_shell_page.dart';

class DogProfilePage extends StatefulWidget {
  const DogProfilePage({super.key});

  @override
  State<DogProfilePage> createState() => _DogProfilePageState();
}

class _DogProfilePageState extends State<DogProfilePage> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _passportCodeController = TextEditingController();
  final _microchipController = TextEditingController();
  final _colorController = TextEditingController();
  final _temperamentController = TextEditingController();
  final _healthNotesController = TextEditingController();
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
  final List<String> _cityOptions = const <String>[
    'Istanbul', 'İstanbul', 'Ankara', 'Izmir', 'İzmir', 'Bursa', 'Antalya', 'Kocaeli', 'Mugla', 'Muğla', 'Adana'
  ];
  String? _selectedCity;
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
    if ((_imageBytes == null) && (_existingPhotoUrl == null)) missing.add('Fotograf');
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
    if ((_imageBytes != null) || (_existingPhotoUrl != null)) filled++;
    return ((filled / total) * 100).round().clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _loadExistingDogProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _passportCodeController.dispose();
    _microchipController.dispose();
    _colorController.dispose();
    _temperamentController.dispose();
    _healthNotesController.dispose();
    super.dispose();
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
      final q = await FirebaseFirestore.instance
          .collection('dogs')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        final doc = q.docs.first;
        final data = doc.data();
        _existingDogId = doc.id;
        _nameController.text = data['name'] as String? ?? '';
        _breedController.text = data['breed'] as String? ?? '';
        _ageController.text = (data['ageMonths']?.toString() ?? '');
        _weightController.text = (data['weightKg']?.toString() ?? '');
        _cityController.text = data['city'] as String? ?? '';
        _selectedCity = _cityOptions.contains(_cityController.text)
            ? _cityController.text
            : null;
        _districtController.text = data['district'] as String? ?? '';
        final loc = data['location'] as Map<String, dynamic>?;
        _latController.text = (loc?['lat']?.toString() ?? '');
        _lngController.text = (loc?['lng']?.toString() ?? '');
        _passportCodeController.text = data['passportCode'] as String? ?? '';
        _microchipController.text = data['microchipNo'] as String? ?? '';
        _colorController.text = data['color'] as String? ?? '';
        _sex = data['sex'] as String? ?? 'female';
        _activityLevel = data['activityLevel'] as String? ?? 'medium';
        _isNeutered = data['isNeutered'] == true;
        _isVaccinated = data['isVaccinated'] == true;
        _friendlyWithDogs = data['friendlyWithDogs'] != false;
        _friendlyWithKids = data['friendlyWithKids'] != false;
        final temperamentTags =
            (data['temperamentTags'] as List<dynamic>? ?? <dynamic>[])
                .whereType<String>()
                .toList();
        _temperamentController.text = temperamentTags.join(', ');
        _selectedTraits
          ..clear()
          ..addAll(temperamentTags.where(_traitOptions.contains));
        _healthNotesController.text = data['healthNotes'] as String? ?? '';
        final photos = (data['photoUrls'] as List<dynamic>? ?? <dynamic>[])
            .whereType<String>()
            .toList();
        _existingPhotoUrl = photos.isNotEmpty ? photos.first : null;
      }
    } catch (e) {
      _status = '${AppStrings.profileLoadFailedPrefix}$e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
    final passportCode = _passportCodeController.text.trim();
    final microchipNo = _microchipController.text.trim();
    final color = _colorController.text.trim();
    final temperamentTags = _temperamentController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final lat = double.tryParse(_latController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final lng = double.tryParse(_lngController.text.trim().replaceAll(',', '.')) ?? 0.0;
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
    if (_imageBytes == null && _existingPhotoUrl == null) {
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
      }

      final payload = <String, dynamic>{
        'dogId': docRef.id,
        'ownerId': user.uid,
        'name': name,
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
        'friendlyWithDogs': _friendlyWithDogs,
        'friendlyWithKids': _friendlyWithKids,
        'bio': healthNotes,
        'photoUrls': imageUrl == null ? <String>[] : <String>[imageUrl],
        'city': city,
        'district': district,
        'location': {'lat': lat, 'lng': lng},
        'isProfileComplete': true,
        'verificationStatus': 'unverified',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_existingDogId == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }
      await docRef.set(payload, SetOptions(merge: true));

      _existingDogId = docRef.id;
      _existingPhotoUrl = imageUrl;

      if (!mounted) return;
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
            TextField(
              controller: _breedController,
              onChanged: (_) => setState(() {}),
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
            TextField(
              controller: _districtController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Ilce',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: AppStrings.profileCityLabel,
                border: OutlineInputBorder(),
              ),
              items: _cityOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCity = value;
                  _cityController.text = value;
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              onChanged: (_) => setState(() {
                _selectedCity = _cityOptions.contains(_cityController.text)
                    ? _cityController.text
                    : null;
              }),
              decoration: const InputDecoration(
                labelText: 'Sehir (elle giris)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Harita Altyapisi: Bu koordinatlar sonraki adimda map pin icin kullanilacak.'),
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
