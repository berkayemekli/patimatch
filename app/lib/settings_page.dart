import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'blocked_users_page.dart';
import 'data/master_data/master_data_repository.dart';
import 'dog_profile_page.dart';
import 'identity_verification_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'payments_page.dart';
import 'role_selection_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  String _emailOrPhone = '';
  String _city = '';
  String _district = '';
  List<String> _cities = const <String>[];
  List<String> _districts = const <String>[];
  bool _loadingProfile = true;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      // Auth bilgisini gostermek icin Firestore hatasini sessiz geciyoruz.
    }

    final districts = city.isEmpty
        ? <String>[]
        : await MasterDataRepository.loadDistricts(city);

    if (!mounted) return;
    setState(() {
      _nameController.text = displayName;
      _emailOrPhone = emailOrPhone;
      _city = city;
      _district = district;
      _cities = cities;
      _districts = districts;
      _loadingProfile = false;
    });
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _savingProfile) return;
    final displayName = _nameController.text.trim();
    setState(() => _savingProfile = true);
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgilerin guncellendi.')),
      );
      setState(() {});
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _openProfileEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickCity(String city) async {
              final districts = await MasterDataRepository.loadDistricts(city);
              setModalState(() {
                _city = city;
                _district = '';
                _districts = districts;
              });
              setState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Benim Bilgilerim',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
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
                      child: Text(_emailOrPhone.isEmpty ? '-' : _emailOrPhone),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _city.isEmpty ? null : _city,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Sehir',
                        border: OutlineInputBorder(),
                      ),
                      items: _cities
                          .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) pickCity(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _districts.contains(_district) ? _district : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Ilce',
                        border: OutlineInputBorder(),
                      ),
                      items: _districts
                          .map((district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() => _district = value ?? '');
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _savingProfile ? null : _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(_savingProfile ? 'Kaydediliyor...' : 'Kaydet'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final title = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'PatiParent hesabi';
    final subtitle = [
      if (_emailOrPhone.isNotEmpty) _emailOrPhone,
      if (_city.isNotEmpty) [_city, _district].where((v) => v.isNotEmpty).join(' / '),
    ].join(' - ');

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _loadingProfile ? null : _openProfileEditor,
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
                          _loadingProfile ? 'Yukleniyor...' : title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle.isEmpty ? 'Bilgilerini duzenle' : subtitle,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_rounded, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD8E7FF)),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.verified_rounded, color: Color(0xFF0A84FF)),
              ),
              title: const Text(
                'Profil ve guven dogrulamasi',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Mavi tik, kimlik dogrulama ve guven rozetleri',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IdentityVerificationPage(),
                  ),
                );
              },
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
            leading: const Icon(Icons.tune_rounded),
            title: const Text('KullanÄ±m rolÃ¼m'),
            subtitle: const Text('Hizmet almak, hizmet vermek veya ikisini birlikte seÃ§'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
              );
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

