import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'welcome_screen.dart';
import 'signup_screen.dart';

/// The very first screen a new person sees — before sign in, sign up, or
/// guest mode. This is what makes SkyBook feel like an app with its own
/// identity rather than dropping straight into a login form.
///
/// [WelcomeScreen] (in this same folder) is the actual sign-in *form* —
/// its name predates this screen. This one is the true landing/welcome
/// screen; it just hands off to that form when the person taps "Sign In".
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _authService = AuthService();
  bool _guestLoading = false;

  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    await _authService.continueAsGuest();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'assets/images/logo.png',
                height: 180,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 96),
              ),
              const SizedBox(height: 28),
              const Text(
                'Your next trip starts here',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Search, compare, and book flights to hundreds of destinations worldwide — all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WelcomeScreen())),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                  child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _guestLoading ? null : _continueAsGuest,
                child: _guestLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                      )
                    : const Text(
                        'Continue as Guest',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
