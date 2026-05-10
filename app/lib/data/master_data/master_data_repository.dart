import 'dart:convert';

import 'package:flutter/services.dart';

class MasterDataRepository {
  static Future<List<String>> loadCities() async {
    final raw = await rootBundle.loadString('assets/master_data/cities_districts_tr.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final cities = (json['cities'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
    return cities;
  }

  static Future<List<String>> loadDistricts(String city) async {
    final raw = await rootBundle.loadString('assets/master_data/cities_districts_tr.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final cities = (json['cities'] as List<dynamic>).cast<Map<String, dynamic>>();
    final match = cities.where((c) => c['name'] == city).cast<Map<String, dynamic>>().toList();
    if (match.isEmpty) return <String>[];
    return (match.first['districts'] as List<dynamic>).cast<String>();
  }

  static Future<Map<String, List<String>>> loadAnimalBreeds() async {
    final raw = await rootBundle.loadString('assets/master_data/animal_breeds_tr.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = (json['animalCategories'] as List<dynamic>).cast<Map<String, dynamic>>();
    final result = <String, List<String>>{};
    for (final c in categories) {
      final label = c['label'] as String;
      final breeds = (c['breeds'] as List<dynamic>).cast<String>();
      final mixes = (c['mixOptions'] as List<dynamic>).cast<String>();
      result[label] = <String>[...mixes, ...breeds];
    }
    return result;
  }

  static Future<Map<String, List<String>>> loadVaccines() async {
    final raw = await rootBundle.loadString('assets/master_data/animal_breeds_tr.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final vaccines = json['vaccines'] as Map<String, dynamic>;
    return <String, List<String>>{
      'Köpek': (vaccines['kopek'] as List<dynamic>).cast<String>(),
      'Kedi': (vaccines['kedi'] as List<dynamic>).cast<String>(),
      'Durum': (vaccines['statusOptions'] as List<dynamic>).cast<String>(),
    };
  }
}
