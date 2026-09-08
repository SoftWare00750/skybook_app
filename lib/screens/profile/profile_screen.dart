import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/auth_service.dart';
import '../auth/welcome_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _loading = true;
  bool _isGuest = true;
  String? _fullName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final isGuest = await _authService.isGuest();
    final fullName = await _authService.cachedFullName();
    final email = await _authService.cachedEmail();
    if (!mounted) return;
    setState(() {
      _isGuest = isGuest;
      _fullName = fullName;
      _email = email;
      _loading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  List<Map<String, Object>> get _items => [
        {'icon': Icons.person_outline, 'label': 'Personal Information'},
        {'icon': Icons.payment_outlined, 'label': 'Payment Methods'},
        {'icon': Icons.description_outlined, 'label': 'Travel Documents'},
        {'icon': Icons.tune, 'label': 'My Preferences'},
        {'icon': Icons.person_add_alt_outlined, 'label': 'Invite Friends'},
        _isGuest
            ? {'icon': Icons.login, 'label': 'Sign In'}
            : {'icon': Icons.logout, 'label': 'Logout'},
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
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white24,
                      child: Icon(_isGuest ? Icons.person_outline : Icons.person, color: Colors.white, size: 44),
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
                if (_loading)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else ...[
                  Text(
                    _isGuest ? 'Guest' : (_fullName?.trim().isNotEmpty == true ? _fullName! : 'SkyBook User'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isGuest ? 'Sign in to unlock bookings, wallet & more' : (_email ?? ''),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
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
                final isSignIn = item['label'] == 'Sign In';
                final isAccentRow = isLogout || isSignIn;
                return ListTile(
                  leading: Icon(item['icon'] as IconData, color: isAccentRow ? AppColors.primary : AppColors.textDark),
                  title: Text(item['label'] as String,
                      style: TextStyle(color: isAccentRow ? AppColors.primary : AppColors.textDark, fontWeight: FontWeight.w500)),
                  trailing: isAccentRow ? null : const Icon(Icons.chevron_right, color: AppColors.textGrey),
                  onTap: () {
                    if (isLogout) {
                      _handleLogout();
                    } else if (isSignIn) {
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
