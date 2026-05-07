import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'data/app_providers.dart';
import 'data/booking_repository.dart';
import 'data/notification_repository.dart';
import 'data/payment_repository.dart';
import 'data/services_repository.dart';
import 'data/user_repository.dart';

class PatiBnbPage extends StatefulWidget {
  const PatiBnbPage({super.key});

  @override
  State<PatiBnbPage> createState() => _PatiBnbPageState();
}

class _PatiBnbPageState extends State<PatiBnbPage> {
  final ServicesRepository _servicesRepository = AppProviders.servicesRepository;
  final BookingRepository _bookingRepository = AppProviders.bookingRepository;
  final PaymentRepository _paymentRepository = AppProviders.paymentRepository;
  final NotificationRepository _notificationRepository =
      AppProviders.notificationRepository;
  final UserRepository _userRepository = AppProviders.userRepository;

  DateTimeRange? _dateRange;
  bool _verifiedOnly = true;
  double _maxNightlyPrice = 900;

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> hosts) {
    return hosts.where((host) {
      final verified = host['verified'] == true;
      final nightlyPrice = _asInt(host['nightlyPrice']);
      final verifiedOk = !_verifiedOnly || verified;
      final priceOk = nightlyPrice <= _maxNightlyPrice.round();
      return verifiedOk && priceOk;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      helpText: 'Konaklama Tarihleri',
    );
    if (result != null) {
      setState(() => _dateRange = result);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Future<void> _requestStay(Map<String, dynamic> host) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _dateRange == null) return;

    final myDog = await _userRepository.fetchMyDogDoc(user.uid);
    if (myDog == null) return;
    if (!mounted) return;
    final noteController = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konaklama Notu'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Beslenme / ilac gibi notlar (opsiyonel)',
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

    final hostId = host['id'] as String? ?? '';
    final hasConflict = await _bookingRepository.hasBnbConflict(
      hostId: hostId,
      checkIn: _dateRange!.start,
      checkOut: _dateRange!.end,
    );
    if (hasConflict) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Secilen tarihlerde bakici musait gorunmuyor.')),
      );
      return;
    }

    final requestId = await _servicesRepository.createBnbRequest(
      requesterUserId: user.uid,
      requesterDogId: myDog.id,
      hostId: hostId,
      hostName: host['name'] as String? ?? '',
      checkIn: _dateRange!.start,
      checkOut: _dateRange!.end,
      note: noteController.text.trim(),
    );
    final nightly = (host['nightlyPrice'] as num?)?.toInt() ?? 0;
    final nights = _dateRange!.duration.inDays.clamp(1, 365);
    await _paymentRepository.createPaymentIntent(
      userId: user.uid,
      requestId: requestId,
      module: 'bnb',
      amountTry: nightly * nights,
    );
    await _notificationRepository.createInAppNotification(
      userId: user.uid,
      title: 'Konaklama talebi alindi',
      body: 'Talebin olusturuldu. Odeme adimi bekleniyor.',
      type: 'bnb_request_created',
      payload: <String, dynamic>{'requestId': requestId},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.bnbRequestSent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateRange == null
        ? 'Tarih Sec'
        : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}';

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _servicesRepository.watchBnbHosts(),
      builder: (context, snapshot) {
        final raw = snapshot.data ?? <Map<String, dynamic>>[];
        final source = raw.isEmpty ? _servicesRepository.demoBnbHosts : raw;
        final hosts = _applyFilters(source);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.calendar_month),
                          label: Text(dateLabel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilterChip(
                        selected: _verifiedOnly,
                        onSelected: (value) => setState(() => _verifiedOnly = value),
                        label: const Text('Sadece Dogrulanmis'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Maks Gece Ucreti:'),
                      const SizedBox(width: 8),
                      Text(
                        '${_maxNightlyPrice.round()} TL',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxNightlyPrice,
                    min: 400,
                    max: 1200,
                    divisions: 16,
                    label: '${_maxNightlyPrice.round()} TL',
                    onChanged: (value) => setState(() => _maxNightlyPrice = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: hosts.isEmpty
                  ? Center(
                      child: Text(
                        'Filtrelere uygun bakici bulunamadi. (ham:${raw.length} kaynak:${source.length})',
                      ),
                    )
                  : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                          itemCount: hosts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final host = hosts[index];
                            final name = host['name'] as String? ?? '-';
                            final initial = name.isEmpty ? '?' : name.substring(0, 1);
                            final city = host['city'] as String? ?? '-';
                            final bio = host['bio'] as String? ?? '';
                            final yard = host['yard'] == true;
                            final verified = host['verified'] == true;
                            final nightlyPrice = _asInt(host['nightlyPrice']);
                            final rating = _asDouble(host['rating']);
                            final nights = _dateRange == null
                                ? 0
                                : _dateRange!.duration.inDays.clamp(1, 365);
                            final total = nights == 0 ? 0 : nightlyPrice * nights;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.orange.shade100,
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
                                              Text(city),
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
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if (verified) _tag('Dogrulanmis', Colors.green.shade100),
                                        _tag(yard ? 'Bahce Var' : 'Apartman', Colors.blue.shade100),
                                        _tag('$nightlyPrice TL/gece', Colors.grey.shade200),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (nights > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          '$nights gece • Toplam $total TL',
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: _dateRange == null ? null : () => _requestStay(host),
                                        child: const Text('Konaklama Talebi'),
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
