import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _loading = true;
  bool _saving = false;
  final Map<String, Set<String>> _moduleRoles = <String, Set<String>>{};

  @override
  void initState() {
    super.initState();
    for (final module in _modules) {
      _moduleRoles[module.id] = <String>{};
    }
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snap.data();
    final saved = data?['moduleRoles'] as Map<String, dynamic>?;

    if (saved != null) {
      for (final module in _modules) {
        final raw = saved[module.id];
        if (raw is Map<String, dynamic>) {
          final roles = <String>{};
          if (raw['customer'] == true) roles.add('customer');
          if (raw['provider'] == true) roles.add('provider');
          _moduleRoles[module.id] = roles;
        }
      }
    } else {
      final legacyRoles = (data?['roles'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => e.toString())
          .where((e) => e == 'provider' || e == 'customer')
          .toSet();
      if (legacyRoles.isNotEmpty) {
        for (final module in _modules) {
          _moduleRoles[module.id] = Set<String>.from(legacyRoles);
        }
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveRoles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_hasAnySelection) return;

    setState(() => _saving = true);
    final moduleRolesPayload = <String, Map<String, dynamic>>{};
    final memberships = <String>[];
    final globalRoles = <String>{};

    for (final module in _modules) {
      final roles = _moduleRoles[module.id] ?? <String>{};
      moduleRolesPayload[module.id] = <String, dynamic>{
        'customer': roles.contains('customer'),
        'provider': roles.contains('provider'),
        'label': module.title,
      };
      for (final role in roles) {
        memberships.add('${module.id}:$role');
        globalRoles.add(role);
      }
    }

    memberships.sort();
    final sortedGlobalRoles = globalRoles.toList()..sort();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'roles': sortedGlobalRoles,
      'role': sortedGlobalRoles.contains('customer')
          ? 'customer'
          : sortedGlobalRoles.first,
      'moduleRoles': moduleRolesPayload,
      'serviceMemberships': memberships,
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) Navigator.of(context).pop(true);
  }

  bool get _hasAnySelection =>
      _moduleRoles.values.any((roles) => roles.isNotEmpty);

  void _toggleRole(String moduleId, String role) {
    setState(() {
      final roles = _moduleRoles[moduleId] ?? <String>{};
      if (roles.contains(role)) {
        roles.remove(role);
      } else {
        roles.add(role);
      }
      _moduleRoles[moduleId] = roles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Katılım ayarları'),
        backgroundColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    const Text(
                      'Hangi alanlarda yer almak istiyorsun?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Her alt platform için hizmet almak, hizmet vermek veya ikisini birlikte seçebilirsin.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.45,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ..._modules.map(
                      (module) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ModuleRoleCard(
                          module: module,
                          roles: _moduleRoles[module.id] ?? <String>{},
                          disabled: _saving,
                          onToggle: (role) => _toggleRole(module.id, role),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed:
                          (_saving || !_hasAnySelection) ? null : _saveRoles,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ModuleRoleCard extends StatelessWidget {
  const _ModuleRoleCard({
    required this.module,
    required this.roles,
    required this.disabled,
    required this.onToggle,
  });

  final _ServiceModule module;
  final Set<String> roles;
  final bool disabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final content = [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: module.softColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(module.icon, color: module.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RoleToggleChip(
                  label: 'Hizmet al',
                  icon: Icons.shopping_bag_outlined,
                  selected: roles.contains('customer'),
                  disabled: disabled,
                  color: const Color(0xFF2563EB),
                  onTap: () => onToggle('customer'),
                ),
                _RoleToggleChip(
                  label: 'Hizmet ver',
                  icon: Icons.storefront_rounded,
                  selected: roles.contains('provider'),
                  disabled: disabled,
                  color: const Color(0xFF0F766E),
                  onTap: () => onToggle('provider'),
                ),
              ],
            ),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content.first,
                const SizedBox(height: 14),
                content.last,
              ],
            );
          }
          return Row(
            children: [
              content.first,
              const SizedBox(width: 16),
              content.last,
            ],
          );
        },
      ),
    );
  }
}

class _RoleToggleChip extends StatelessWidget {
  const _RoleToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.disabled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool disabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: FilterChip(
        selected: selected,
        onSelected: disabled ? null : (_) => onTap(),
        avatar: Icon(
          selected ? Icons.check_circle_rounded : icon,
          size: 18,
          color: selected ? Colors.white : color,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w800,
        ),
        selectedColor: color,
        backgroundColor: const Color(0xFFF8FAFC),
        checkmarkColor: Colors.white,
        side: BorderSide(color: selected ? color : const Color(0xFFE2E8F0)),
      ),
    );
  }
}

class _ServiceModule {
  const _ServiceModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color softColor;
}

const List<_ServiceModule> _modules = <_ServiceModule>[
  _ServiceModule(
    id: 'patiGezdirme',
    title: 'PatiGezdirme',
    subtitle: 'Yuruyus destegi al veya gezdirici olarak katil.',
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF0F766E),
    softColor: Color(0xFFE7F7F2),
  ),
  _ServiceModule(
    id: 'patiBnb',
    title: 'PatiBnB',
    subtitle: 'Konaklama bul veya guvenilir host profili olustur.',
    icon: Icons.home_work_rounded,
    color: Color(0xFFF97316),
    softColor: Color(0xFFFFF2E8),
  ),
  _ServiceModule(
    id: 'patiMatch',
    title: 'PatiMatch',
    subtitle: 'Eslesme ara veya eslesme sureclerinde destek ver.',
    icon: Icons.favorite_rounded,
    color: Color(0xFFE11D48),
    softColor: Color(0xFFFFEEF3),
  ),
  _ServiceModule(
    id: 'patiFamily',
    title: 'PatiFamily',
    subtitle: 'Sahiplendirme destegi al veya yuva sureclerine katil.',
    icon: Icons.pets_rounded,
    color: Color(0xFF4F46E5),
    softColor: Color(0xFFEDEBFF),
  ),
];
