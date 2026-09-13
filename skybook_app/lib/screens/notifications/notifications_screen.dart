import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    {'icon': Icons.trending_down, 'color': Color(0xFF2F80ED), 'title': 'Price Drop Alert', 'body': 'The price for your flight to London has dropped.', 'time': '2m ago'},
    {'icon': Icons.check_circle, 'color': AppColors.success, 'title': 'Booking Confirmed', 'body': 'Your booking ABC12345 is confirmed.', 'time': '10m ago'},
    {'icon': Icons.access_time, 'color': AppColors.warning, 'title': 'Check-in Reminder', 'body': 'Check-in for your flight to London is open.', 'time': '1h ago'},
    {'icon': Icons.local_offer, 'color': AppColors.primary, 'title': 'Special Offer', 'body': 'Get 10% off on your next booking.', 'time': '1d ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: (item['color'] as Color).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(item['body'] as String, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
                ),
                Text(item['time'] as String, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}
