import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'blocked_users_page.dart';
import 'dog_profile_page.dart';
import 'login_page.dart';
import 'payments_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text(AppStrings.settingsEditProfile),
            subtitle: const Text(AppStrings.settingsEditProfileSub),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DogProfilePage()),
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaymentsPage()),
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
