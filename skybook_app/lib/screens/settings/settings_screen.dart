import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _tile(Icons.person_outline, 'Account Settings'),
          _tile(Icons.notifications_outlined, 'Notifications'),
          _tile(Icons.attach_money, 'Currency', trailingText: 'USD (\$)'),
          _tile(Icons.language_outlined, 'Language', trailingText: 'English'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: AppColors.textDark),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: darkMode,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => darkMode = v),
            ),
          ),
          const Divider(height: 1),
          _tile(Icons.help_outline, 'Help & Support'),
          _tile(Icons.privacy_tip_outlined, 'Privacy Policy'),
          _tile(Icons.description_outlined, 'Terms & Conditions'),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, {String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark),
      title: Text(label),
      trailing: trailingText != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailingText, style: const TextStyle(color: AppColors.textGrey)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.textGrey),
              ],
            )
          : const Icon(Icons.chevron_right, color: AppColors.textGrey),
      onTap: () {},
    );
  }
}
