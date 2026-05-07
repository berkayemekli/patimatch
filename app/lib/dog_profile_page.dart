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
    final passportCode = _passportCodeController.text.trim();
    final microchipNo = _microchipController.text.trim();
    final color = _colorController.text.trim();
    final temperamentTags = _temperamentController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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
        'temperamentTags': temperamentTags,
        'activityLevel': _activityLevel,
        'healthNotes': healthNotes,
        'isNeutered': _isNeutered,
        'isVaccinated': _isVaccinated,
        'friendlyWithDogs': _friendlyWithDogs,
        'friendlyWithKids': _friendlyWithKids,
        'bio': healthNotes,
        'photoUrls': imageUrl == null ? <String>[] : <String>[imageUrl],
        'city': city,
        'location': {'lat': 0.0, 'lng': 0.0},
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.profileNameLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: AppStrings.profileBreedLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.profileAgeLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.profileWeightLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: AppStrings.profileCityLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passportCodeController,
              decoration: const InputDecoration(
                labelText: AppStrings.profilePassportLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _microchipController,
              decoration: const InputDecoration(
                labelText: AppStrings.profileMicrochipLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorController,
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
            TextField(
              controller: _temperamentController,
              decoration: const InputDecoration(
                labelText: AppStrings.profileTemperamentLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _healthNotesController,
              maxLines: 3,
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
