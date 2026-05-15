import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'blocked_users_page.dart';
import 'data/master_data/master_data_repository.dart';
import 'dog_profile_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'payments_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _displayName = '';
  String _emailOrPhone = '';
  String _city = '';
  String _district = '';
  List<String> _cities = const <String>[];
  List<String> _districts = const <String>[];
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadingProfile = false);
      return;
    }

    final cities = await MasterDataRepository.loadCities();
    var displayName = user.displayName ?? '';
    var emailOrPhone = user.email ?? user.phoneNumber ?? '';
    var city = '';
    var district = '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        displayName = (data['displayName'] as String? ?? displayName).trim();
        emailOrPhone =
            (data['email'] as String? ?? data['phone'] as String? ?? emailOrPhone)
                .trim();
        city = (data['city'] as String? ?? '').trim();
        district = (data['district'] as String? ?? '').trim();
      }
    } catch (_) {
      // Firestore okunamazsa Auth bilgileriyle devam edilir.
    }

    final districts = city.isEmpty
        ? <String>[]
        : await MasterDataRepository.loadDistricts(city);

    if (!mounted) return;
    setState(() {
      _displayName = displayName;
      _emailOrPhone = emailOrPhone;
      _city = city;
      _district = district;
      _cities = cities;
      _districts = districts;
      _loadingProfile = false;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openAccountEditor() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AccountInfoPage(
          initialName: _displayName,
          emailOrPhone: _emailOrPhone,
          initialCity: _city,
          initialDistrict: _district,
          cities: _cities,
          districts: _districts,
        ),
      ),
    );
    if (updated == true) {
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgilerin gÃ¼ncellendi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final title = _displayName.trim().isNotEmpty
        ? _displayName.trim()
        : 'PatiParent hesabı';
    final location = [_city, _district].where((v) => v.isNotEmpty).join(' / ');
    final subtitle = [
      if (_emailOrPhone.isNotEmpty) _emailOrPhone,
      if (location.isNotEmpty) location,
    ].join(' - ');

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _loadingProfile ? null : _openAccountEditor,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFEAF2FF),
                    backgroundImage: photoUrl == null || photoUrl.isEmpty
                        ? null
                        : NetworkImage(photoUrl),
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(Icons.person_rounded)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loadingProfile ? 'Yükleniyor...' : title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle.isEmpty ? 'Bilgilerini düzenle' : subtitle,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text(AppStrings.settingsEditProfile),
            subtitle: const Text(AppStrings.settingsEditProfileSub),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DogProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text(AppStrings.settingsBlocked),
            subtitle: const Text(AppStrings.settingsBlockedSub),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text(AppStrings.settingsPayments),
            subtitle: const Text(AppStrings.settingsPaymentsSub),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaymentsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text(AppStrings.settingsNotifications),
            subtitle: const Text(AppStrings.settingsNotificationsSub),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.settingsSignOut),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({
    super.key,
    required this.initialName,
    required this.emailOrPhone,
    required this.initialCity,
    required this.initialDistrict,
    required this.cities,
    required this.districts,
  });

  final String initialName;
  final String emailOrPhone;
  final String initialCity;
  final String initialDistrict;
  final List<String> cities;
  final List<String> districts;

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  late final TextEditingController _nameController;
  late String _city;
  late String _district;
  late List<String> _districts;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _city = widget.initialCity;
    _district = widget.initialDistrict;
    _districts = widget.districts;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _saving) return;
    final displayName = _nameController.text.trim();
    setState(() => _saving = true);
    try {
      if (displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'displayName': displayName,
        'email': user.email,
        'phone': user.phoneNumber,
        'city': _city,
        'district': _district,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgilerin güncellendi.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benim Bilgilerim')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Ad Soyad',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'E-posta / Telefon',
              border: OutlineInputBorder(),
            ),
            child: Text(widget.emailOrPhone.isEmpty ? '-' : widget.emailOrPhone),
          ),
          const SizedBox(height: 12),
          _SearchableSelect(
            label: 'İl',
            value: _city,
            options: widget.cities,
            onSelected: _setCity,
          ),
          const SizedBox(height: 12),
          _SearchableSelect(
            label: 'İlçe',
            value: _district,
            options: _districts,
            enabled: _city.isNotEmpty && _districts.isNotEmpty,
            onSelected: (value) => setState(() => _district = value),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
          ),
        ],
      ),
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
          value.isEmpty ? 'Seç' : value,
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
      return const Center(child: Text('SonuÃ§ bulunamadÄ±'));
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
      .replaceAll('Ä±', 'i')
      .replaceAll('Ä°', 'i')
      .replaceAll('iÌ‡', 'i')
      .replaceAll('ÄŸ', 'g')
      .replaceAll('Ã¼', 'u')
      .replaceAll('ÅŸ', 's')
      .replaceAll('Ã¶', 'o')
      .replaceAll('Ã§', 'c');
}

