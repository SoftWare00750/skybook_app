import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/bottom_nav.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  _tabBtn('Upcoming', 0),
                  _tabBtn('Past', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: _tab == 0
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF3B4A63), Color(0xFF1A2436)]),
                              ),
                              child: const Stack(
                                children: [
                                  Center(child: Icon(Icons.location_city, color: Colors.white38, size: 56)),
                                  Positioned(
                                    left: 16,
                                    bottom: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('London Trip', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text('15 Jun - 22 Jun, 2023', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 28, height: 28,
                                        decoration: const BoxDecoration(color: Color(0xFFB01F24), shape: BoxShape.circle),
                                        child: const Icon(Icons.flight, color: Colors.white, size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('American Airlines', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      const Text('AA 100', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('08:30', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('JFK', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(children: [
                                          Text('7h 45m', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                          Icon(Icons.flight, size: 14, color: AppColors.textGrey),
                                        ]),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('20:15', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('LHR', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('15 Jun, 2023', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                  const SizedBox(height: 12),
                                  SizedBox(width: double.infinity, child: PrimaryButton(label: 'View Trip Details', onPressed: () {})),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(child: Text('No past trips yet', style: TextStyle(color: AppColors.textGrey))),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _tabBtn(String label, int i) {
    final selected = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
