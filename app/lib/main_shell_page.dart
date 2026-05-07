import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final selectedModule = _modules[_selectedModuleIndex];
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
                            Text(
                              selectedModule.title,
                              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w500, color: Color(0xFF0F172A), height: 1.02),
                            ),
                            const SizedBox(height: 4),
                            Text(selectedModule.subtitle, style: const TextStyle(color: Color(0xFF475569), fontSize: 17, height: 1.5)),
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
                                  child: const Text('Nasil Calisir'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFD8E3F3)),
                        ),
                        child: const Text(
                          '4 Modules',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List<Widget>.generate(_modules.length, (index) {
                          final module = _modules[index];
                          final selected = index == _selectedModuleIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedModuleIndex = index),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(module.icon, size: 17, color: selected ? Colors.white : const Color(0xFF475569)),
                                  const SizedBox(width: 6),
                                  Text(module.title),
                                ],
                              ),
                              selectedColor: const Color(0xFF111827),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0x00000000)),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : const Color(0xFF111827),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                SizedBox(
                  height: 260,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _StoryVisualCard(
                        title: 'Guvenli Emanet Deneyimi',
                        subtitle: 'Dogrulanmis bakicilarla huzurlu seyahat',
                        imageUrl: 'https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=1200&q=80',
                      ),
                      SizedBox(width: 12),
                      _StoryVisualCard(
                        title: 'Mutlu Yuruyus Rutinleri',
                        subtitle: 'Canli takip ve premium gezdirici standartlari',
                        imageUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=1200&q=80',
                      ),
                      SizedBox(width: 12),
                      _StoryVisualCard(
                        title: 'Akilli Eslesme ve Bag Kurma',
                        subtitle: 'AI destekli uyum sinyalleriyle dogru eslesme',
                        imageUrl: 'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?auto=format&fit=crop&w=1200&q=80',
                      ),
                    ],
                  ),
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
