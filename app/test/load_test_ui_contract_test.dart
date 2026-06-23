import 'package:flutter_test/flutter_test.dart';
import 'package:patimatch_app/data/marketplace_list_utils.dart';

void main() {
  final records = List<Map<String, dynamic>>.generate(250, (index) {
    final number = index + 1;
    return {
      'id': number,
      'city': number.isEven ? 'Istanbul' : 'Ankara',
      'district': number % 4 == 0 ? 'Kadikoy' : 'Cankaya',
      'petTypes': number % 5 == 0 ? ['Kedi'] : ['Kopek', 'Kedi'],
      'breeds': number % 3 == 0
          ? ['Golden Retriever', 'Maltese']
          : ['Tekir', 'Melez'],
      'verificationStatus': number % 5 == 0 ? 'verified' : 'phone_email',
    };
  });

  test('250 kayıt 20lik sayfalarda eksiksiz ve tekrarsız döner', () {
    final pagedIds = <int>[];
    for (var page = 0; page < 13; page += 1) {
      pagedIds.addAll(
        marketplacePage(records, page: page)
            .map((record) => record['id'] as int),
      );
    }
    expect(pagedIds.length, 250);
    expect(pagedIds.toSet().length, 250);
    expect(marketplacePage(records, page: 12).length, 10);
    expect(marketplacePage(records, page: 13), isEmpty);
  });

  test('şehir, ilçe, tür, cins ve doğrulama filtreleri birlikte çalışır', () {
    final filtered = filterMarketplaceRecords(
      records,
      city: 'Istanbul',
      district: 'Kadikoy',
      animalType: 'Kedi',
      breed: 'Tekir',
      verifiedOnly: true,
    );
    expect(filtered, isNotEmpty);
    expect(
      filtered.every(
        (record) =>
            record['city'] == 'Istanbul' &&
            record['district'] == 'Kadikoy' &&
            (record['petTypes'] as List).contains('Kedi') &&
            (record['breeds'] as List).contains('Tekir') &&
            record['verificationStatus'] == 'verified',
      ),
      isTrue,
    );
  });

  test('250 kayıt filtreleme işlemi temel performans bütçesinde kalır', () {
    final stopwatch = Stopwatch()..start();
    for (var iteration = 0; iteration < 100; iteration += 1) {
      filterMarketplaceRecords(
        records,
        city: iteration.isEven ? 'Istanbul' : 'Ankara',
        animalType: 'Kedi',
      );
    }
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}
