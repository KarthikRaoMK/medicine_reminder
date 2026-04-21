// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medicine_reminder/main.dart';
import 'package:medicine_reminder/providers/settings_provider.dart';
import 'package:medicine_reminder/providers/profile_provider.dart';

void main() {
  testWidgets('Medicine Reminder app smoke test', (WidgetTester tester) async {
    // Create providers
    final settingsProvider = SettingsProvider();
    final profileProvider = ProfileProvider();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      settingsProvider: settingsProvider,
      profileProvider: profileProvider,
    ));

    // Verify that the app starts up without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
