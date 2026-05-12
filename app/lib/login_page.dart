import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  bool _showPhoneOtp = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
  }

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
      _confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
        raw,
      );
      setState(() => _status = AppStrings.loginCodeSent);
    } catch (e) {
      setState(() => _status = '${AppStrings.loginSendFailedPrefix}$e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
      if (user != null) await _finishSignedInUser(user);
    } catch (e) {
      setState(() => _status = '${AppStrings.loginVerifyFailedPrefix}$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _status = 'Google ile baglaniyor...';
    });

    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters(<String, String>{'prompt': 'select_account'});

    try {
      UserCredential credential;
      if (kIsWeb) {
        try {
          credential = await FirebaseAuth.instance
              .signInWithPopup(provider)
              .timeout(const Duration(seconds: 45));
        } on FirebaseAuthException catch (e) {
          if (e.code == 'popup-blocked' ||
              e.code == 'popup-closed-by-user' ||
              e.code == 'cancelled-popup-request' ||
              e.code == 'network-request-failed') {
            setState(() {
              _status =
                  'Popup tamamlanamadi, Google sayfasina yonlendiriliyor...';
            });
            await FirebaseAuth.instance.signInWithRedirect(provider);
            return;
          }
          rethrow;
        }
      } else {
        credential = await FirebaseAuth.instance.signInWithProvider(provider);
      }

      final user = credential.user ?? FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(
          () => _status = 'Google hesabi alinamadi. Lutfen tekrar dene.',
        );
        return;
      }
      await _finishSignedInUser(user);
    } on FirebaseAuthException catch (e) {
      setState(() => _status = _friendlyAuthError(e));
    } on TimeoutException {
      setState(() {
        _status =
            'Google girisi zaman asimina ugradi. Popup acildiysa kapatip tekrar dene.';
      });
    } catch (e) {
      setState(() => _status = 'Google girisi baslatilamadi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finishSignedInUser(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'phone': user.phoneNumber,
        'email': user.email,
        'displayName': user.displayName ?? '',
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
    } catch (_) {
      // Auth başarıyla tamamlandıysa profil dokümanı yazımı kullanıcıyı bloklamasın.
    }

    if (!mounted) return;
    setState(
      () => _status =
          'Giri\u015f ba\u015far\u0131l\u0131, y\u00f6nlendiriliyor...',
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellPage()),
      (route) => false,
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'unauthorized-domain':
        return 'Bu domain Google giri\u015fi i\u00e7in yetkili de\u011fil. Firebase Authentication > Authorized domains alan\u0131na eklenmeli.';
      case 'operation-not-allowed':
        return 'Google giri\u015fi Firebase taraf\u0131nda aktif de\u011fil.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta farkl\u0131 bir giri\u015f y\u00f6ntemiyle kay\u0131tl\u0131 g\u00f6r\u00fcn\u00fcyor.';
      default:
        return 'Google giri\u015fi tamamlanamad\u0131: ${e.message ?? e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 860;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFBF5), Color(0xFFF4F8FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F0F172A),
                        blurRadius: 48,
                        offset: Offset(0, 24),
                      ),
                    ],
                  ),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(child: _StoryPanel()),
                            Expanded(child: _authPanel()),
                          ],
                        )
                      : _authPanel(compact: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _authPanel({bool compact = false}) {
    return Padding(
      padding: EdgeInsets.all(compact ? 24 : 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SoftIcon(
                icon: Icons.pets_rounded,
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(width: 12),
              const Text(
                'PatiParent',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'G\u00fcvenli \u015fekilde devam et.',
            style: TextStyle(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Google, Apple, e-posta veya telefon ile hesab\u0131na giri\u015f yap. Profilini sonra tamamlayabilirsin.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          _brandAuthButton(
            label: _loading
                ? 'Google ile ba\u011flan\u0131yor...'
                : 'Google ile devam et',
            fg: const Color(0xFF111827),
            bg: Colors.white,
            border: const Color(0xFF747775),
            iconWidget: Image.asset(
              'assets/images/google_g.png',
              width: 20,
              height: 20,
            ),
            onTap: _signInWithGoogle,
          ),
          const SizedBox(height: 12),
          _brandAuthButton(
            label: 'Apple ile devam et',
            fg: Colors.white,
            bg: const Color(0xFF1F1F1F),
            border: const Color(0xFF1F1F1F),
            iconWidget: const Icon(
              Icons.apple_rounded,
              size: 24,
              color: Colors.white,
            ),
            onTap: () => _comingSoon('Apple'),
          ),
          const SizedBox(height: 12),
          _brandAuthButton(
            label: 'E-posta ile devam et',
            fg: const Color(0xFF111827),
            bg: Colors.white,
            border: const Color(0xFFD8DDE6),
            iconWidget: const Icon(Icons.mail_outline_rounded, size: 20),
            onTap: () => _comingSoon('E-posta'),
          ),
          const SizedBox(height: 12),
          _brandAuthButton(
            label: 'Telefon ile devam et',
            fg: const Color(0xFF111827),
            bg: Colors.white,
            border: const Color(0xFFD8DDE6),
            iconWidget: const Icon(Icons.phone_rounded, size: 20),
            onTap: () => setState(() => _showPhoneOtp = !_showPhoneOtp),
          ),
          if (_showPhoneOtp) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(AppStrings.loginPhoneHint),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _sendCode,
              child: const Text(AppStrings.loginSendCode),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(AppStrings.loginSmsCodeHint),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _verifyCode,
              child: const Text(AppStrings.loginVerifyCode),
            ),
          ],
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE5E7EB))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'veya',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainShellPage(guestMode: true),
                      ),
                      (route) => false,
                    );
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
              side: const BorderSide(color: Color(0xFFD8E7E2)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.pets_outlined),
            label: const Text(
              'Misafir olarak devam et',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InlineFeedback(text: _status),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _brandAuthButton({
    required String label,
    required Color fg,
    required Color bg,
    required Color border,
    Widget? iconWidget,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style:
          OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            foregroundColor: fg,
            backgroundColor: bg,
            side: BorderSide(color: border),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(fg.withValues(alpha: 0.06)),
          ),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: Center(child: iconWidget)),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  void _comingSoon(String provider) {
    setState(() {
      _status = '$provider giri\u015fi sonraki ad\u0131mda aktif edilecek.';
    });
  }
}

class _StoryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 620),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(34),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: AssetImage('assets/images/rony_login_story.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment(0.78, 0.72),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2B0F172A),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xD9172430),
                    Color(0x99173B3C),
                    Color(0x006B4A31),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -44,
            top: -38,
            child: _BlurOrb(size: 180, color: const Color(0x33FFFFFF)),
          ),
          Positioned(
            left: -56,
            bottom: -60,
            child: _BlurOrb(size: 220, color: const Color(0x22FAD7A0)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Text(
                  'G\u00fcvenli pet ebeveynli\u011fi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Pet bak\u0131m\u0131n\u0131 daha g\u00fcvenli, daha sakin ve daha insani hale getiriyoruz.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  height: 1.05,
                  letterSpacing: -1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Gezdirme, konaklama, e\u015fle\u015fme ve sahiplenme s\u00fcre\u00e7leri tek bir g\u00fcven katman\u0131nda birle\u015fir.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              const _TrustRow(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _TrustPill(
          icon: Icons.verified_rounded,
          label: 'Do\u011frulanm\u0131\u015f profiller',
        ),
        SizedBox(width: 10),
        _TrustPill(icon: Icons.lock_rounded, label: 'G\u00fcvenli giri\u015f'),
      ],
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF475569),
          height: 1.4,
        ),
      ),
    );
  }
}
