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
      // Auth bilgileri ekranin acilmasi icin yeterlidir.
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
        const SnackBar(content: Text('Bilgilerin guncellendi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final title = _displayName.trim().isNotEmpty
        ? _displayName.trim()
        : 'PatiParent hesabi';
    final location = [_city, _district].where((v) => v.isNotEmpty).join(' / ');
    final subtitle = [
      if (_emailOrPhone.isNotEmpty) _emailOrPhone,
      if (location.isNotEmpty) location,
    ].join(' - ');
    final completionScore = _profileCompletionScore(
      hasName: _displayName.trim().isNotEmpty,
      hasContact: _emailOrPhone.trim().isNotEmpty,
      hasLocation: location.isNotEmpty,
      hasPhoto: photoUrl != null && photoUrl.isNotEmpty,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Hesap merkezi'),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  _SettingsHero(
                    title: _loadingProfile ? 'Yukleniyor...' : title,
                    subtitle: subtitle.isEmpty ? 'Bilgilerini duzenle' : subtitle,
                    photoUrl: photoUrl,
                    completionScore: completionScore,
                    onTap: _loadingProfile ? null : _openAccountEditor,
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Hesap ve pet',
                    children: [
                      _SettingsActionTile(
                        icon: Icons.person_outline_rounded,
                        tint: const Color(0xFF0F766E),
                        title: 'Benim bilgilerim',
                        subtitle: 'Kayit bilgilerini gor ve guncelle',
                        onTap: _loadingProfile ? null : _openAccountEditor,
                      ),
                      _SettingsActionTile(
                        icon: Icons.pets_rounded,
                        tint: const Color(0xFFE11D48),
                        title: AppStrings.settingsEditProfile,
                        subtitle: AppStrings.settingsEditProfileSub,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DogProfilePage(),
                            ),
                          );
                        },
                      ),
                      _SettingsActionTile(
                        icon: Icons.verified_user_rounded,
                        tint: const Color(0xFF2563EB),
                        title: 'Guven dogrulamasi',
                        subtitle: 'Mavi tik, kimlik durumu ve guven sinyalleri',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const IdentityVerificationPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Aktivite',
                    children: [
                      _SettingsActionTile(
                        icon: Icons.notifications_outlined,
                        tint: const Color(0xFF7C3AED),
                        title: AppStrings.settingsNotifications,
                        subtitle: AppStrings.settingsNotificationsSub,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Gizlilik ve hesap',
                    children: [
                      _SettingsActionTile(
                        icon: Icons.block_rounded,
                        tint: const Color(0xFF475569),
                        title: AppStrings.settingsBlocked,
                        subtitle: AppStrings.settingsBlockedSub,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BlockedUsersPage(),
                            ),
                          );
                        },
                      ),
                      _SettingsActionTile(
                        icon: Icons.logout_rounded,
                        tint: const Color(0xFFDC2626),
                        title: AppStrings.settingsSignOut,
                        subtitle: 'Bu cihazdaki oturumu kapat',
                        onTap: () => _signOut(context),
                        destructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _profileCompletionScore({
    required bool hasName,
    required bool hasContact,
    required bool hasLocation,
    required bool hasPhoto,
  }) {
    final completed = [hasName, hasContact, hasLocation, hasPhoto]
        .where((item) => item)
        .length;
    return (completed / 4 * 100).round();
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.title,
    required this.subtitle,
    required this.photoUrl,
    required this.completionScore,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? photoUrl;
  final int completionScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = completionScore / 100;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: const Color(0xFFEAF2FF),
                  backgroundImage: photoUrl == null || photoUrl!.isEmpty
                      ? null
                      : NetworkImage(photoUrl!),
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? const Icon(Icons.person_rounded, color: Color(0xFF111827))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7DD3C7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '%$completionScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Profil tamamlama',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final textColor = destructive ? const Color(0xFFDC2626) : const Color(0xFF111827);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: tint, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Benim bilgilerim'),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  const _AccountInfoNotice(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE7ECF3)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration('Ad Soyad'),
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: _fieldDecoration('E-posta / Telefon'),
                          child: Text(
                            widget.emailOrPhone.isEmpty
                                ? '-'
                                : widget.emailOrPhone,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SearchableSelect(
                          label: 'Il',
                          value: _city,
                          options: widget.cities,
                          onSelected: _setCity,
                        ),
                        const SizedBox(height: 12),
                        _SearchableSelect(
                          label: 'Ilce',
                          value: _district,
                          options: _districts,
                          enabled: _city.isNotEmpty && _districts.isNotEmpty,
                          onSelected: (value) =>
                              setState(() => _district = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }
}

class _AccountInfoNotice extends StatelessWidget {
  const _AccountInfoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFE7DD)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF0F766E), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bu alan senin hesap bilgilerin. Pet veya Rony bilgileri ayri pet profili ekraninda duzenlenir.',
              style: TextStyle(
                color: Color(0xFF0F766E),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
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
      borderRadius: BorderRadius.circular(18),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
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
      .replaceAll('\u0131', 'i')
      .replaceAll('\u0130', 'i')
      .replaceAll('i\u0307', 'i')
      .replaceAll('\u011f', 'g')
      .replaceAll('\u00fc', 'u')
      .replaceAll('\u015f', 's')
      .replaceAll('\u00f6', 'o')
      .replaceAll('\u00e7', 'c');
}
