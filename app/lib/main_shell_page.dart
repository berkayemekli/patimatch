import 'package:flutter/material.dart';

import 'discover_page.dart';
import 'matches_page.dart';
import 'pati_bnb_page.dart';
import 'pati_gezdirme_page.dart';
import 'pati_parent_page.dart';
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
      color: Color(0xFF0E9F6E),
    ),
    _ModuleItem(
      title: 'PatiBnB',
      subtitle: 'Seyahatlerde guvenli emanet bakici bul.',
      icon: Icons.home_work,
      color: Color(0xFFF59E0B),
    ),
    _ModuleItem(
      title: 'PatiMatch',
      subtitle: 'Kopegini uygun eslesmelerle bulustur.',
      icon: Icons.favorite,
      color: Color(0xFFEF4444),
    ),
    _ModuleItem(
      title: 'PatiParent',
      subtitle: 'Sahiplenme ve ebeveynlik yolculugu.',
      icon: Icons.pets,
      color: Color(0xFF2563EB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedModule = _modules[_selectedModuleIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PatiParent'),
        actions: widget.guestMode
            ? [
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      'Misafir Modu',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ]
            : [
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
                  selectedModule.color.withValues(alpha: 0.16),
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
                    border: Border.all(color: selectedModule.color.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '4 ModUl',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selectedModule.color,
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
                  selectedColor: module.color,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
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
