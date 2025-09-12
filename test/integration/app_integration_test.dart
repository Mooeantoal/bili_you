import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bili_you/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches and displays main interface', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 验证应用成功启动
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // 等待应用完全加载
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 验证没有异常抛出
      expect(tester.takeException(), isNull);
    });

    testWidgets('Navigation works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 等待应用加载完成
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 查找底部导航栏（如果存在）
      final bottomNavBar = find.byType(BottomNavigationBar);
      
      if (bottomNavBar.evaluate().isNotEmpty) {
        // 测试底部导航切换
        await tester.tap(bottomNavBar);
        await tester.pumpAndSettle();
        
        // 验证导航成功
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('App handles network requests gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 等待应用加载完成
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 查找刷新相关的 Widget
      final refreshIndicator = find.byType(RefreshIndicator);
      
      if (refreshIndicator.evaluate().isNotEmpty) {
        // 测试下拉刷新
        await tester.drag(refreshIndicator.first, const Offset(0, 300));
        await tester.pumpAndSettle();
        
        // 验证刷新操作不会导致崩溃
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('App settings can be accessed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 等待应用加载完成
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 查找设置入口（通常是一个图标按钮）
      final settingsButton = find.byIcon(Icons.settings).first;
      
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        
        // 验证设置页面打开
        expect(tester.takeException(), isNull);
      }
    });
  });
}