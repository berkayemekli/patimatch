import 'dart:convert';

import 'package:flutter/services.dart';

class MasterDataRepository {
  static Future<List<String>> loadCities() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/cities_districts_tr.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final cities = (json['cities'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
    return cities;
  }

  static Future<List<String>> loadDistricts(String city) async {
    final raw = await rootBundle.loadString(
      'assets/master_data/cities_districts_tr.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final cities = (json['cities'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final match = cities
        .where((c) => c['name'] == city)
        .cast<Map<String, dynamic>>()
        .toList();
    if (match.isEmpty) return <String>[];
    return (match.first['districts'] as List<dynamic>).cast<String>();
  }

  static Future<Map<String, List<String>>> loadAnimalBreeds() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/animal_breeds_tr.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = (json['animalCategories'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
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
    final raw = await rootBundle.loadString(
      'assets/master_data/animal_breeds_tr.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final vaccines = json['vaccines'] as Map<String, dynamic>;
    return <String, List<String>>{
      'Köpek': (vaccines['kopek'] as List<dynamic>).cast<String>(),
      'Kedi': (vaccines['kedi'] as List<dynamic>).cast<String>(),
      'Durum': (vaccines['statusOptions'] as List<dynamic>).cast<String>(),
    };
  }

  static Future<Map<String, dynamic>> loadMarketplaceExamples() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/seed_marketplace_examples.json',
    );
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<List<String>> loadTrustBadges() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/trust_safety_framework.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['trustBadges'] as List<dynamic>).cast<String>();
  }

  static Future<Map<String, dynamic>> loadIdentityVerificationPlan() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/identity_verification_blue_badge.json',
    );
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> loadVeterinaryClinics() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/veterinary_clinics_tr.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['clinics'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> loadPatiFriendlyPlaces() async {
    final raw = await rootBundle.loadString(
      'assets/master_data/pati_friendly_places_tr.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['places'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}

