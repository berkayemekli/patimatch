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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEAF2FF),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedModule.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(selectedModule.subtitle),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFD8E3F3)),
                  ),
                  child: Text(
                    '4 ModUl',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final module = _modules[index];
                final selected = index == _selectedModuleIndex;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedModuleIndex = index);
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        module.icon,
                        size: 18,
                        color: selected ? Colors.white : module.color,
                      ),
                      const SizedBox(width: 6),
                      Text(module.title),
                    ],
                  ),
                  selectedColor: const Color(0xFF111827),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF111827),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: _modules.length,
            ),
          ),
          const Divider(height: 1),
          Expanded(
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
        ],
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
