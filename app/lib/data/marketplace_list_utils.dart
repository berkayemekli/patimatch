List<T> marketplacePage<T>(
  List<T> items, {
  required int page,
  int pageSize = 20,
}) {
  if (page < 0 || pageSize < 1) return <T>[];
  final start = page * pageSize;
  if (start >= items.length) return <T>[];
  final end = (start + pageSize).clamp(0, items.length);
  return items.sublist(start, end);
}

List<Map<String, dynamic>> filterMarketplaceRecords(
  List<Map<String, dynamic>> records, {
  String city = '',
  String district = '',
  String animalType = '',
  String breed = '',
  bool verifiedOnly = false,
}) {
  return records.where((record) {
    final recordBreeds = (record['breeds'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toSet();
    final petTypes = (record['petTypes'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toSet();
    return (city.isEmpty || record['city'] == city) &&
        (district.isEmpty || record['district'] == district) &&
        (animalType.isEmpty || petTypes.contains(animalType)) &&
        (breed.isEmpty || recordBreeds.contains(breed)) &&
        (!verifiedOnly || record['verificationStatus'] == 'verified');
  }).toList(growable: false);
}
