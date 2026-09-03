import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
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
            child: _tab == 0 ? _upcomingCard() : _pastEmpty(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
          child: Text(label,
              style: TextStyle(color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _upcomingCard() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: Color(0xFFB01F24), shape: BoxShape.circle),
                    child: const Icon(Icons.flight, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text('American Airlines', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Text('AA 100', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Upcoming', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('08:30', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('JFK', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      Text('15 Jun, 2023', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('7h 45m', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        Icon(Icons.flight, color: AppColors.textGrey, size: 16),
                        Text('Non-stop', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('20:15', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('LHR', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      Text('15 Jun, 2023', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _kv('Booking Ref', 'ABC12345'),
                  _kv('Seat', '5D'),
                  _kv('Status', 'Confirmed', color: AppColors.success),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () {}, child: const Text('View Details >')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(v, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color ?? AppColors.textDark)),
      ],
    );
  }

  Widget _pastEmpty() {
    return const Center(
      child: Text('No past bookings yet', style: TextStyle(color: AppColors.textGrey)),
    );
  }
}
