import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pati_match_page.dart';
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
      subtitle:
          'Saatlik veya d\u00fczenli y\u00fcr\u00fcy\u00fc\u015f planla, do\u011frulanm\u0131\u015f gezdiricilerle g\u00fcvenli rota olu\u015ftur.',
      icon: Icons.directions_walk,
      color: Color(0xFF0F766E),
      softColor: Color(0xFFE7F7F2),
    ),
    _ModuleItem(
      title: 'PatiBnB',
      subtitle:
          'Seyahat veya yo\u011fun g\u00fcnlerde ev tipi konaklama ve g\u00fcvenilir bak\u0131m se\u00e7eneklerini ke\u015ffet.',
      icon: Icons.home_work,
      color: Color(0xFFF97316),
      softColor: Color(0xFFFFF2E8),
    ),
    _ModuleItem(
      title: 'PatiMatch',
      subtitle:
          'Petinin karakterine, ya\u015f\u0131na ve lokasyonuna g\u00f6re g\u00fcvenli sosyal e\u015fle\u015fmeler bul.',
      icon: Icons.favorite,
      color: Color(0xFFE11D48),
      softColor: Color(0xFFFFEEF3),
    ),
    _ModuleItem(
      title: 'PatiFamily',
      subtitle:
          'Sahiplenme, aile olma ve uzun vadeli pet ebeveynli\u011fi s\u00fcre\u00e7lerini tek yerde y\u00f6net.',
      icon: Icons.pets,
      color: Color(0xFF4F46E5),
      softColor: Color(0xFFEDEBFF),
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
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
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
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _UserAvatarButton(user: user),
                ),
              ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _HeroModuleChooser(
                modules: _modules,
                selectedIndex: _selectedModuleIndex,
                onSelected: (index) =>
                    setState(() => _selectedModuleIndex = index),
              ),
              const SizedBox(height: 14),
              _ModuleInfoCard(module: _modules[_selectedModuleIndex]),
              const SizedBox(height: 20),
              _ModuleBody(index: _selectedModuleIndex),
            ],
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
              Positioned(right: -4, top: -4, child: _CountBadge(count: count)),
          ],
        );
      },
    );
  }

  Widget _buildPendingPaymentIcon(String? userId) {
    if (userId == null) {
      return const Icon(Icons.account_balance_wallet_outlined);
    }
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
              Positioned(right: -4, top: -4, child: _CountBadge(count: count)),
          ],
        );
      },
    );
  }
}

class _ModuleBody extends StatelessWidget {
  const _ModuleBody({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const PatiGezdirmePage();
      case 1:
        return const PatiBnbPage();
      case 2:
        return const PatiMatchPage();
      case 3:
        return const PatiParentPage();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _UserAvatarButton extends StatelessWidget {
  const _UserAvatarButton({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;
    final label = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email ?? 'Profil');
    final initial = label.trim().isEmpty ? 'P' : label.trim()[0].toUpperCase();

    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
        },
        child: CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFFEAF2FF),
          backgroundImage: photoUrl == null || photoUrl.isEmpty
              ? null
              : NetworkImage(photoUrl),
          child: photoUrl == null || photoUrl.isEmpty
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _HeroModuleChooser extends StatelessWidget {
  const _HeroModuleChooser({
    required this.modules,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_ModuleItem> modules;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 760;
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: double.infinity,
        height: compact ? 500 : 430,
        decoration: const BoxDecoration(color: Color(0xFF111827)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1600&q=82',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFF1F2937)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xCC0F172A),
                    Color(0x88111827),
                    Color(0xB3142A22),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 34,
                compact ? 18 : 28,
                compact ? 18 : 34,
                compact ? 22 : 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _HeroBrand(),
                  const Spacer(),
                  Text(
                    'Evcil dostun i\u00e7in\nneye ihtiyac\u0131n var?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 34 : 52,
                      height: 1.02,
                      letterSpacing: -1.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'G\u00fcvenli y\u00fcr\u00fcy\u00fc\u015f, s\u0131cak konaklama, do\u011fru e\u015fle\u015fme ve aile olma yolculu\u011fu tek yerde.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: compact ? 15 : 18,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _HeroModuleGrid(
                      modules: modules,
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Se\u00e7imini de\u011fi\u015ftirebilir, a\u015fa\u011f\u0131da detaylar\u0131 filtreleyebilirsin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBrand extends StatelessWidget {
  const _HeroBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.pets_rounded, color: Color(0xFF7DD3C7), size: 28),
        SizedBox(width: 8),
        Text(
          'PatiParent',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _HeroModuleGrid extends StatelessWidget {
  const _HeroModuleGrid({
    required this.modules,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_ModuleItem> modules;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List<Widget>.generate(modules.length, (index) {
            final module = modules[index];
            final selected = index == selectedIndex;
            return SizedBox(
              width: compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 30) / 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 16 : 12,
                    vertical: compact ? 14 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? module.color
                        : Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: compact
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(
                        module.icon,
                        color: selected ? Colors.white : module.color,
                        size: 22,
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: compact
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            Text(
                              module.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _shortLabel(module.title),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.82)
                                    : const Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  String _shortLabel(String title) {
    switch (title) {
      case 'PatiGezdirme':
        return 'Y\u00fcr\u00fcy\u00fc\u015f';
      case 'PatiBnB':
        return 'Konaklama';
      case 'PatiMatch':
        return 'E\u015fle\u015fme';
      case 'PatiFamily':
        return 'Aile';
      default:
        return '';
    }
  }
}

class _ModuleInfoCard extends StatelessWidget {
  const _ModuleInfoCard({required this.module});

  final _ModuleItem module;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: module.softColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: module.color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(module.icon, color: module.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    color: module.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class _ModuleItem {
  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color softColor;
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
