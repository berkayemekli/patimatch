import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import 'discover_page.dart';
import 'login_page.dart';
import 'matches_page.dart';
import 'notifications_page.dart';
import 'pati_bnb_page.dart';
import 'pati_gezdirme_page.dart';
import 'pati_parent_page.dart';
import 'payments_page.dart';
import 'settings_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, this.guestMode = false});

  final bool guestMode;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedModuleIndex = 0;

  static const List<_ModuleItem> _modules = <_ModuleItem>[
    _ModuleItem(
      title: 'PatiGezdirme',
      subtitle: 'Saatlik veya duzenli gezdirici bul.',
      icon: Icons.directions_walk,
      color: Color(0xFF0A84FF),
    ),
    _ModuleItem(
      title: 'PatiBnB',
      subtitle: 'Seyahatlerde guvenli emanet bakici bul.',
      icon: Icons.home_work,
      color: Color(0xFF0A84FF),
    ),
    _ModuleItem(
      title: 'PatiMatch',
      subtitle: 'Kopegini uygun eslesmelerle bulustur.',
      icon: Icons.favorite,
      color: Color(0xFF0A84FF),
    ),
    _ModuleItem(
      title: 'PatiParent',
      subtitle: 'Sahiplenme ve ebeveynlik yolculugu.',
      icon: Icons.pets,
      color: Color(0xFF0A84FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = widget.guestMode && user == null;
    final maxWidth = MediaQuery.of(context).size.width > 1200 ? 1180.0 : 980.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F7FA),
        title: const Text('PatiParent'),
        actions: isGuest
            ? [
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Giris Yap'),
                ),
              ]
            : [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    );
                  },
                  icon: _buildNotificationIcon(user?.uid),
                  tooltip: 'Bildirimler',
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaymentsPage()),
                    );
                  },
                  icon: _buildPendingPaymentIcon(user?.uid),
                  tooltip: 'Odemeler',
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MatchesPage()),
                    );
                  },
                  icon: const Icon(Icons.forum_outlined),
                  tooltip: 'Eslesmeler',
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Ayarlar',
                ),
              ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAF7F2), Color(0xFFF2F6FF), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trusted Pet Parenting Ecosystem', style: TextStyle(fontSize: 13, color: Color(0xFF7C8AA0), fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            const Text(
                              'Her adimda\nsevgi, guven ve\npremium bakim',
                              style: TextStyle(fontSize: 56, fontWeight: FontWeight.w500, color: Color(0xFF0F172A), height: 1.02),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'PatiParent, evcil dostun icin dogru bakiciyi, guvenli yuruyusu ve huzurlu emanet deneyimini tek bir sicak platformda bulusturur.',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 17, height: 1.5),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF111827),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Guvenli Basla'),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Hikayemizi Kesfet'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          width: 280,
                          height: 220,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=900&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Color(0xFFE5E7EB)),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Color(0x990F172A), Color(0x22000000)],
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Text(
                                  'Dogrulanmis bakicilar,\nmutlu patiler, huzurlu ebeveynler.',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List<Widget>.generate(_modules.length, (index) {
                              final module = _modules[index];
                              final selected = index == _selectedModuleIndex;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => setState(() => _selectedModuleIndex = index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selected ? const Color(0xFF111827) : Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(module.icon, size: 19, color: selected ? Colors.white : const Color(0xFF475569)),
                                        const SizedBox(width: 8),
                                        Text(
                                          module.title,
                                          style: TextStyle(
                                            color: selected ? Colors.white : const Color(0xFF111827),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                const _StoryVisualCard(
                  title: 'Mutlu Yuruyus Rutinleri',
                  subtitle: 'Canli takip ve dogrulanmis gezdiricilerle guvenli yuruyusler.',
                  imageUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=1600&q=80',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: IndexedStack(
                        index: _selectedModuleIndex,
                        children: const [
                          PatiGezdirmePage(),
                          PatiBnbPage(),
                          DiscoverPage(embedded: true),
                          PatiParentPage(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String? userId) {
    if (userId == null) return const Icon(Icons.notifications_outlined);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: _CountBadge(count: count),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPendingPaymentIcon(String? userId) {
    if (userId == null) return const Icon(Icons.account_balance_wallet_outlined);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.account_balance_wallet_outlined),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: _CountBadge(count: count),
              ),
          ],
        );
      },
    );
  }
}

class _ModuleItem {
  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StoryVisualCard extends StatelessWidget {
  const _StoryVisualCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Color(0xFFE5E7EB)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xAA111827), Color(0x22000000)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, height: 1.15)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
