import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/bookings/my_bookings_screen.dart';
import '../screens/trips/my_trips_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/profile/profile_screen.dart';

/// The 5-tab bottom navigation shown across the app's main sections:
/// Home, Bookings, Trips, Wallet, Profile.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  static const _labels = ['Home', 'Bookings', 'Trips', 'Wallet', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.confirmation_number_outlined,
    Icons.card_travel_rounded,
    Icons.account_balance_wallet_outlined,
    Icons.person_outline_rounded,
  ];

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    late Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const MyBookingsScreen();
        break;
      case 2:
        page = const MyTripsScreen();
        break;
      case 3:
        page = const WalletScreen();
        break;
      default:
        page = const ProfileScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_labels.length, (i) {
              final selected = i == currentIndex;
              final color = selected ? AppColors.primary : AppColors.textGrey;
              return Expanded(
                child: InkWell(
                  onTap: () => _navigate(context, i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[i], color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(_labels[i], style: TextStyle(color: color, fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
