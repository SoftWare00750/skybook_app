// Basic smoke tests for the SkyBook app.
//
// These verify the app boots to the right first screen depending on
// whether a session was saved from a previous run (see lib/screens/auth/
// auth_gate.dart), and that the "Continue as Guest" affordance exists on
// the Welcome screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skybook/main.dart';

void main() {
  testWidgets('Shows the Welcome screen (with a guest option) when there is no saved session',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SkyBookApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });

  testWidgets('Skips straight to Home when a guest session was saved', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'skybook_is_guest': true});

    await tester.pumpWidget(const SkyBookApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsNothing);
    expect(find.text('Where would you like to go?'), findsOneWidget);
  });

  testWidgets('Skips straight to Home when a signed-in session was saved', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'skybook_auth_token': 'test-token'});

    await tester.pumpWidget(const SkyBookApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsNothing);
    expect(find.text('Where would you like to go?'), findsOneWidget);
  });
}
