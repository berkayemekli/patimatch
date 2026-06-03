import 'package:flutter/material.dart';

import 'data/master_data/master_data_repository.dart';

class PatiVetPage extends StatefulWidget {
  const PatiVetPage({super.key});

  @override
  State<PatiVetPage> createState() => _PatiVetPageState();
}

class _PatiVetPageState extends State<PatiVetPage> {
  String _city = 'Tüm iller';
  String _district = 'Tüm ilçeler';
  String _search = '';
  List<String> _cities = const ['Tüm iller'];
  List<String> _districts = const [];
  List<Map<String, dynamic>> _clinics = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cities = await MasterDataRepository.loadCities();
    final clinics = await MasterDataRepository.loadVeterinaryClinics();
    if (!mounted) return;
    setState(() {
      _cities = ['Tüm iller', ...cities];
      _clinics = clinics;
    });
  }

  Future<void> _setCity(String city) async {
    final districts = city == 'Tüm iller'
        ? <String>[]
        : await MasterDataRepository.loadDistricts(city);
    if (!mounted) return;
    setState(() {
      _city = city;
      _district = 'Tüm ilçeler';
      _districts = districts;
    });
  }

  List<Map<String, dynamic>> get _filteredClinics {
    final query = _search.trim().toLowerCase();
    return _clinics.where((clinic) {
      final city = clinic['city']?.toString() ?? '';
      final district = clinic['district']?.toString() ?? '';
      final cityMatch = _city == 'Tüm iller' || city == _city;
      final districtMatch =
          _district == 'Tüm ilçeler' || district == _district;
      final text = [
        clinic['name'],
        city,
        district,
        ...(clinic['services'] as List<dynamic>? ?? const []),
        ...(clinic['badges'] as List<dynamic>? ?? const []),
      ].join(' ').toLowerCase();
      return cityMatch &&
          districtMatch &&
          (query.isEmpty || text.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clinics = _filteredClinics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PatiVetHeader(totalCount: clinics.length),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _VetDropdown(
              value: _city,
              options: _cities,
              onChanged: _setCity,
            ),
            _VetDropdown(
              value: _district,
              options: ['Tüm ilçeler', ..._districts],
              onChanged: (value) => setState(() => _district = value),
            ),
            SizedBox(
              width: 280,
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: InputDecoration(
                  hintText: 'Klinik, hizmet veya rozet ara',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (clinics.isEmpty)
          const _PatiVetEmptyState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 860 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clinics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 2.35 : 2.05,
                ),
                itemBuilder: (context, index) {
                  return _VetClinicCard(clinic: clinics[index]);
                },
              );
            },
          ),
      ],
    );
  }
}

class _PatiVetHeader extends StatelessWidget {
  const _PatiVetHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PatiVet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Şehir bazlı veteriner keşfi, yorum ve puanlama altyapısı.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _VetCountPill(count: totalCount),
        ],
      ),
    );
  }
}

class _VetCountPill extends StatelessWidget {
  const _VetCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count klinik',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _VetDropdown extends StatelessWidget {
  const _VetDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          items: options
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _VetClinicCard extends StatelessWidget {
  const _VetClinicCard({required this.clinic});

  final Map<String, dynamic> clinic;

  @override
  Widget build(BuildContext context) {
    final services = (clinic['services'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList();
    final badges = (clinic['badges'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList();
    final rating = clinic['rating'] as num? ?? 0;
    final reviewCount = clinic['reviewCount'] as int? ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  clinic['name'] as String? ?? 'Veteriner kliniği',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
              Text(
                ' ${rating.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_locationLabel(clinic)} - $reviewCount yorum',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...badges.map((badge) => _VetPill(label: badge, dark: true)),
              ...services.take(3).map((service) => _VetPill(label: service)),
            ],
          ),
          const Spacer(),
          const Divider(height: 18),
          const Text(
            'Puanlama ve yorum altyapısı hazır; doğrulanmış listeyle açılacak.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _locationLabel(Map<String, dynamic> clinic) {
    final city = clinic['city']?.toString() ?? '';
    final district = clinic['district']?.toString() ?? '';
    if (city.isEmpty && district.isEmpty) return 'Harita konumu mevcut';
    if (district.isEmpty) return city;
    if (city.isEmpty) return district;
    return '$district / $city';
  }
}

class _VetPill extends StatelessWidget {
  const _VetPill({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFFE7F7F2) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dark ? const Color(0xFF0F766E) : const Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PatiVetEmptyState extends StatelessWidget {
  const _PatiVetEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: const Text(
        'Bu bölge için doğrulanmış klinik listesi henüz hazır değil.',
        style: TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
