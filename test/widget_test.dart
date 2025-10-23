// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hakbang/screens/login_screen.dart';

// main.dart import removed for focused widget test

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Render the LoginScreen directly to avoid AuthenticationWrapper async checks
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
      ),
    );
    await tester.pump();

    // Verify the app title and Login button are present on LoginScreen.
    expect(find.text('Hakbang'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
