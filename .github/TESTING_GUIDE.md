# bili_you 项目测试指南

## 🧪 测试框架概述

本项目使用 Flutter 的官方测试框架，包含以下类型的测试：

### 测试类型

1. **单元测试 (Unit Tests)** - 测试独立的函数和类
2. **Widget 测试 (Widget Tests)** - 测试单个 Widget 的行为
3. **集成测试 (Integration Tests)** - 测试完整的应用流程

## 📁 测试目录结构

```
test/
├── unit/                     # 单元测试
│   ├── string_format_utils_test.dart
│   ├── bvid_avid_util_test.dart
│   ├── settings_test.dart
│   └── http_utils_test.dart
├── widget/                   # Widget 测试
│   └── avatar_widget_test.dart
├── integration/              # 集成测试
│   └── app_integration_test.dart
├── test_helper.dart          # 测试辅助工具
├── dart_test.yaml           # 测试配置
└── widget_test.dart         # 主 Widget 测试
```

## 🚀 运行测试

### 方法一：使用脚本 (推荐)

Windows:
```cmd
scripts\run_tests.bat
```

Linux/macOS:
```bash
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

### 方法二：使用 Flutter 命令

```bash
# 运行所有测试
flutter test

# 运行特定目录的测试
flutter test test/unit/
flutter test test/widget/

# 运行特定测试文件
flutter test test/unit/string_format_utils_test.dart

# 运行测试并生成覆盖率报告
flutter test --coverage

# 运行测试并生成报告
flutter test --reporter json > test/reports/test-results.json
```

## 📊 测试覆盖的功能模块

### ✅ 已测试模块

#### 工具类 (Utils)
- **StringFormatUtils** - 数字和时间格式化
  - 数字格式化 (1000 → 1.0k, 10000 → 1.0万)
  - 时间长度格式化 (3661 → 1:01:01)
  - 边界条件处理

- **BvidAvidUtil** - BV号和AV号转换
  - AV号转BV号
  - BV号转AV号
  - BV号格式验证
  - 往返转换一致性

- **SettingsUtil** - 应用设置管理
  - 基本设置存储和读取
  - 默认值处理
  - 主题设置
  - 文本缩放设置

- **HttpUtils** - 网络请求工具 (Mock 测试)
  - GET 请求测试
  - 错误处理测试
  - 请求头验证
  - 重试机制测试

#### UI 组件 (Widgets)
- **AvatarWidget** - 头像组件
  - 默认头像显示
  - 网络图片加载
  - 尺寸参数处理
  - 异常处理

#### 应用级别
- **App Widget** - 主应用组件
  - 应用启动测试
  - 初始化验证
  - 崩溃检测

### 🔄 集成测试

- 应用启动流程
- 导航功能
- 网络请求处理
- 设置页面访问

## 🛠️ 测试工具和辅助函数

### TestHelper 类

提供常用的测试辅助方法：

```dart
// 包装 Widget 为可测试的 MaterialApp
TestHelper.wrapWithMaterialApp(widget)

// 等待异步操作完成
await TestHelper.waitForAsync(tester)

// 模拟网络延迟
await TestHelper.simulateNetworkDelay()

// 验证 Widget 可见性
TestHelper.expectWidgetVisible(finder)
```

### 自定义匹配器

```dart
// 验证样式
expect(widget, CustomMatchers.hasStyle(expectedStyle))

// 验证数值范围
expect(value, CustomMatchers.inRange(0, 100))

// 验证 URL 格式
expect(url, CustomMatchers.isValidUrl())

// 验证 BVID 格式
expect(bvid, CustomMatchers.isValidBvid())
```

### 测试数据生成器

```dart
// 生成测试数据
final bvid = TestDataGenerator.generateBvid()
final videoData = TestDataGenerator.generateVideoData()
final commentData = TestDataGenerator.generateCommentData()
```

## 📋 测试最佳实践

### 1. 测试命名规范

```dart
group('ClassName Tests', () {
  group('methodName', () {
    test('should do something when condition', () {
      // 测试实现
    });
  });
});
```

### 2. 使用 AAA 模式

```dart
test('should format number correctly', () {
  // Arrange (准备)
  final input = 1500;
  final expected = '1.5k';
  
  // Act (执行)
  final result = StringFormatUtils.numFormat(input);
  
  // Assert (断言)
  expect(result, equals(expected));
});
```

### 3. Mock 网络请求

```dart
// 使用 Mockito 创建 Mock 对象
@GenerateMocks([Dio])
import 'test_file.mocks.dart';

final mockDio = MockDio();
when(mockDio.get(any)).thenAnswer((_) async => mockResponse);
```

### 4. Widget 测试模式

```dart
testWidgets('widget description', (WidgetTester tester) async {
  // 构建 Widget
  await tester.pumpWidget(TestHelper.wrapWithMaterialApp(widget));
  
  // 执行操作
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();
  
  // 验证结果
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## 🎯 测试目标

### 当前覆盖率目标
- **单元测试**: 核心工具类 80%+ 覆盖率
- **Widget 测试**: 通用组件 70%+ 覆盖率
- **集成测试**: 主要用户流程覆盖

### 待添加测试

#### 高优先级
- [ ] API 接口测试 (VideoApi, CommentApi 等)
- [ ] 页面控制器测试 (GetX Controllers)
- [ ] 数据模型测试 (Models)
- [ ] 缓存工具测试 (CacheUtil)

#### 中优先级
- [ ] 视频播放器组件测试
- [ ] 评论组件测试
- [ ] 搜索功能测试
- [ ] 主题切换测试

#### 低优先级
- [ ] 动画组件测试
- [ ] 性能测试
- [ ] 可访问性测试

## 🔧 测试配置

### dart_test.yaml 配置

```yaml
timeout: 30s
platforms: [vm, chrome]
concurrency: 4
verbose_trace: true
```

### pubspec.yaml 测试依赖

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.1
  mockito: ^5.4.2
  fake_async: ^1.3.1
```

## 🚨 故障排除

### 常见问题

1. **测试超时**
   ```bash
   # 增加超时时间
   flutter test --timeout=60s
   ```

2. **Widget 测试失败**
   ```dart
   // 确保使用 pumpAndSettle 等待动画完成
   await tester.pumpAndSettle();
   ```

3. **Mock 不工作**
   ```bash
   # 重新生成 Mock 文件
   flutter packages pub run build_runner build
   ```

4. **覆盖率报告为空**
   ```bash
   # 确保测试文件在正确目录
   flutter test --coverage test/
   ```

## 📈 持续改进

### 定期任务
- [ ] 每周检查测试覆盖率
- [ ] 每月更新测试依赖
- [ ] 每季度评估测试策略

### 最佳实践检查清单
- [ ] 新功能必须包含测试
- [ ] 测试必须快速运行 (<30s)
- [ ] 测试必须可重复执行
- [ ] 测试必须独立运行
- [ ] 测试必须有清晰的描述

---

✅ **完整的测试框架已配置完成，可以开始测试驱动开发！**