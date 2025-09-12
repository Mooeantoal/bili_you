import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bili_you/main.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App should build without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should initialize properly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      
      // Allow for async initialization
      await tester.pumpAndSettle();

      // The app should not crash during initialization
      expect(tester.takeException(), isNull);
    });
  });
}