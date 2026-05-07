import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'main_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  ConfirmationResult? _confirmationResult;
  bool _loading = false;
  String _status = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty || !raw.startsWith('+')) {
      setState(() => _status = AppStrings.loginPhoneInvalid);
      return;
    }

    setState(() {
      _loading = true;
      _status = '';
    });

    try {
      _confirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(raw);
      setState(() => _status = AppStrings.loginCodeSent);
    } catch (e) {
      setState(() => _status = '${AppStrings.loginSendFailedPrefix}$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_confirmationResult == null) {
      setState(() => _status = AppStrings.loginSendCodeFirst);
      return;
    }
    final smsCode = _codeController.text.trim();
    if (smsCode.length < 6) {
      setState(() => _status = AppStrings.loginSmsCodeInvalid);
      return;
    }

    setState(() {
      _loading = true;
      _status = '';
    });

    try {
      final credential = await _confirmationResult!.confirm(smsCode);
      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'phone': user.phoneNumber,
          'displayName': '',
          'city': '',
          'district': '',
          'experienceLevel': 'first_time',
          'isBlocked': false,
          'blockedReason': null,
          'consentKvkk': true,
          'consentTerms': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() => _status = AppStrings.loginSuccessRedirect);
      }
    } catch (e) {
      setState(() => _status = '${AppStrings.loginVerifyFailedPrefix}$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: AppStrings.loginPhoneHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _sendCode,
              child: const Text(AppStrings.loginSendCode),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.loginSmsCodeHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _verifyCode,
              child: const Text(AppStrings.loginVerifyCode),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainShellPage(guestMode: true),
                        ),
                      );
                    },
              child: const Text('Misafir Olarak Devam Et'),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
