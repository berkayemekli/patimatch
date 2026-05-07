import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';
import 'data/app_providers.dart';
import 'data/swipe_repository.dart';
import 'data/user_repository.dart';
import 'firestore_payloads.dart';
import 'login_page.dart';
import 'matches_page.dart';
import 'settings_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  static const String _prefCityFilterKey = 'discover_city_filter';
  static const String _prefVerifiedOnlyKey = 'discover_verified_only';
  static const String _prefVaccinatedOnlyKey = 'discover_vaccinated_only';
  static const String _prefActivityFilterKey = 'discover_activity_filter';
  bool _loading = true;
  bool _swiping = false;
  String _status = '';
  String? _myDogId;
  String? _myOwnerId;
  final Set<String> _swipedDogIds = <String>{};
  final Set<String> _blockedOwnerIds = <String>{};
  final List<Map<String, dynamic>> _candidates = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _swipeHistory = <Map<String, dynamic>>[];
  DocumentSnapshot<Map<String, dynamic>>? _lastDogDoc;
  bool _hasMoreDogs = true;
  static const int _pageSize = 40;
  int _index = 0;
  String _cityFilter = 'all';
  String _myCity = '';
  bool _verifiedOnly = false;
  bool _vaccinatedOnly = false;
  String _activityFilter = 'all';
  DismissDirection _lastDismissDirection = DismissDirection.none;
  double _swipeProgress = 0;
  DismissDirection _swipeDirection = DismissDirection.none;
  final SwipeRepository _swipeRepository = AppProviders.swipeRepository;
  final UserRepository _userRepository = AppProviders.userRepository;
  bool _bootTimeoutFired = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (!mounted || !_loading) return;
      setState(() {
        _bootTimeoutFired = true;
        _loading = false;
        _status = 'Yukleme uzadi. Giris yaparak devam edebilirsin.';
      });
    });
    _initFiltersAndLoad();
  }

  Future<void> _initFiltersAndLoad() async {
    await _loadFilterPrefs();
    await _loadDiscoverData();
  }

  Future<void> _loadFilterPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCityFilter = prefs.getString(_prefCityFilterKey);
    final savedVerifiedOnly = prefs.getBool(_prefVerifiedOnlyKey);
    final savedVaccinatedOnly = prefs.getBool(_prefVaccinatedOnlyKey);
    final savedActivityFilter = prefs.getString(_prefActivityFilterKey);
    if (!mounted) return;
    setState(() {
      _cityFilter = savedCityFilter ?? _cityFilter;
      _verifiedOnly = savedVerifiedOnly ?? _verifiedOnly;
      _vaccinatedOnly = savedVaccinatedOnly ?? _vaccinatedOnly;
      _activityFilter = savedActivityFilter ?? _activityFilter;
    });
  }

  Future<void> _saveFilterPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCityFilterKey, _cityFilter);
    await prefs.setBool(_prefVerifiedOnlyKey, _verifiedOnly);
    await prefs.setBool(_prefVaccinatedOnlyKey, _vaccinatedOnly);
    await prefs.setString(_prefActivityFilterKey, _activityFilter);
  }

  Future<void> _loadDiscoverData() async {
    setState(() {
      _loading = true;
      _status = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _status = AppStrings.userNotFound;
          _loading = false;
        });
        return;
      }

      _myOwnerId = user.uid;
      _blockedOwnerIds
        ..clear()
        ..addAll(await _userRepository.fetchBlockedOwnerIds(user.uid));

      final myDogDoc = await _userRepository.fetchMyDogDoc(user.uid);
      if (myDogDoc == null) {
        setState(() {
          _status = AppStrings.discoverNeedProfile;
          _loading = false;
        });
        return;
      }

      _myDogId = myDogDoc.id;
      _myCity = (myDogDoc.data()['city'] as String? ?? '').trim();

      final swipesQuery = await FirebaseFirestore.instance
          .collection('swipes')
          .where('fromDogId', isEqualTo: _myDogId)
          .get();

      _swipedDogIds
        ..clear()
        ..addAll(
          swipesQuery.docs
              .map((d) => d.data()['toDogId'] as String?)
              .whereType<String>(),
        );

      _candidates.clear();
      _lastDogDoc = null;
      _hasMoreDogs = true;
      await _loadMoreDogs();

      setState(() {
        _index = 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status = '${AppStrings.discoverLoadFailedPrefix}$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadMoreDogs() async {
    if (_myDogId == null || !_hasMoreDogs) return;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('dogs')
        .where('isProfileComplete', isEqualTo: true);
    if (_verifiedOnly) {
      query = query.where('verificationStatus', isEqualTo: 'verified');
    }
    if (_cityFilter == 'my_city' && _myCity.isNotEmpty) {
      query = query.where('city', isEqualTo: _myCity);
    }
    query = query.limit(_pageSize);
    if (_lastDogDoc != null) {
      query = query.startAfterDocument(_lastDogDoc!);
    }

    final dogsQuery = await query.get();
    if (dogsQuery.docs.isEmpty) {
      _hasMoreDogs = false;
      return;
    }
    _lastDogDoc = dogsQuery.docs.last;
    if (dogsQuery.docs.length < _pageSize) {
      _hasMoreDogs = false;
    }

    final filtered = dogsQuery.docs
        .map(
          (doc) => <String, dynamic>{
            'dogId': doc.id,
            ...doc.data(),
          },
        )
        .where((dog) {
          final dogId = dog['dogId'] as String? ?? '';
          final ownerId = dog['ownerId'] as String? ?? '';
          final isVaccinated = dog['isVaccinated'] == true;
          final activityLevel = (dog['activityLevel'] as String? ?? '').trim();
          return dogId != _myDogId &&
              ownerId != _myOwnerId &&
              !_blockedOwnerIds.contains(ownerId) &&
              !_swipedDogIds.contains(dogId) &&
              (!_vaccinatedOnly || isVaccinated) &&
              (_activityFilter == 'all' || activityLevel == _activityFilter) &&
              !_candidates.any((e) => e['dogId'] == dogId);
        })
        .toList();

    _candidates.addAll(filtered);
  }

  Future<void> _swipe(bool liked) async {
    if (_swiping || _myDogId == null || _index >= _candidates.length) return;
    final target = _candidates[_index];
    final targetDogId = target['dogId'] as String;
    final targetOwnerId = target['ownerId'] as String? ?? '';

    setState(() {
      _swiping = true;
      _status = '';
      _lastDismissDirection =
          liked ? DismissDirection.startToEnd : DismissDirection.endToStart;
      _swipeProgress = 0;
      _swipeDirection = DismissDirection.none;
    });

    var didCreateMatch = false;
    var matchedDogName = '';
    try {
      didCreateMatch = await _swipeRepository.writeSwipeAndMaybeCreateMatch(
        myDogId: _myDogId!,
        myOwnerId: _myOwnerId!,
        targetDogId: targetDogId,
        targetOwnerId: targetOwnerId,
        liked: liked,
      );
      matchedDogName = target['name'] as String? ?? 'Bu kopekle';

      setState(() {
        _swipeHistory.add({
          'dog': target,
          'prevIndex': _index,
          'liked': liked,
        });
        _swipedDogIds.add(targetDogId);
        _index += 1;
        _status = liked ? AppStrings.discoverLikeSaved : AppStrings.discoverPassed;
        if (liked) {
          _status = AppStrings.discoverLikeMaybeMatch;
        }
      });
      if (_candidates.length - _index <= 3 && _hasMoreDogs) {
        await _loadMoreDogs();
        if (mounted) setState(() {});
      }

      if (didCreateMatch && mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eslesme Oldu!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$matchedDogName ile karsilikli begeni olustu.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Harika'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() => _status = '${AppStrings.discoverSwipeFailedPrefix}$e');
    } finally {
      setState(() {
        _swiping = false;
        _swipeProgress = 0;
        _swipeDirection = DismissDirection.none;
      });
    }
  }

  Future<void> _undoLastSwipe() async {
    if (_swiping || _swipeHistory.isEmpty || _myDogId == null) return;
    final last = _swipeHistory.last;
    final dog = last['dog'] as Map<String, dynamic>;
    final liked = last['liked'] == true;
    final prevIndex = (last['prevIndex'] as int?) ?? 0;
    final targetDogId = dog['dogId'] as String? ?? '';
    if (targetDogId.isEmpty) return;

    setState(() {
      _swiping = true;
      _status = '';
    });

    try {
      await _swipeRepository.undoLastSwipe(
        myDogId: _myDogId!,
        targetDogId: targetDogId,
        liked: liked,
      );

      setState(() {
        _swipeHistory.removeLast();
        _swipedDogIds.remove(targetDogId);
        if (_candidates.where((e) => e['dogId'] == targetDogId).isEmpty) {
          final insertAt = prevIndex.clamp(0, _candidates.length);
          _candidates.insert(insertAt, dog);
        }
        _index = prevIndex.clamp(0, _candidates.isEmpty ? 0 : _candidates.length - 1);
        _status = AppStrings.discoverUndoDone;
      });
    } catch (e) {
      setState(() => _status = '${AppStrings.discoverUndoFailedPrefix}$e');
    } finally {
      setState(() => _swiping = false);
    }
  }

  Future<void> _blockOwner(Map<String, dynamic> dog) async {
    final myOwnerId = _myOwnerId;
    final targetOwnerId = dog['ownerId'] as String? ?? '';
    final targetDogId = dog['dogId'] as String? ?? '';
    if (myOwnerId == null || targetOwnerId.isEmpty) return;

    setState(() {
      _swiping = true;
      _status = '';
    });

    try {
      final db = FirebaseFirestore.instance;
      final blockId = '${myOwnerId}_$targetOwnerId';
      await db.collection('blocks').doc(blockId).set(
            FirestorePayloads.block(
              blockId: blockId,
              userId: myOwnerId,
              blockedUserId: targetOwnerId,
              reason: 'user_action',
            ),
            SetOptions(merge: true),
          );

      setState(() {
        _blockedOwnerIds.add(targetOwnerId);
        _candidates.removeWhere((e) => e['ownerId'] == targetOwnerId);
        if (_index >= _candidates.length) {
          _index = _candidates.isEmpty ? 0 : _candidates.length - 1;
        }
        _status = AppStrings.discoverBlockDone;
        if (targetDogId.isNotEmpty) {
          _swipedDogIds.add(targetDogId);
        }
      });
    } catch (e) {
      setState(() => _status = '${AppStrings.discoverBlockFailedPrefix}$e');
    } finally {
      setState(() => _swiping = false);
    }
  }

  Future<void> _reportDog(Map<String, dynamic> dog) async {
    final myOwnerId = _myOwnerId;
    final targetOwnerId = dog['ownerId'] as String? ?? '';
    final targetDogId = dog['dogId'] as String? ?? '';
    if (myOwnerId == null || targetOwnerId.isEmpty || targetDogId.isEmpty) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Rapor Nedeni'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'spam'),
              child: const Text('Spam'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'fake_profile'),
              child: const Text('Sahte Profil'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'harassment'),
              child: const Text('Rahatsiz Edici Icerik'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'other'),
              child: const Text('Diger'),
            ),
          ],
        );
      },
    );
    if (reason == null) return;

    try {
      final reportRef = FirebaseFirestore.instance.collection('reports').doc();
      await reportRef.set(
        FirestorePayloads.reportUserOrDog(
          reportId: reportRef.id,
          reporterUserId: myOwnerId,
          reportedUserId: targetOwnerId,
          reportedDogId: targetDogId,
          reasonCode: reason,
          description: 'In-app quick report: $reason',
        ),
        SetOptions(merge: true),
      );
      setState(() => _status = AppStrings.discoverReportDone);
    } catch (e) {
      setState(() => _status = '${AppStrings.discoverReportFailedPrefix}$e');
    }
  }

  Widget _buildDogCard(Map<String, dynamic> dog) {
    final name = dog['name'] as String? ?? '-';
    final breed = dog['breed'] as String? ?? '-';
    final city = dog['city'] as String? ?? '-';
    final ageMonths = dog['ageMonths']?.toString() ?? '-';
    final weightKg = dog['weightKg']?.toString() ?? '-';
    final activityLevel = dog['activityLevel'] as String? ?? '-';
    final vaccinated = dog['isVaccinated'] == true;
    final friendlyDogs = dog['friendlyWithDogs'] == true;
    final friendlyKids = dog['friendlyWithKids'] == true;
    final photos = (dog['photoUrls'] as List<dynamic>? ?? <dynamic>[])
        .whereType<String>()
        .toList();
    final photoUrl = photos.isNotEmpty ? photos.first : null;

    return Dismissible(
      key: ValueKey<String>(dog['dogId'] as String? ?? '${name}_$ageMonths'),
      direction: _swiping
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (_swiping) return false;
        _lastDismissDirection = direction;
        await _swipe(direction == DismissDirection.startToEnd);
        return false;
      },
      onUpdate: (details) {
        setState(() {
          _swipeProgress = details.progress.clamp(0.0, 1.0);
          _swipeDirection = details.direction;
        });
      },
      onDismissed: (direction) {},
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Begen',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Gec',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.clear, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 260,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      photoUrl == null
                          ? const ColoredBox(
                              color: Color(0xFFECECEC),
                              child: Center(child: Icon(Icons.pets, size: 64)),
                            )
                          : Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const ColoredBox(
                                  color: Color(0xFFF2F2F2),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                                color: Color(0xFFECECEC),
                                child: Center(child: Icon(Icons.broken_image, size: 40)),
                              ),
                            ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x66000000),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'report') {
                              await _reportDog(dog);
                            } else if (value == 'block') {
                              await _blockOwner(dog);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'report',
                              child: Text('Raporla'),
                            ),
                            PopupMenuItem(
                              value: 'block',
                              child: Text('Kullaniciyi Engelle'),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text('Irk: $breed'),
                      Text('Yas: $ageMonths ay'),
                      Text('Kilo: $weightKg kg'),
                      Text('Aktivite: $activityLevel'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('Sehir: $city'),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (vaccinated)
                            _tagChip('Asili', Colors.green.shade100),
                          if (friendlyDogs)
                            _tagChip('Kopeklerle Uyumlu', Colors.blue.shade100),
                          if (friendlyKids)
                            _tagChip('Cocuklarla Uyumlu', Colors.orange.shade100),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_swipeDirection == DismissDirection.startToEnd)
              Positioned(
                top: 18,
                left: 18,
                child: Opacity(
                  opacity: _swipeProgress,
                  child: Transform.rotate(
                    angle: -0.22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade700, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      child: Text(
                        'LIKE',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_swipeDirection == DismissDirection.endToStart)
              Positioned(
                top: 18,
                right: 18,
                child: Opacity(
                  opacity: _swipeProgress,
                  child: Transform.rotate(
                    angle: 0.22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade700, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      child: Text(
                        'NOPE',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStackedCards() {
    if (_myOwnerId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 42, color: Color(0xFF64748B)),
              const SizedBox(height: 10),
              const Text(
                'PatiMatch icin giris yapman gerekiyor.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Giris yaptiginda profiline gore eslesmeleri gosterecegiz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
                child: const Text('Giris / Profil Ayarlari'),
              ),
            ],
          ),
        ),
      );
    }

    if (_candidates.isEmpty || _index >= _candidates.length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.discoverNoMoreDogs,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _hasMoreDogs
                  ? () async {
                      await _loadMoreDogs();
                      if (mounted) setState(() {});
                    }
                  : null,
              child: const Text('Daha Fazla Yukle'),
            ),
          ],
        ),
      );
    }

    final current = _candidates[_index];
    final next1 = _index + 1 < _candidates.length ? _candidates[_index + 1] : null;
    final next2 = _index + 2 < _candidates.length ? _candidates[_index + 2] : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            if (next2 != null)
              Positioned(
                top: 22,
                child: IgnorePointer(
                  child: Transform.scale(
                    scale: 0.93,
                    child: Opacity(
                      opacity: 0.35,
                      child: SizedBox(
                        width: constraints.maxWidth * 0.96,
                        child: _buildDogCard(next2),
                      ),
                    ),
                  ),
                ),
              ),
            if (next1 != null)
              Positioned(
                top: 10,
                child: IgnorePointer(
                  child: Transform.scale(
                    scale: 0.965,
                    child: Opacity(
                      opacity: 0.6,
                      child: SizedBox(
                        width: constraints.maxWidth * 0.985,
                        child: _buildDogCard(next1),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  );
                  final scale = Tween<double>(begin: 0.94, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                  );
                  return FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: _buildDogCard(current),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if ((!_loading || _bootTimeoutFired) && _myOwnerId == null) {
      final guestFallback = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 44, color: Color(0xFF64748B)),
                  const SizedBox(height: 10),
                  const Text(
                    'PatiMatch icin giris gerekli',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Eslesmeleri gorebilmek icin once hesabina giris yap.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Giris Yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (widget.embedded) return guestFallback;
      return Scaffold(body: guestFallback);
    }

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _buildStackedCards(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _miniFilterChip(_cityFilter == 'my_city' ? 'Sehir: $_myCity' : 'Tum Sehirler'),
                    _miniFilterChip(_verifiedOnly ? 'Verified' : 'All Profiles'),
                    _miniFilterChip(_vaccinatedOnly ? 'Asili' : 'Asi Serbest'),
                    _miniFilterChip(_activityFilter == 'all' ? 'Aktivite: Tum' : 'Aktivite: $_activityFilter'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundActionButton(
                      onTap: _swiping ? null : () => _swipe(false),
                      icon: Icons.close_rounded,
                      bg: const Color(0xFFF3F4F6),
                      fg: const Color(0xFF111827),
                    ),
                    const SizedBox(width: 18),
                    _roundActionButton(
                      onTap: _swiping ? null : () => _swipe(true),
                      icon: Icons.favorite_rounded,
                      bg: const Color(0xFF111827),
                      fg: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _status,
                  style: TextStyle(
                    color: _lastDismissDirection == DismissDirection.startToEnd
                        ? Colors.green.shade700
                        : (_lastDismissDirection == DismissDirection.endToStart
                            ? Colors.grey.shade700
                            : null),
                  ),
                ),
              ],
            ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  IconButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _verifiedOnly = !_verifiedOnly;
                            });
                            _saveFilterPrefs();
                            _loadDiscoverData();
                          },
                    icon: Icon(
                      _verifiedOnly ? Icons.verified : Icons.verified_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: (_swiping || _swipeHistory.isEmpty) ? null : _undoLastSwipe,
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _vaccinatedOnly = !_vaccinatedOnly;
                            });
                            _saveFilterPrefs();
                            _loadDiscoverData();
                          },
                    icon: Icon(
                      _vaccinatedOnly ? Icons.shield : Icons.shield_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              if (_activityFilter == 'all') {
                                _activityFilter = 'low';
                              } else if (_activityFilter == 'low') {
                                _activityFilter = 'medium';
                              } else if (_activityFilter == 'medium') {
                                _activityFilter = 'high';
                              } else {
                                _activityFilter = 'all';
                              }
                            });
                            _saveFilterPrefs();
                            _loadDiscoverData();
                          },
                    icon: const Icon(Icons.directions_run),
                  ),
                  IconButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _cityFilter = _cityFilter == 'all' ? 'my_city' : 'all';
                            });
                            _saveFilterPrefs();
                            _loadDiscoverData();
                          },
                    icon: Icon(_cityFilter == 'all' ? Icons.public : Icons.location_city),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _loadDiscoverData,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesfet'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MatchesPage()),
              );
            },
            icon: const Icon(Icons.favorite),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    setState(() {
                      _verifiedOnly = !_verifiedOnly;
                    });
                    _saveFilterPrefs();
                    _loadDiscoverData();
                  },
            icon: Icon(
              _verifiedOnly ? Icons.verified : Icons.verified_outlined,
            ),
          ),
          IconButton(
            onPressed: (_swiping || _swipeHistory.isEmpty) ? null : _undoLastSwipe,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    setState(() {
                      _vaccinatedOnly = !_vaccinatedOnly;
                    });
                    _saveFilterPrefs();
                    _loadDiscoverData();
                  },
            icon: Icon(
              _vaccinatedOnly ? Icons.shield : Icons.shield_outlined,
            ),
          ),
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    setState(() {
                      if (_activityFilter == 'all') {
                        _activityFilter = 'low';
                      } else if (_activityFilter == 'low') {
                        _activityFilter = 'medium';
                      } else if (_activityFilter == 'medium') {
                        _activityFilter = 'high';
                      } else {
                        _activityFilter = 'all';
                      }
                    });
                    _saveFilterPrefs();
                    _loadDiscoverData();
                  },
            icon: const Icon(Icons.directions_run),
          ),
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    setState(() {
                      _cityFilter = _cityFilter == 'all' ? 'my_city' : 'all';
                    });
                    _saveFilterPrefs();
                    _loadDiscoverData();
                  },
            icon: Icon(_cityFilter == 'all' ? Icons.public : Icons.location_city),
          ),
          IconButton(
            onPressed: _loading ? null : _loadDiscoverData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _miniFilterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
      ),
    );
  }

  Widget _roundActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required Color bg,
    required Color fg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 7))],
        ),
        child: Icon(icon, color: fg, size: 30),
      ),
    );
  }
}
