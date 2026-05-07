import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'data/app_providers.dart';
import 'data/booking_repository.dart';
import 'data/notification_repository.dart';
import 'data/payment_repository.dart';
import 'data/services_repository.dart';
import 'data/user_repository.dart';

class PatiGezdirmePage extends StatefulWidget {
  const PatiGezdirmePage({super.key});

  @override
  State<PatiGezdirmePage> createState() => _PatiGezdirmePageState();
}

class _PatiGezdirmePageState extends State<PatiGezdirmePage> {
  final ServicesRepository _servicesRepository = AppProviders.servicesRepository;
  final BookingRepository _bookingRepository = AppProviders.bookingRepository;
  final PaymentRepository _paymentRepository = AppProviders.paymentRepository;
  final NotificationRepository _notificationRepository =
      AppProviders.notificationRepository;
  final UserRepository _userRepository = AppProviders.userRepository;

  String _cityFilter = 'Tum Sehirler';
  bool _instantOnly = false;
  double _maxPrice = 400;

  static const List<String> _cityOptions = <String>[
    'Tum Sehirler',
    'Istanbul',
    'Ankara',
    'Izmir',
    'Bursa',
  ];

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> walkers) {
    return walkers.where((walker) {
      final city = (walker['city'] as String? ?? '').trim();
      final instant = walker['instantBooking'] == true;
      final pricePerHour = (walker['pricePerHour'] as num?)?.toInt() ?? 0;
      final cityOk = _cityFilter == 'Tum Sehirler' || city == _cityFilter;
      final instantOk = !_instantOnly || instant;
      final priceOk = pricePerHour <= _maxPrice.round();
      return cityOk && instantOk && priceOk;
    }).toList();
  }

  Future<void> _requestWalk(Map<String, dynamic> walker) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final myDog = await _userRepository.fetchMyDogDoc(user.uid);
    if (myDog == null) return;
    if (!mounted) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now,
      helpText: 'Yuruyus Gunu',
    );
    if (picked == null) return;
    if (!mounted) return;
    final tod = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 2))),
      helpText: 'Yuruyus Saati',
    );
    if (tod == null) return;
    if (!mounted) return;
    final noteController = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Talep Notu'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Varsa kisa not ekleyin (opsiyonel)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgec'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Gonder'),
            ),
          ],
        );
      },
    );
    if (approved != true) return;
    if (!mounted) return;

    final preferredAt = DateTime(
      picked.year,
      picked.month,
      picked.day,
      tod.hour,
      tod.minute,
    );

    final walkerId = walker['id'] as String? ?? '';
    final hasConflict = await _bookingRepository.hasWalkConflict(
      walkerId: walkerId,
      preferredAt: preferredAt,
    );
    if (hasConflict) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu saat icin gezdirici musait gorunmuyor.')),
      );
      return;
    }

    final requestId = await _servicesRepository.createWalkRequest(
      requesterUserId: user.uid,
      requesterDogId: myDog.id,
      walkerId: walkerId,
      walkerName: walker['name'] as String? ?? '',
      preferredAt: preferredAt,
      note: noteController.text.trim(),
    );
    final amount = (walker['pricePerHour'] as num?)?.toInt() ?? 0;
    await _paymentRepository.createPaymentIntent(
      userId: user.uid,
      requestId: requestId,
      module: 'walk',
      amountTry: amount,
    );
    await _notificationRepository.createInAppNotification(
      userId: user.uid,
      title: 'Gezdirme talebi alindi',
      body: 'Talebin olusturuldu. Odeme adimi bekleniyor.',
      type: 'walk_request_created',
      payload: <String, dynamic>{'requestId': requestId},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.walkRequestSent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _servicesRepository.watchWalkers(),
      builder: (context, snapshot) {
        final source = snapshot.hasError
            ? _servicesRepository.demoWalkers
            : (snapshot.data ?? _servicesRepository.demoWalkers);
        final walkers = _applyFilters(source);

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
                          items: _cityOptions
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
                      const SizedBox(width: 12),
                      FilterChip(
                        selected: _instantOnly,
                        onSelected: (selected) {
                          setState(() => _instantOnly = selected);
                        },
                        label: const Text('Aninda Musait'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Maks Saatlik:'),
                      const SizedBox(width: 8),
                      Text(
                        '${_maxPrice.round()} TL',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Slider(
                    min: 150,
                    max: 500,
                    divisions: 14,
                    value: _maxPrice,
                    label: '${_maxPrice.round()} TL',
                    onChanged: (value) => setState(() => _maxPrice = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: walkers.isEmpty
                  ? const Center(child: Text('Filtrelere uygun gezdirici bulunamadi.'))
                  : ListView.separated(
                          itemCount: walkers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                          itemBuilder: (context, index) {
                            final walker = walkers[index];
                            final name = walker['name'] as String? ?? '-';
                            final initial = name.isEmpty ? '?' : name.substring(0, 1);
                            final city = walker['city'] as String? ?? '-';
                            final walkCount = (walker['walkCount'] as num?)?.toInt() ?? 0;
                            final pricePerHour = (walker['pricePerHour'] as num?)?.toInt() ?? 0;
                            final instant = walker['instantBooking'] == true;
                            final bio = walker['bio'] as String? ?? '';
                            final rating = (walker['rating'] as num?)?.toDouble() ?? 0;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.teal.shade100,
                                          child: Text(initial),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text('$city - $walkCount yuruyus'),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text('Puan ${rating.toStringAsFixed(1)}'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(bio),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          '$pricePerHour TL/saat',
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 8),
                                        if (instant)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              'Aninda Musait',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () => _requestWalk(walker),
                                          child: const Text('Talep Gonder'),
                                        ),
                                      ],
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
}
