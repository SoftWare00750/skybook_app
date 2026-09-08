import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';

void main() {
  runApp(const SkyBookApp());
}

class SkyBookApp extends StatelessWidget {
  const SkyBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
