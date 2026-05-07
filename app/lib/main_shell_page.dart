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
    _ModuleItem(title: 'PatiGezdirme', subtitle: 'Hourly dog walking intelligence.', icon: Icons.directions_walk),
    _ModuleItem(title: 'PatiBnB', subtitle: 'Trusted stay marketplace analytics.', icon: Icons.home_work),
    _ModuleItem(title: 'PatiMatch', subtitle: 'Compatibility and match performance.', icon: Icons.favorite),
    _ModuleItem(title: 'PatiParent', subtitle: 'Adoption funnel and trust signals.', icon: Icons.pets),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = widget.guestMode && user == null;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0F172A),
        title: const Text('PatiParent Intelligence'),
        actions: isGuest
            ? [
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
              ]
            : [
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
                  icon: _buildNotificationIcon(user?.uid),
                  tooltip: 'Notifications',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentsPage())),
                  icon: _buildPendingPaymentIcon(user?.uid),
                  tooltip: 'Payments',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchesPage())),
                  icon: const Icon(Icons.forum_outlined),
                  tooltip: 'Matches',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          const _HeroSection(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _KpiCard(title: 'Net Revenue', value: '?2.48M', delta: '+12.4%'),
              _KpiCard(title: 'Retention', value: '83.1%', delta: '+2.1%'),
              _KpiCard(title: 'AI Match Score', value: '91/100', delta: '+5.0'),
              _KpiCard(title: 'Risk Index', value: 'Low', delta: '-18%'),
            ],
          ),
          const SizedBox(height: 14),
          isMobile
              ? const Column(children: [_InsightPanel(), SizedBox(height: 10), _ChartPanel()])
              : const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 5, child: _ChartPanel()),
                  SizedBox(width: 10),
                  Expanded(flex: 3, child: _InsightPanel()),
                ]),
          const SizedBox(height: 14),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final module = _modules[index];
                final selected = index == _selectedModuleIndex;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedModuleIndex = index),
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(module.icon, size: 18, color: selected ? Colors.white : const Color(0xFF334155)),
                    const SizedBox(width: 6),
                    Text(module.title),
                  ]),
                  selectedColor: const Color(0xFF0F172A),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.blueGrey.shade100),
                  labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: _modules.length,
            ),
          ),
          const SizedBox(height: 10),
          Text(_modules[_selectedModuleIndex].subtitle, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          Container(
            height: 720,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Color(0x0F0F172A), blurRadius: 20, offset: Offset(0, 8))],
            ),
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
      stream: FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Stack(clipBehavior: Clip.none, children: [
          const Icon(Icons.notifications_outlined),
          if (count > 0) Positioned(right: -4, top: -4, child: _CountBadge(count: count)),
        ]);
      },
    );
  }

  Widget _buildPendingPaymentIcon(String? userId) {
    if (userId == null) return const Icon(Icons.account_balance_wallet_outlined);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('payments').where('userId', isEqualTo: userId).where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Stack(clipBehavior: Clip.none, children: [
          const Icon(Icons.account_balance_wallet_outlined),
          if (count > 0) Positioned(right: -4, top: -4, child: _CountBadge(count: count)),
        ]);
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC), Color(0xFFE6FFFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('AI Investment Intelligence for Pet Services', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 10),
        const Text('Trust-first growth cockpit: demand signals, pricing confidence, and operational insight across all modules.', style: TextStyle(fontSize: 15, color: Color(0xFF334155))),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, children: [
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white), child: const Text('Start Analysis')),
          OutlinedButton(onPressed: () {}, child: const Text('View Live Dashboard')),
        ]),
      ]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.title, required this.value, required this.delta});
  final String title;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text(delta, style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Demand & Revenue Trend', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFDDF4FF), Color(0xFFEFFCF7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Center(child: Text('Interactive chart preview', style: TextStyle(color: Color(0xFF475569)))),
          ),
        ),
      ]),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI Insight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        SizedBox(height: 10),
        Text('Istanbul segmentinde fiyat elastikiyeti yuksek. Premium walker fiyatlari %6 arttirilabilir.', style: TextStyle(color: Color(0xFFCBD5E1), height: 1.5)),
        SizedBox(height: 14),
        Chip(label: Text('Confidence 92%')),
      ]),
    );
  }
}

class _ModuleItem {
  const _ModuleItem({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
