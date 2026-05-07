import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'data/app_providers.dart';
import 'data/payment_repository.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final PaymentRepository _paymentRepository = AppProviders.paymentRepository;

  String _formatTimestamp(dynamic ts) {
    if (ts is! Timestamp) return '-';
    final dt = ts.toDate();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$day.$month.${dt.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.userNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odemelerim'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _paymentRepository.watchPaymentsForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final payments = snapshot.data ?? <Map<String, dynamic>>[];
          if (payments.isEmpty) {
            return const Center(
              child: Text('Henuz odeme kaydi bulunmuyor.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = payments[index];
              final paymentId = item['paymentId'] as String? ?? item['id'] as String? ?? '';
              final module = item['module'] as String? ?? '-';
              final status = item['status'] as String? ?? '-';
              final amount = (item['amountTry'] as num?)?.toInt() ?? 0;
              final createdAt = item['createdAt'];
              final paid = status == 'paid';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              module.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: paid ? Colors.green.shade100 : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              paid ? 'PAID' : 'PENDING',
                              style: TextStyle(
                                color: paid ? Colors.green.shade800 : Colors.orange.shade900,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Tutar: $amount TL'),
                      Text('Olusturma: ${_formatTimestamp(createdAt)}'),
                      const SizedBox(height: 10),
                      if (!paid)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _paymentRepository.markPaymentCompleted(
                                paymentId: paymentId,
                                userId: user.uid,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Odeme tamamlandi (demo).'),
                                ),
                              );
                            },
                            child: const Text('Odemeyi Tamamla (Demo)'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
