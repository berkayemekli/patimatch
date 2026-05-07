import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'data/app_providers.dart';
import 'data/services_repository.dart';
import 'data/user_repository.dart';

class PatiParentPage extends StatefulWidget {
  const PatiParentPage({super.key});

  @override
  State<PatiParentPage> createState() => _PatiParentPageState();
}

class _PatiParentPageState extends State<PatiParentPage> {
  final ServicesRepository _servicesRepository = AppProviders.servicesRepository;
  final UserRepository _userRepository = AppProviders.userRepository;

  String _cityFilter = 'Tum Sehirler';
  String _sizeFilter = 'Hepsi';
  bool _vaccinatedOnly = false;

  static const List<String> _cities = <String>[
    'Tum Sehirler',
    'Istanbul',
    'Ankara',
    'Izmir',
    'Bursa',
  ];

  static const List<String> _sizes = <String>[
    'Hepsi',
    'Kucuk',
    'Orta',
    'Buyuk',
  ];

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> posts) {
    return posts.where((post) {
      final city = (post['city'] as String? ?? '').trim();
      final size = (post['size'] as String? ?? '').trim();
      final vaccinated = post['vaccinated'] == true;
      final cityOk = _cityFilter == 'Tum Sehirler' || city == _cityFilter;
      final sizeOk = _sizeFilter == 'Hepsi' || size == _sizeFilter;
      final vaccineOk = !_vaccinatedOnly || vaccinated;
      return cityOk && sizeOk && vaccineOk;
    }).toList();
  }

  Future<void> _applyForAdoption(Map<String, dynamic> post) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final myDog = await _userRepository.fetchMyDogDoc(user.uid);
    if (myDog == null) return;

    await _servicesRepository.createAdoptionApplication(
      requesterUserId: user.uid,
      requesterDogId: myDog.id,
      postId: post['id'] as String? ?? '',
      dogName: post['dogName'] as String? ?? '',
      ownerUserId: post['ownerUserId'] as String? ?? '',
      note: 'In-app quick adoption application',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.adoptionApplicationSent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _servicesRepository.watchAdoptionPosts(),
      builder: (context, snapshot) {
        final posts = _applyFilters(snapshot.data ?? <Map<String, dynamic>>[]);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _cityFilter,
                          decoration: const InputDecoration(
                            labelText: 'Sehir',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _cities
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _cityFilter = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _sizeFilter,
                          decoration: const InputDecoration(
                            labelText: 'Boyut',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _sizes
                              .map(
                                (size) => DropdownMenuItem<String>(
                                  value: size,
                                  child: Text(size),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _sizeFilter = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChip(
                      selected: _vaccinatedOnly,
                      onSelected: (value) => setState(() => _vaccinatedOnly = value),
                      label: const Text('Sadece Asili Ilanlar'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: posts.isEmpty
                  ? const Center(child: Text('Filtrelere uygun ilan bulunamadi.'))
                  : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                          itemCount: posts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            final dogName = post['dogName'] as String? ?? '-';
                            final initial = dogName.isEmpty ? '?' : dogName.substring(0, 1);
                            final city = post['city'] as String? ?? '-';
                            final ageMonths = (post['ageMonths'] as num?)?.toInt() ?? 0;
                            final size = post['size'] as String? ?? '-';
                            final vaccinated = post['vaccinated'] == true;
                            final bio = post['bio'] as String? ?? '';
                            final ownerNote = post['ownerNote'] as String? ?? '';

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(initial),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dogName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text('$city - $ageMonths ay'),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(size),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(bio),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if (vaccinated) _tag('Asili', Colors.green.shade100),
                                        _tag('Sahiplendirme', Colors.purple.shade100),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text('Not: $ownerNote', style: TextStyle(color: Colors.grey.shade700)),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () => _applyForAdoption(post),
                                        child: const Text('Sahiplenme Basvurusu'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _tag(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
