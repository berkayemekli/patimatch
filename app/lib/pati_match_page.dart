import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';
import 'widgets/smart_pet_image.dart';

class PatiMatchPage extends StatefulWidget {
  const PatiMatchPage({super.key});

  @override
  State<PatiMatchPage> createState() => _PatiMatchPageState();
}

class _PatiMatchPageState extends State<PatiMatchPage> {
  int _activeProfile = 0;
  int _activeIntent = 0;
  String _lastAction = 'Bugunun uyumlu profillerini kesfedebilirsin.';
  List<_PetMatchProfile> _profiles = _defaultProfiles;

  static const List<_MatchIntent> _intents = <_MatchIntent>[
    _MatchIntent('Tum eslesmeler', Icons.auto_awesome_rounded),
    _MatchIntent('Oyun arkadasi', Icons.sports_baseball_rounded),
    _MatchIntent('Sakin karakter', Icons.spa_rounded),
    _MatchIntent('Yakin cevre', Icons.near_me_rounded),
  ];

  static const List<_PetMatchProfile> _defaultProfiles = <_PetMatchProfile>[
    _PetMatchProfile(
      name: 'Luna',
      type: 'Golden Retriever',
      age: '2 yas',
      city: 'İstanbul / Kadıköy',
      distance: '3.2 km',
      score: 94,
      photo:
          'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=1100&q=84',
      owner: 'Derya',
      note: 'Sosyal, oyun seven ve park rutinine alisik.',
      tags: <String>['Asilari tam', 'Cocuklarla iyi', 'Park rutini'],
      vibe: 'Enerjik ama kontrollu',
      firstMessage: 'Luna hafta sonu Caddebostan sahilde yuruyuse uygun mu?',
    ),
    _PetMatchProfile(
      name: 'Maya',
      type: 'British Shorthair',
      age: '3 yas',
      city: 'İstanbul / Beşiktaş',
      distance: '5.8 km',
      score: 91,
      photo:
          'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=1100&q=84',
      owner: 'Ece',
      note: 'Sakin ev ziyaretleri ve kedi arkadasligi icin uygun.',
      tags: <String>['Sakin', 'Ev ortami', 'Kedi dostu'],
      vibe: 'Guvenli ve nazik',
      firstMessage: 'Maya yeni kedi arkadaslarina ne kadar hizli alisir?',
    ),
    _PetMatchProfile(
      name: 'Atlas',
      type: 'Kangal kirma',
      age: '4 yas',
      city: 'Ankara / Çankaya',
      distance: '7.1 km',
      score: 88,
      photo:
          'https://images.unsplash.com/photo-1568572933382-74d440642117?auto=format&fit=crop&w=1100&q=84',
      owner: 'Mert',
      note: 'Buyuk irklarla deneyimli sahipler icin dengeli eslesme.',
      tags: <String>['Buyuk irk', 'Egitimli', 'Bahce sever'],
      vibe: 'Guvenceli ve dengeli',
      firstMessage: 'Atlas kalabalik parklarda nasil davranir?',
    ),
    _PetMatchProfile(
      name: 'Pamuk',
      type: 'Tekir',
      age: '1.5 yas',
      city: 'İzmir / Karşıyaka',
      distance: '2.4 km',
      score: 86,
      photo:
          'https://images.unsplash.com/photo-1574158622682-e40e69881006?auto=format&fit=crop&w=1100&q=84',
      owner: 'Selin',
      note: 'Merakli, oyuncu ve yavas tanisma ritmini seviyor.',
      tags: <String>['Oyuncu', 'Yavas tanisma', 'Ev ziyareti'],
      vibe: 'Sicak ve merakli',
      firstMessage: 'Pamuk oyuncakla tanismayi sever mi?',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSeedProfiles();
  }

  Future<void> _loadSeedProfiles() async {
    final examples = await MasterDataRepository.loadMarketplaceExamples();
    final seedMatches = (examples['matches'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    if (seedMatches.isEmpty) return;

    final seededProfiles = seedMatches.asMap().entries.map((entry) {
      final index = entry.key;
      final match = entry.value;
      final fallback = _defaultProfiles[index % _defaultProfiles.length];
      final trust = (match['trust'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
      return _PetMatchProfile(
        name: match['petName'] as String? ?? fallback.name,
        type: [
          match['type'] as String? ?? '',
          match['breed'] as String? ?? '',
        ].where((part) => part.isNotEmpty).join(' - '),
        age: fallback.age,
        city: match['city'] as String? ?? fallback.city,
        distance: fallback.distance,
        score: fallback.score,
        photo: fallback.photo,
        owner: fallback.owner,
        note:
            '${match['matchGoal'] as String? ?? 'guvenli tanisma'} icin uygun, dogrulanmis profil.',
        tags: trust.isEmpty ? fallback.tags : trust,
        vibe: fallback.vibe,
        firstMessage: fallback.firstMessage,
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      _profiles = <_PetMatchProfile>[...seededProfiles, ..._defaultProfiles];
      _activeProfile = 0;
    });
  }

  void _nextProfile(String action) {
    final current = _profiles[_activeProfile];
    setState(() {
      _lastAction =
          '$action: ${current.name}. Uye olunca istek gonderebilirsin.';
      _activeProfile = (_activeProfile + 1) % _profiles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _profiles[_activeProfile];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MatchHero(active: active),
        const SizedBox(height: 18),
        _IntentSelector(
          intents: _intents,
          activeIndex: _activeIntent,
          onSelected: (index) => setState(() => _activeIntent = index),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            if (!wide) {
              return Column(
                children: [
                  _SwipeStage(
                    active: active,
                    next: _profiles[(_activeProfile + 1) % _profiles.length],
                    onPass: () => _nextProfile('Gecildi'),
                    onLike: () => _nextProfile('Begeni'),
                    onSuper: () => _nextProfile('Super pati'),
                  ),
                  const SizedBox(height: 16),
                  _MatchInsightPanel(active: active, lastAction: _lastAction),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _SwipeStage(
                    active: active,
                    next: _profiles[(_activeProfile + 1) % _profiles.length],
                    onPass: () => _nextProfile('Gecildi'),
                    onLike: () => _nextProfile('Begeni'),
                    onSuper: () => _nextProfile('Super pati'),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 4,
                  child: _MatchInsightPanel(
                    active: active,
                    lastAction: _lastAction,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _QueuePreview(
          profiles: _profiles,
          activeIndex: _activeProfile,
          onSelected: (index) => setState(() => _activeProfile = index),
        ),
      ],
    );
  }
}

class _MatchHero extends StatelessWidget {
  const _MatchHero({required this.active});

  final _PetMatchProfile active;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 720;
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7D6), Color(0xFFFFEEF3), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'PatiMatch beta',
                    style: TextStyle(
                      color: Color(0xFFE11D48),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Petin icin daha uyumlu, daha guvenli eslesmeler.',
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: compact ? 31 : 44,
                    height: 1.04,
                    letterSpacing: -1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Karakter, konum, yas, rutin ve guven sinyallerini birlikte okuyarak dogru tanisma akisini baslatir.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    height: 1.55,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 20),
            _FloatingMiniCard(active: active),
          ],
        ],
      ),
    );
  }
}

class _FloatingMiniCard extends StatelessWidget {
  const _FloatingMiniCard({required this.active});

  final _PetMatchProfile active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F111827),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SmartPetImage(
              source: active.photo,
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFFFFE4E6),
                child: SizedBox(width: 64, height: 64),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${active.score}% uyum',
                  style: const TextStyle(
                    color: Color(0xFFE11D48),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  active.distance,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
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

class _IntentSelector extends StatelessWidget {
  const _IntentSelector({
    required this.intents,
    required this.activeIndex,
    required this.onSelected,
  });

  final List<_MatchIntent> intents;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(intents.length, (index) {
          final intent = intents[index];
          final active = index == activeIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index == intents.length - 1 ? 0 : 10,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: Color(0x24111827),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      intent.icon,
                      size: 18,
                      color: active
                          ? const Color(0xFFFFD84D)
                          : const Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      intent.label,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SwipeStage extends StatelessWidget {
  const _SwipeStage({
    required this.active,
    required this.next,
    required this.onPass,
    required this.onLike,
    required this.onSuper,
  });

  final _PetMatchProfile active;
  final _PetMatchProfile next;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 520,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Opacity(
                    opacity: 0.52,
                    child: Transform.scale(
                      scale: 0.94,
                      child: _ProfileCard(profile: next, muted: true),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.96,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _ProfileCard(
                      key: ValueKey(active.name),
                      profile: active,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundActionButton(
                icon: Icons.close_rounded,
                color: const Color(0xFF111827),
                background: const Color(0xFFF1F5F9),
                onTap: onPass,
              ),
              const SizedBox(width: 14),
              _RoundActionButton(
                icon: Icons.pets_rounded,
                color: const Color(0xFF111827),
                background: const Color(0xFFFFD84D),
                large: true,
                onTap: onSuper,
              ),
              const SizedBox(width: 14),
              _RoundActionButton(
                icon: Icons.favorite_rounded,
                color: Colors.white,
                background: const Color(0xFFE11D48),
                onTap: onLike,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({super.key, required this.profile, this.muted = false});

  final _PetMatchProfile profile;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SmartPetImage(
            source: profile.photo,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: Color(0xFFFFEEF3)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x08000000),
                  Color(0x33000000),
                  Color(0xD9000000),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SoftBadge(
                      '${profile.score}% uyum',
                      Icons.auto_awesome_rounded,
                    ),
                    _SoftBadge(profile.distance, Icons.near_me_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${profile.name}, ${profile.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    height: 1,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profile.type} ? ${profile.city}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.note,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.tags
                      .map((tag) => _PhotoTag(tag: tag))
                      .toList(),
                ),
              ],
            ),
          ),
          if (muted) ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFE11D48)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTag extends StatelessWidget {
  const _PhotoTag({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 66.0 : 58.0;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A111827),
              blurRadius: 18,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: large ? 31 : 28),
      ),
    );
  }
}

class _MatchInsightPanel extends StatelessWidget {
  const _MatchInsightPanel({required this.active, required this.lastAction});

  final _PetMatchProfile active;
  final String lastAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uyum analizi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            active.vibe,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _InsightRow(
            icon: Icons.verified_user_rounded,
            title: 'Guven sinyali',
            text:
                '${active.owner} profili dogrulanmis, asi ve rutin bilgileri tamam.',
          ),
          _InsightRow(
            icon: Icons.place_rounded,
            title: 'Konum uyumu',
            text:
                '${active.city} bolgesinde ${active.distance} yakinlikta gorunuyor.',
          ),
          _InsightRow(
            icon: Icons.chat_bubble_rounded,
            title: 'Ilk mesaj onerisi',
            text: active.firstMessage,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7D6),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              lastAction,
              style: const TextStyle(
                color: Color(0xFF7A4B00),
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Uye olunca eslesme istegi gonder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFE11D48), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.35,
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

class _QueuePreview extends StatelessWidget {
  const _QueuePreview({
    required this.profiles,
    required this.activeIndex,
    required this.onSelected,
  });

  final List<_PetMatchProfile> profiles;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bugunun onerileri',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 960 ? 4 : (width >= 680 ? 3 : 2);
            final itemWidth = (width - ((columns - 1) * 12)) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(profiles.length, (index) {
                final profile = profiles[index];
                final active = index == activeIndex;
                return SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: active
                              ? const Color(0xFFE11D48)
                              : Colors.transparent,
                          width: active ? 1.4 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: AspectRatio(
                              aspectRatio: 1.2,
                              child: SmartPetImage(
                                source: profile.photo,
                                errorBuilder: (context, error, stackTrace) =>
                                    const ColoredBox(color: Color(0xFFFFEEF3)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.type,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
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
        ),
      ],
    );
  }
}

class _MatchIntent {
  const _MatchIntent(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _PetMatchProfile {
  const _PetMatchProfile({
    required this.name,
    required this.type,
    required this.age,
    required this.city,
    required this.distance,
    required this.score,
    required this.photo,
    required this.owner,
    required this.note,
    required this.tags,
    required this.vibe,
    required this.firstMessage,
  });

  final String name;
  final String type;
  final String age;
  final String city;
  final String distance;
  final int score;
  final String photo;
  final String owner;
  final String note;
  final List<String> tags;
  final String vibe;
  final String firstMessage;
}

