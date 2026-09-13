import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/profile.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/api_client.dart';
import '../auth/welcome_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();

  bool _loading = true;
  bool _isGuest = true;
  String? _fullName;
  String? _email;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final isGuest = await _authService.isGuest();
    final signedIn = await _authService.isSignedIn();
    final fullName = await _authService.cachedFullName();
    final email = await _authService.cachedEmail();
    if (!mounted) return;
    setState(() {
      _isGuest = isGuest;
      _fullName = fullName;
      _email = email;
      _loading = false;
    });

    if (signedIn) {
      try {
        final profile = await _profileService.getProfile();
        if (!mounted) return;
        setState(() => _profile = profile);
      } catch (_) {
        // Falls back to the cached name/email already shown — trip stats
        // just won't appear this time.
      }
    }
  }

  Future<void> _editProfile() async {
    final profile = _profile;
    if (profile == null) return;
    final nameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phone ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;
    try {
      final updated = await _profileService.updateProfile(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _fullName = updated.fullName;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
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
            padding: const EdgeInsets.only(bottom: 20),
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
                if (!_isGuest && _profile != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Row(
                      children: [
                        _statColumn('${_profile!.tripsCount}', 'Trips'),
                        _statDivider(),
                        _statColumn('${_profile!.upcomingCount}', 'Upcoming'),
                      ],
                    ),
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
                final isPersonalInfo = item['label'] == 'Personal Information';
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
                    } else if (isPersonalInfo && _profile != null) {
                      _editProfile();
                    } else if (isPersonalInfo && _isGuest) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Sign in to edit your personal information.')));
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

  Widget _statColumn(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 28, color: Colors.white24);
}
