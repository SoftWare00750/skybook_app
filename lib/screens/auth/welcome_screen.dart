import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _guestLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please enter your email/phone and password.');
      return;
    }
    setState(() => _loading = true);
    final result = await _authService.login(
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      _showMessage(result.errorMessage ?? 'Sign in failed.');
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    await _authService.continueAsGuest();
    if (!mounted) return;
    setState(() => _guestLoading = false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 64,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 24),
                      const Text('Welcome Back',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Sign in to continue your journey',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        hint: 'Email or Phone number',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscurable: true,
                        controller: _passwordController,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?', style: TextStyle(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Sign In',
                        loading: _loading,
                        onPressed: _signIn,
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or continue with', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SocialButton(asset: 'G', icon: Icons.g_mobiledata, onPressed: () {}),
                          const SizedBox(width: 16),
                          SocialButton(asset: 'A', icon: Icons.apple, onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SecondaryButton(
                        label: _guestLoading ? 'Continuing…' : 'Continue as Guest',
                        icon: Icons.explore_outlined,
                        onPressed: _guestLoading ? null : _continueAsGuest,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: AppColors.textGrey)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                            child: const Text('Sign up',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
