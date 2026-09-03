import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../auth/welcome_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _items = [
    {'icon': Icons.person_outline, 'label': 'Personal Information'},
    {'icon': Icons.payment_outlined, 'label': 'Payment Methods'},
    {'icon': Icons.description_outlined, 'label': 'Travel Documents'},
    {'icon': Icons.tune, 'label': 'My Preferences'},
    {'icon': Icons.person_add_alt_outlined, 'label': 'Invite Friends'},
    {'icon': Icons.logout, 'label': 'Logout'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 44),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('John Doe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('john.doe@email.com', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (context, i) {
                final item = _items[i];
                final isLogout = item['label'] == 'Logout';
                return ListTile(
                  leading: Icon(item['icon'] as IconData, color: isLogout ? AppColors.primary : AppColors.textDark),
                  title: Text(item['label'] as String,
                      style: TextStyle(color: isLogout ? AppColors.primary : AppColors.textDark, fontWeight: FontWeight.w500)),
                  trailing: isLogout ? null : const Icon(Icons.chevron_right, color: AppColors.textGrey),
                  onTap: () {
                    if (isLogout) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
