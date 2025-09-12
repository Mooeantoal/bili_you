import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 测试辅助工具类
class TestHelper {
  /// 创建一个包装了 MaterialApp 的测试 Widget
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// 创建一个带主题的测试 Widget
  static Widget wrapWithTheme(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// 等待异步操作完成
  static Future<void> waitForAsync(WidgetTester tester, {Duration? timeout}) async {
    await tester.pumpAndSettle(timeout ?? const Duration(seconds: 3));
  }

  /// 查找带文本的 Widget
  static Finder findByTextContaining(String text) {
    return find.byWidgetPredicate(
      (widget) => widget is Text && widget.data?.contains(text) == true,
    );
  }

  /// 模拟网络延迟
  static Future<void> simulateNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 100));
  }

  /// 验证 Widget 是否存在且可见
  static void expectWidgetVisible(Finder finder) {
    expect(finder, findsOneWidget);
    expect(finder.evaluate().first.renderObject?.attached, isTrue);
  }

  /// 验证 Widget 不存在
  static void expectWidgetNotFound(Finder finder) {
    expect(finder, findsNothing);
  }

  /// 模拟用户输入
  static Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// 滚动到指定 Widget
  static Future<void> scrollToWidget(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }
}

/// 自定义匹配器
class CustomMatchers {
  /// 验证 Widget 是否有特定的样式
  static Matcher hasStyle(TextStyle expectedStyle) {
    return predicate<Widget>((widget) {
      if (widget is Text) {
        final actualStyle = widget.style;
        return actualStyle?.fontSize == expectedStyle.fontSize &&
               actualStyle?.color == expectedStyle.color;
      }
      return false;
    }, 'Widget should have expected style');
  }

  /// 验证数字是否在指定范围内
  static Matcher inRange(num min, num max) {
    return predicate<num>((value) => value >= min && value <= max,
        'Value should be between $min and $max');
  }

  /// 验证字符串是否为有效的 URL
  static Matcher isValidUrl() {
    return predicate<String>((value) {
      try {
        final uri = Uri.parse(value);
        return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
      } catch (e) {
        return false;
      }
    }, 'String should be a valid URL');
  }

  /// 验证字符串是否为有效的 BVID
  static Matcher isValidBvid() {
    return predicate<String>((value) {
      return value.startsWith('BV') && value.length == 12;
    }, 'String should be a valid BVID');
  }
}

/// 测试数据生成器
class TestDataGenerator {
  /// 生成测试用的 BVID
  static String generateBvid() {
    return 'BV1xx411c7mD'; // 示例 BVID
  }

  /// 生成测试用的 AV 号
  static int generateAvid() {
    return 170001; // 示例 AV 号
  }

  /// 生成测试用的用户头像 URL
  static String generateAvatarUrl() {
    return 'https://example.com/avatar.jpg';
  }

  /// 生成测试用的视频数据
  static Map<String, dynamic> generateVideoData() {
    return {
      'bvid': generateBvid(),
      'aid': generateAvid(),
      'title': '测试视频标题',
      'pic': 'https://example.com/cover.jpg',
      'duration': 300,
      'view': 1000,
      'danmaku': 100,
      'owner': {
        'name': '测试UP主',
        'face': generateAvatarUrl(),
      },
    };
  }

  /// 生成测试用的评论数据
  static Map<String, dynamic> generateCommentData() {
    return {
      'rpid': 123456,
      'content': {
        'message': '这是一条测试评论',
      },
      'member': {
        'uname': '测试用户',
        'avatar': generateAvatarUrl(),
      },
      'like': 10,
      'ctime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
  }
}