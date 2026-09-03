import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _transactions = [
    {'label': 'Flight Booking', 'date': '15 Jun, 2023', 'amount': -740.00, 'icon': Icons.flight_takeoff},
    {'label': 'Money Added', 'date': '10 Jun, 2023', 'amount': 500.00, 'icon': Icons.add_circle_outline},
    {'label': 'Seat Selection', 'date': '15 Jun, 2023', 'amount': -20.00, 'icon': Icons.event_seat_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wallet Balance', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text('\$250.00', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, minimumSize: const Size(0, 40)),
                  onPressed: () {},
                  child: const Text('Add Money'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ..._transactions.map((t) {
            final amount = t['amount'] as double;
            final positive = amount > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Icon(t['icon'] as IconData, color: AppColors.textDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(t['date'] as String, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    '${positive ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: positive ? AppColors.success : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: TextButton(onPressed: () {}, child: const Text('View all transactions >')),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
