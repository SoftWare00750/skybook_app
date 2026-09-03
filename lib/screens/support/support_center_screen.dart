import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'help_faq_screen.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  static const _topics = [
    {'icon': Icons.book_outlined, 'label': 'Manage My Booking'},
    {'icon': Icons.how_to_reg_outlined, 'label': 'Check-in Information'},
    {'icon': Icons.luggage_outlined, 'label': 'Baggage Policy'},
    {'icon': Icons.replay_outlined, 'label': 'Refunds & Cancellations'},
    {'icon': Icons.payment_outlined, 'label': 'Payment & Receipts'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Center')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('How can we help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(hintText: 'Search for help topics', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 24),
          const Text('Popular Topics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ..._topics.map((t) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(t['icon'] as IconData, color: AppColors.textDark),
                title: Text(t['label'] as String),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqScreen())),
              )),
          const SizedBox(height: 16),
          const Text('Still need help?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Contact our support team.', style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Contact Support', icon: Icons.headset_mic_outlined, onPressed: () {}),
        ],
      ),
    );
  }
}
