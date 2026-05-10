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

  Future<void> _saveRoles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_roles.isEmpty) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'roles': _roles.toList(),
      'role': _roles.first,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hesap Tipi Seçimi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PatiParent\'ı nasıl kullanmak istiyorsun?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text('Daha sonra Ayarlar bölümünden değiştirebilirsin.'),
                const SizedBox(height: 18),
                CheckboxListTile(
                  value: _roles.contains('provider'),
                  onChanged: _saving
                      ? null
                      : (v) => setState(() {
                            if (v == true) {
                              _roles.add('provider');
                            } else {
                              _roles.remove('provider');
                            }
                          }),
                  title: const Text('Hizmet Vermek İstiyorum'),
                  secondary: const Icon(Icons.storefront_outlined),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: _roles.contains('customer'),
                  onChanged: _saving
                      ? null
                      : (v) => setState(() {
                            if (v == true) {
                              _roles.add('customer');
                            } else {
                              _roles.remove('customer');
                            }
                          }),
                  title: const Text('Hizmet Almak İstiyorum'),
                  secondary: const Icon(Icons.pets_outlined),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (_saving || _roles.isEmpty) ? null : _saveRoles,
                  child: const Text('Devam Et'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
