import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const _faqs = [
    {'q': 'How do I change my booking?', 'a': 'Go to My Bookings, select your trip, and tap Modify Booking to change your dates or seat.'},
    {'q': 'What is your baggage policy?', 'a': 'Economy passengers get one 23kg checked bag and one carry-on, free of charge.'},
    {'q': 'How can I check-in online?', 'a': 'Online check-in opens 24 hours before departure from the My Bookings screen.'},
    {'q': 'What payment methods do you accept?', 'a': 'We accept major credit/debit cards, PayPal, Apple Pay, Google Pay, and Klarna.'},
    {'q': 'How do I request a refund?', 'a': 'Refund requests can be submitted from Booking Details under Refunds & Cancellations.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ..._faqs.map((f) => Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(f['a']!, style: const TextStyle(color: AppColors.textGrey)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
