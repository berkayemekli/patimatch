import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/master_data/master_data_repository.dart';
import 'login_page.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  bool _loadingPlan = true;
  bool _saving = false;
  String _status = '';
  List<String> _principles = const <String>[];
  List<Map<String, dynamic>> _levels = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _providers = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final raw = await MasterDataRepository.loadIdentityVerificationPlan();
    final product = raw['verificationProduct'] as Map<String, dynamic>;
    if (!mounted) return;
    setState(() {
      _principles = (product['principles'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      _levels = (product['verificationLevels'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _providers = (product['recommendedProvidersToEvaluate'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _loadingPlan = false;
    });
  }

  Future<void> _startVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

    setState(() {
      _saving = true;
      _status = '';
    });

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('createVerificationSession');
      final result = await callable.call<Map<String, dynamic>>({
        'provider': 'veriff',
      });
      final data = result.data;
      final verificationUrl = data['verificationUrl']?.toString();
      final sdkToken = data['sdkToken']?.toString();
      if (verificationUrl != null && verificationUrl.isNotEmpty) {
        final opened = await launchUrl(
          Uri.parse(verificationUrl),
          webOnlyWindowName: '_blank',
          mode: LaunchMode.externalApplication,
        );
        if (!opened && mounted) {
          await _showVerificationInfoDialog(
            title: 'Doğrulama ekranı açılamadı',
            message:
              'Tarayıcı yeni pencereyi engellemiş olabilir. Gerçek sağlayıcı aktif olduğunda bu buton kimlik ve yüz doğrulama ekranını açacak.',
          );
        }
      } else if (sdkToken != null && sdkToken.isNotEmpty && mounted) {
        await _showVerificationInfoDialog(
          title: 'SDK oturumu hazır',
          message:
              'Sağlayıcı doğrulama tokenı üretildi. Sumsub/SDK ekranı bağlandığında aynı akış kimlik ve yüz doğrulamayı uygulama içinde açacak.',
        );
      }
      if (!mounted) return;
      setState(() {
        _status =
            'Doğrulama oturumu oluşturuldu. Gerçek sağlayıcı aktif olduğunda bu akış kimlik ve yüz/liveness ekranına gidecek.';
      });
    } on FirebaseFunctionsException catch (e) {
      await _createLocalPendingSession(
        user: user,
        message:
            'Backend function henuz aktif degil (${e.code}). Gecici dogrulama talebi olusturuldu.',
      );
    } catch (e) {
      await _createLocalPendingSession(
        user: user,
        message:
            'Backend function henuz aktif degil. Gecici dogrulama talebi olusturuldu.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createLocalPendingSession({
    required User user,
    required String message,
  }) async {
    try {
      final sessionRef = FirebaseFirestore.instance
          .collection('verificationSessions')
          .doc();
      final now = FieldValue.serverTimestamp();
      await sessionRef.set({
        'userId': user.uid,
        'provider': 'demo_pending_provider_selection',
        'status': 'pending',
        'providerReference': sessionRef.id,
        'createdAt': now,
        'updatedAt': now,
        'decisionReason':
            'Provider secilene kadar demo/pending dogrulama kaydi.',
      });
      if (!mounted) return;
      setState(() {
        _status = message;
      });
      await _showVerificationInfoDialog(
        title: 'Talep kaydedildi',
        message:
            'Şu an gerçek kimlik tarama ekranı açılmıyor çünkü Firebase Functions için Blaze plan ve KYC sağlayıcı entegrasyonu bekliyor. Talebini pending olarak kaydettim; Veriff/Sumsub gibi sağlayıcı bağlanınca aynı buton gerçek doğrulama ekranını açacak.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Doğrulama talebi oluşturulamadı: $e');
    }
  }

  Future<void> _showVerificationInfoDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil ve Guven')),
      body: _loadingPlan
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _HeroCard(user: user),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Mavi tik nasıl çalışacak?',
                  icon: Icons.verified_user_rounded,
                  children: _principles
                      .map((text) => _BulletLine(text: text))
                      .toList(),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Doğrulama seviyeleri',
                  icon: Icons.workspace_premium_rounded,
                  children: _levels
                      .map(
                        (level) => _LevelTile(
                          title: level['label']?.toString() ?? '',
                          badge: level['badge']?.toString() ?? '',
                          active:
                              level['key'] == 'phone_email' ||
                              level['key'] == 'identity',
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Değerlendirilecek sağlayıcılar',
                  icon: Icons.shield_rounded,
                  children: _providers
                      .map(
                        (provider) => _ProviderTile(
                          title: provider['label']?.toString() ?? '',
                          strengths:
                              (provider['strengths'] as List<dynamic>? ??
                                      const <dynamic>[])
                                  .map((item) => item.toString())
                                  .toList(),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saving ? null : _startVerification,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_rounded),
                  label: Text(
                    user == null
                        ? 'Giris yaparak dogrulama baslat'
                        : 'Doğrulama talebi oluştur',
                  ),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _StatusBox(text: _status),
                ],
              ],
            ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF0A84FF),
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mavi tikli güven profili',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  user == null
                      ? 'Kimlik doğrulama için önce hesaba giriş yapmalısın.'
                      : 'Hizmet verenler, hostlar ve ilan sahipleri için güven sinyali.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0F766E)),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFF0F766E),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.title,
    required this.badge,
    required this.active,
  });

  final String title;
  final String badge;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        active ? Icons.verified_rounded : Icons.radio_button_unchecked,
        color: active ? const Color(0xFF0A84FF) : const Color(0xFF94A3B8),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(badge.isEmpty ? 'Rozet yok' : badge),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.title, required this.strengths});

  final String title;
  final List<String> strengths;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            strengths.take(3).join(' - '),
            style: const TextStyle(color: Color(0xFF64748B), height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF475569))),
    );
  }
}
