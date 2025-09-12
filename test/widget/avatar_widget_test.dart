import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bili_you/common/widget/avatar.dart';

void main() {
  group('AvatarWidget Tests', () {
    testWidgets('should display default avatar when no URL provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              avatarUrl: '',
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should display cached network image when URL provided', (WidgetTester tester) async {
      const testUrl = 'https://example.com/avatar.jpg';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              avatarUrl: testUrl,
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      // CachedNetworkImage should be used for valid URLs
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('should respect radius parameter', (WidgetTester tester) async {
      const testRadius = 30.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              avatarUrl: '',
              radius: testRadius,
            ),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, equals(testRadius));
    });

    testWidgets('should handle null URL gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              avatarUrl: null,
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}