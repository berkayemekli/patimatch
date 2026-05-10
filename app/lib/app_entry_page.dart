import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_shell_page.dart';

class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  late Future<String?> _redirectResultFuture = _completeRedirectResult();

  Future<String?> _completeRedirectResult() async {
    try {
      await FirebaseAuth.instance.getRedirectResult();
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Google girişi tamamlanamadı: ${e.message ?? e.code}';
    } catch (_) {
      // No pending redirect is a normal app start condition.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _redirectResultFuture,
      builder: (context, redirectSnap) {
        if (redirectSnap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final redirectError = redirectSnap.data;
        if (redirectError != null && redirectError.isNotEmpty) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 34),
                    const SizedBox(height: 12),
                    Text(
                      redirectError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() {
                        _redirectResultFuture = _completeRedirectResult();
                      }),
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            final user = authSnap.data ?? FirebaseAuth.instance.currentUser;

            return user == null
                ? const MainShellPage(guestMode: true)
                : const MainShellPage();
          },
        );
      },
    );
  }
}
