import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/currency_service.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the person's last-picked display currency before the first
  // frame, so flight cards, fare summaries, and the wallet never flash
  // USD before switching to the saved currency.
  await CurrencyService.instance.load();
  runApp(const SkyBookApp());
}

/// Lets a screen (e.g. WalletScreen) refresh itself whenever the user
/// navigates back to it — used by the wallet so a top-up made a couple
/// of screens deep (pick a method -> maybe enter a new card) is reflected
/// the moment its "Add Money" flow finishes and pops back.
final routeObserver = RouteObserver<PageRoute>();

class SkyBookApp extends StatelessWidget {
  const SkyBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorObservers: [routeObserver],
      home: const AuthGate(),
    );
  }
}
