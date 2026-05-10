import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_shell_page.dart';

class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  late final Future<void> _redirectResultFuture = _completeRedirectResult();

  Future<void> _completeRedirectResult() async {
    try {
      await FirebaseAuth.instance.getRedirectResult();
    } catch (_) {
      // No pending redirect is a normal app start condition.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _redirectResultFuture,
      builder: (context, redirectSnap) {
        if (redirectSnap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
