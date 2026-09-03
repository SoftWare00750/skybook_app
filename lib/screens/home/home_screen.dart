import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/bottom_nav.dart';
import '../search/search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tripType = 1; // 0 one way, 1 round trip, 2 multi-city

  final _destinations = const [
    {'city': 'London', 'icon': Icons.location_city},
    {'city': 'Paris', 'icon': Icons.location_city},
    {'city': 'Bangkok', 'icon': Icons.location_city},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Afternoon', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Where would you like to go?', style: TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.inputFill, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(
                  children: [
                    _tripTypeTab('One way', 0),
                    _tripTypeTab('Round trip', 1),
                    _tripTypeTab('Multi-city', 2),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _fieldRow('From', 'New York (JFK)', trailing: const Icon(Icons.swap_vert, color: AppColors.primary)),
                    const Divider(height: 28),
                    _fieldRow('To', 'London (LHR)'),
                    const Divider(height: 28),
                    Row(
                      children: [
                        Expanded(child: _fieldRow('Departure', '15 Jun, 2023')),
                        const SizedBox(width: 16),
                        Expanded(child: _fieldRow('Return', '22 Jun, 2023')),
                      ],
                    ),
                    const Divider(height: 28),
                    _fieldRow('Passengers', '1 Adult, Economy'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Search Flights',
                icon: Icons.search,
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SearchResultsScreen())),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular Destinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('See all')),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _destinations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final d = _destinations[i];
                    return Column(
                      children: [
                        Container(
                          width: 90,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(d['icon'] as IconData, color: AppColors.primary, size: 32),
                        ),
                        const SizedBox(height: 6),
                        Text(d['city'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _tripTypeTab(String label, int index) {
    final selected = _tripType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tripType = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textGrey,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldRow(String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
