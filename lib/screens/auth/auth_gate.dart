import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'welcome_screen.dart';

/// The app's actual start screen. Decides, once, whether there's a saved
/// session from a previous run — either a real signed-in user (a stored
/// JWT) or a guest session (see [AuthService.continueAsGuest]) — and skips
/// straight to [HomeScreen] if so. Otherwise it falls back to
/// [WelcomeScreen] so the person can sign in, sign up, or continue as a
/// guest.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasActiveSession() async {
    final authService = AuthService();
    if (await authService.isSignedIn()) return true;
    return authService.isGuest();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasActiveSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return (snapshot.data ?? false) ? const HomeScreen() : const WelcomeScreen();
      },
    );
  }
}
