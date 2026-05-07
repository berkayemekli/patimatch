import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dog_profile_page.dart';
import 'login_page.dart';
import 'main_shell_page.dart';

class AppEntryPage extends StatelessWidget {
  const AppEntryPage({super.key});

  Future<bool> _hasDogProfile(String uid) async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('dogs')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      return q.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data ?? FirebaseAuth.instance.currentUser;

        if (user == null) {
          return const LoginPage();
        }

        return FutureBuilder<bool>(
          future: _hasDogProfile(user.uid),
          builder: (context, dogSnap) {
            if (dogSnap.connectionState == ConnectionState.waiting) {
              return const _EntryWaitFallback();
            }
            final hasDog = dogSnap.data == true;
            return hasDog ? const MainShellPage() : const DogProfilePage();
          },
        );
      },
    );
  }
}

class _EntryWaitFallback extends StatefulWidget {
  const _EntryWaitFallback();

  @override
  State<_EntryWaitFallback> createState() => _EntryWaitFallbackState();
}

class _EntryWaitFallbackState extends State<_EntryWaitFallback> {
  bool _longWait = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      setState(() => _longWait = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_longWait) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yukleme uzadi. Devam etmek icin tekrar deneyin.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AppEntryPage()),
                  );
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
