import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _saving = false;
  final Set<String> _roles = <String>{};

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snap.data();
    final roles = (data?['roles'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => e.toString())
        .where((e) => e == 'provider' || e == 'customer')
        .toSet();
    if (!mounted || roles.isEmpty) return;
    setState(() => _roles.addAll(roles));
  }

  Future<void> _saveRoles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _roles.isEmpty) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'roles': _roles.toList()..sort(),
      'role': _roles.contains('customer') ? 'customer' : _roles.first,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text('Kullanım rolüm'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0F172A),
                    blurRadius: 34,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PatiParent’i nasıl kullanmak istiyorsun?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'İstersen iki rolü de seçebilirsin. Hem hizmet alabilir hem de uygun olduğunda hizmet verebilirsin.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _RoleCard(
                    selected: _roles.contains('customer'),
                    icon: Icons.pets_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: 'Hizmet almak istiyorum',
                    subtitle:
                        'Gezdirme, konaklama, eşleşme ve aile ilanlarında güvenli destek ara.',
                    onTap: _saving
                        ? null
                        : () => setState(() {
                              if (_roles.contains('customer')) {
                                _roles.remove('customer');
                              } else {
                                _roles.add('customer');
                              }
                            }),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    selected: _roles.contains('provider'),
                    icon: Icons.storefront_rounded,
                    iconColor: const Color(0xFF0F766E),
                    title: 'Hizmet vermek istiyorum',
                    subtitle:
                        'Gezdirici, host, eşleşme danışmanı veya sahiplendirme destek profili oluştur.',
                    onTap: _saving
                        ? null
                        : () => setState(() {
                              if (_roles.contains('provider')) {
                                _roles.remove('provider');
                              } else {
                                _roles.add('provider');
                              }
                            }),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: (_saving || _roles.isEmpty) ? null : _saveRoles,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kaydet ve devam et'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF93C5FD) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
