import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'main_shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PatiMatch',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF),
          brightness: Brightness.light,
          primary: const Color(0xFF0A84FF),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF374151)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFE8F1FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          labelStyle: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
      ),
      home: FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Baglanti baslatilamadi. Lutfen tekrar deneyin.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const MyApp()),
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
          return const MainShellPage(guestMode: true);
        },
      ),
    );
  }
}
