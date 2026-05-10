import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  bool _showPhoneOtp = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _completePendingGoogleRedirect();
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
    setState(() {
      _loading = true;
      _status = 'Google giri\u015fi ba\u015flat\u0131l\u0131yor...';
    });

    final provider = GoogleAuthProvider()
      ..setCustomParameters(<String, String>{'prompt': 'select_account'});

    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithRedirect(provider);
        return;
      }

      final credential = await FirebaseAuth.instance
          .signInWithPopup(provider)
          .timeout(const Duration(seconds: 25));
      final user = credential.user ?? FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(
          () => _status =
              'Google hesab\u0131 al\u0131namad\u0131. L\u00fctfen tekrar dene.',
        );
        return;
      }
      await _finishSignedInUser(user);
    } on TimeoutException {
      setState(
        () => _status =
            'Google y\u00f6nlendirmesi ba\u015flat\u0131l\u0131yor...',
      );
      await FirebaseAuth.instance.signInWithRedirect(provider);
    } on FirebaseAuthException catch (e) {
      setState(() => _status = _friendlyAuthError(e));
    } catch (e) {
      setState(
        () => _status = 'Google giri\u015fi ba\u015flat\u0131lamad\u0131: $e',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completePendingGoogleRedirect() async {
    try {
      final credential = await FirebaseAuth.instance.getRedirectResult();
      final user = credential.user ?? FirebaseAuth.instance.currentUser;
      if (user != null) await _finishSignedInUser(user);
    } catch (_) {
      // Normal sayfa açılışlarında bekleyen yönlendirme olmayabilir.
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
    setState(() => _status = 'Giriş başarılı, yönlendiriliyor...');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellPage()),
      (route) => false,
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'unauthorized-domain':
        return 'Bu domain Google girişi için yetkili değil. Firebase Authentication > Authorized domains alanına eklenmeli.';
      case 'operation-not-allowed':
        return 'Google girişi Firebase tarafında aktif değil.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta farklı bir giriş yöntemiyle kayıtlı görünüyor.';
      default:
        return 'Google girişi tamamlanamadı: ${e.message ?? e.code}';
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
            'Güvenli şekilde devam et.',
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
            'Google, Apple, e-posta veya telefon ile hesabına giriş yap. Profilini sonra tamamlayabilirsin.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          _brandAuthButton(
            label: _loading
                ? 'Google ile bağlanıyor...'
                : 'Google ile devam et',
            fg: const Color(0xFF111827),
            bg: Colors.white,
            border: const Color(0xFF747775),
            iconWidget: const _GoogleLogo(size: 20),
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
      _status = '$provider girişi sonraki adımda aktif edilecek.';
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF172033), Color(0xFF214A52), Color(0xFFD8B99B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          Positioned(
            right: -44,
            top: -38,
            child: _BlurOrb(size: 180, color: const Color(0x55FFFFFF)),
          ),
          Positioned(
            left: -56,
            bottom: -60,
            child: _BlurOrb(size: 220, color: const Color(0x33FAD7A0)),
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
                  'Güvenli pet ebeveynliği',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Pet bakımını daha güvenli, daha sakin ve daha insani hale getiriyoruz.',
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
                'Gezdirme, konaklama, eşleşme ve sahiplenme süreçleri tek bir güven katmanında birleşir.',
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
          label: 'Doğrulanmış profiller',
        ),
        SizedBox(width: 10),
        _TrustPill(icon: Icons.lock_rounded, label: 'Güvenli giriş'),
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

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -0.12, 1.55, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 1.43, 1.35, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, 2.78, 1.18, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, 3.96, 1.45, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    final y = size.height * 0.52;
    canvas.drawLine(
      Offset(size.width * 0.52, y),
      Offset(size.width * 0.86, y),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
