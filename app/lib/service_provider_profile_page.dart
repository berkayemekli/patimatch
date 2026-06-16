import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';
import 'login_page.dart';

class ServiceProviderProfilePage extends StatefulWidget {
  const ServiceProviderProfilePage({super.key});

  @override
  State<ServiceProviderProfilePage> createState() =>
      _ServiceProviderProfilePageState();
}

class _ServiceProviderProfilePageState
    extends State<ServiceProviderProfilePage> {
  final _priceController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _availabilityController = TextEditingController();

  String _serviceType = 'walker';
  String _city = '';
  String _district = '';
  bool _instantBooking = false;
  bool _yard = false;
  bool _loading = true;
  bool _saving = false;
  String _status = '';
  List<String> _cities = const <String>[];
  List<String> _districts = const <String>[];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final cities = await MasterDataRepository.loadCities();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _cities = cities;
          _loading = false;
        });
      }
      return;
    }

    var city = '';
    var district = '';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = userDoc.data();
      city = (data?['city'] as String? ?? '').trim();
      district = (data?['district'] as String? ?? '').trim();
    } catch (_) {
      // Profil bilgileri okunamazsa form bos baslar.
    }

    final districts =
        city.isEmpty ? <String>[] : await MasterDataRepository.loadDistricts(city);

    if (!mounted) return;
    setState(() {
      _cities = cities;
      _city = city;
      _district = district;
      _districts = districts;
      _loading = false;
    });
    await _loadExistingProviderProfile();
  }

  Future<void> _loadExistingProviderProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collection = _serviceType == 'walker' ? 'walkers' : 'bnb_hosts';
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (!mounted || data == null) return;

    setState(() {
      _city = (data['city'] as String? ?? _city).trim();
      _district = (data['district'] as String? ?? _district).trim();
      _priceController.text =
          (data[_serviceType == 'walker' ? 'pricePerHour' : 'nightlyPrice'] ??
                  '')
              .toString();
      _experienceController.text =
          (data['experience'] as String? ?? '').trim();
      _bioController.text = (data['bio'] as String? ?? '').trim();
      _availabilityController.text =
          (data['availability'] as String? ?? '').trim();
      _instantBooking = data['instantBooking'] == true;
      _yard = data['yard'] == true;
    });
  }

  Future<void> _setServiceType(String value) async {
    setState(() {
      _serviceType = value;
      _priceController.clear();
      _experienceController.clear();
      _bioController.clear();
      _availabilityController.clear();
      _instantBooking = false;
      _yard = false;
      _status = '';
    });
    await _loadExistingProviderProfile();
  }

  Future<void> _setCity(String city) async {
    final districts = await MasterDataRepository.loadDistricts(city);
    if (!mounted) return;
    setState(() {
      _city = city;
      _district = '';
      _districts = districts;
    });
  }

  Future<void> _saveProviderProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final experience = _experienceController.text.trim();
    final bio = _bioController.text.trim();
    final availability = _availabilityController.text.trim();
    if (_city.isEmpty ||
        _district.isEmpty ||
        price <= 0 ||
        experience.isEmpty ||
        bio.length < 20 ||
        availability.isEmpty) {
      setState(() {
        _status =
            'Il, ilce, fiyat, deneyim, uygunluk ve en az 20 karakterlik aciklama gerekli.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _status = '';
    });

    final collection = _serviceType == 'walker' ? 'walkers' : 'bnb_hosts';
    final priceField = _serviceType == 'walker' ? 'pricePerHour' : 'nightlyPrice';
    final payload = <String, dynamic>{
      'id': user.uid,
      'ownerUserId': user.uid,
      'name': user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : (user.email ?? user.phoneNumber ?? 'PatiParent kullanicisi'),
      'city': _city,
      'district': _district,
      priceField: price,
      'experience': experience,
      'availability': availability,
      'bio': bio,
      'status': 'active',
      'verificationStatus': 'unverified',
      'trustBadges': <String>['Telefon onayli'],
      'rating': 0,
      'reviewCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (_serviceType == 'walker') {
      payload.addAll({
        'walkCount': 0,
        'instantBooking': _instantBooking,
      });
    } else {
      payload.addAll({
        'yard': _yard,
        'instantBooking': _instantBooking,
      });
    }

    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(user.uid)
          .set(payload, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _status = _serviceType == 'walker'
            ? 'Gezdirici profilin yayina alindi.'
            : 'PatiBnB host profilin yayina alindi.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Profil kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hizmet Veren Profili')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: [
                    _Header(serviceType: _serviceType),
                    const SizedBox(height: 16),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'walker',
                          icon: Icon(Icons.directions_walk_rounded),
                          label: Text('PatiGezdirme'),
                        ),
                        ButtonSegment(
                          value: 'bnb',
                          icon: Icon(Icons.home_work_rounded),
                          label: Text('PatiBnB'),
                        ),
                      ],
                      selected: {_serviceType},
                      onSelectionChanged: _saving
                          ? null
                          : (values) => _setServiceType(values.first),
                    ),
                    const SizedBox(height: 14),
                    _SearchableSelect(
                      label: 'Il',
                      value: _city,
                      options: _cities,
                      onSelected: _setCity,
                    ),
                    const SizedBox(height: 12),
                    _SearchableSelect(
                      label: 'Ilce',
                      value: _district,
                      options: _districts,
                      enabled: _city.isNotEmpty && _districts.isNotEmpty,
                      onSelected: (value) => setState(() => _district = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            _serviceType == 'walker' ? 'Saatlik fiyat' : 'Gecelik fiyat',
                        suffixText: 'TL',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Deneyim',
                        hintText: 'Orn: 2 yildir duzenli kopek gezdiriyorum',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _availabilityController,
                      decoration: const InputDecoration(
                        labelText: 'Uygunluk',
                        hintText: 'Orn: Hafta ici 18:00 sonrasi, hafta sonu tam gun',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(
                        labelText: 'Profil aciklamasi',
                        hintText:
                            'Guven veren, net ve samimi bir hizmet aciklamasi yaz.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _instantBooking,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _instantBooking = value),
                      title: const Text('Hizli talep kabul ediyorum'),
                      subtitle: const Text('Musaitlik uygunsa kullanici direkt talep gonderebilir.'),
                    ),
                    if (_serviceType == 'bnb')
                      SwitchListTile(
                        value: _yard,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _yard = value),
                        title: const Text('Bahce / dis alan var'),
                        subtitle: const Text('Konaklama profilinde guven sinyali olarak gorunur.'),
                      ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _saving ? null : _saveProviderProfile,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.publish_rounded),
                      label: Text(_saving ? 'Kaydediliyor...' : 'Yayina Al'),
                    ),
                    if (_status.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _StatusBox(text: _status),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.serviceType});

  final String serviceType;

  @override
  Widget build(BuildContext context) {
    final isWalker = serviceType == 'walker';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isWalker ? const Color(0xFFE7F7F2) : const Color(0xFFFFF2E8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              isWalker ? Icons.directions_walk_rounded : Icons.home_work_rounded,
              color: isWalker ? const Color(0xFF0F766E) : const Color(0xFFF97316),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWalker ? 'Gezdirici olarak katil' : 'Host olarak katil',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWalker
                      ? 'Konum, fiyat ve deneyimini ekleyerek yuruyus talepleri almaya basla.'
                      : 'Ev tipi konaklama profilini olustur ve guvenli talepler al.',
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

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF475569))),
    );
  }
}

class _SearchableSelect extends StatelessWidget {
  const _SearchableSelect({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _openPicker(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.search_rounded),
          enabled: enabled,
        ),
        child: Text(
          value.isEmpty ? 'Sec' : value,
          style: TextStyle(
            color: enabled ? const Color(0xFF111827) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showSearch<String>(
      context: context,
      delegate: _OptionSearchDelegate(label: label, options: options),
    );
    if (selected != null && selected.isNotEmpty) {
      onSelected(selected);
    }
  }
}

class _OptionSearchDelegate extends SearchDelegate<String> {
  _OptionSearchDelegate({required this.label, required this.options});

  final String label;
  final List<String> options;

  @override
  String get searchFieldLabel => '$label ara';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Temizle',
          onPressed: () => query = '',
          icon: const Icon(Icons.close_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Geri',
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildOptions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildOptions(context);

  Widget _buildOptions(BuildContext context) {
    final normalized = _normalizeTurkishSearch(query);
    final matches = normalized.isEmpty
        ? options
        : options
            .where(
              (option) => _normalizeTurkishSearch(option).startsWith(normalized),
            )
            .toList();
    final fallback = normalized.isEmpty || matches.isNotEmpty
        ? matches
        : options
            .where(
              (option) => _normalizeTurkishSearch(option).contains(normalized),
            )
            .toList();

    if (fallback.isEmpty) {
      return const Center(child: Text('Sonuc bulunamadi'));
    }

    return ListView.builder(
      itemCount: fallback.length,
      itemBuilder: (context, index) {
        final option = fallback[index];
        return ListTile(
          title: Text(option),
          onTap: () => close(context, option),
        );
      },
    );
  }
}

String _normalizeTurkishSearch(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('i̇', 'i')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ş', 's')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c');
}
