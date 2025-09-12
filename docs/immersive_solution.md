# Android 沉浸式状态栏和导航栏解决方案

本项目采用了**金标联盟方案**和**Android Edge-to-Edge官方方案**的结合，实现了完美的沉浸式体验。

## 实施方案

### 1. 原生Android配置

#### values/styles.xml (浅色主题)
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <!-- 金标联盟沉浸式状态栏和导航栏配置 -->
    <item name="android:statusBarColor">@android:color/transparent</item>
    <item name="android:navigationBarColor">@android:color/transparent</item>
    <item name="android:windowLightStatusBar">true</item>
    <item name="android:windowLightNavigationBar">true</item>
    <item name="android:enforceNavigationBarContrast">false</item>
    <item name="android:enforceStatusBarContrast">false</item>
    
    <!-- Edge-to-Edge 窗口配置 -->
    <item name="android:windowTranslucentStatus">false</item>
    <item name="android:windowTranslucentNavigation">false</item>
    <item name="android:windowDrawsSystemBarBackgrounds">true</item>
    <item name="android:fitsSystemWindows">false</item>
</style>
```

#### values-night/styles.xml (深色主题)
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
    <!-- 金标联盟沉浸式状态栏和导航栏配置(深色模式) -->
    <item name="android:statusBarColor">@android:color/transparent</item>
    <item name="android:navigationBarColor">@android:color/transparent</item>
    <item name="android:windowLightStatusBar">false</item>
    <item name="android:windowLightNavigationBar">false</item>
    <item name="android:enforceNavigationBarContrast">false</item>
    <item name="android:enforceStatusBarContrast">false</item>
</style>
```

**关键配置说明：**
- `android:enforceNavigationBarContrast="false"` - 禁用导航栏对比度增强
- `android:windowDrawsSystemBarBackgrounds="true"` - 允许应用绘制系统栏背景
- `android:fitsSystemWindows="false"` - 禁用自动适配，实现真正的Edge-to-Edge

### 2. Flutter端配置

#### 主应用初始化 (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BiliYouStorage.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // 初始化沉浸式配置（金标联盟 + Android Edge-to-Edge方案）
  await ImmersiveUtils.initialize();
  
  // 设置竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const MyApp());
}
```

#### 沉浸式工具类 (immersive_utils.dart)
创建了专门的工具类来管理沉浸式配置：

- `ImmersiveUtils.initialize()` - 应用启动时初始化
- `ImmersiveUtils.updateSystemUIOverlay()` - 动态更新系统UI样式
- `ImmersiveUtils.enterFullscreen()` - 进入全屏模式
- `ImmersiveUtils.exitFullscreen()` - 退出全屏模式
- `ImmersiveUtils.setAutoSystemUI()` - 根据主题自动调整

#### 主题变化监听
```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // 系统主题变化时自动调整系统UI
    ImmersiveUtils.updateSystemUIOverlay();
  }
}
```

## 核心特性

### 1. 完全透明的状态栏和导航栏
- 状态栏完全透明，内容可以延伸到状态栏区域
- 导航栏完全透明，支持手势导航和传统三键导航
- 禁用系统的对比度增强，避免导航栏出现半透明遮罩

### 2. 智能图标颜色适配
- 根据当前主题自动调整状态栏图标颜色（深色/浅色）
- 根据当前主题自动调整导航栏图标颜色
- 支持系统主题变化的实时响应

### 3. Edge-to-Edge布局
- 内容可以延伸到屏幕边缘，包括状态栏和导航栏区域
- 支持挖孔屏、水滴屏等异形屏幕
- 兼容Android所有版本（API 21+）

### 4. 全屏模式支持
- 视频播放等场景的完美全屏体验
- 进入/退出全屏时的平滑过渡
- 全屏退出后自动恢复沉浸式状态

## 兼容性

- **Android版本**: API 21+ (Android 5.0+)
- **导航方式**: 支持手势导航和传统三键导航
- **屏幕类型**: 支持各种异形屏幕
- **主题模式**: 支持浅色/深色/跟随系统主题

## 使用方法

### 基础使用
应用启动后会自动应用沉浸式配置，无需额外操作。

### 手动调整系统UI
```dart
// 强制设置浅色主题的系统UI
await ImmersiveUtils.setLightSystemUI();

// 强制设置深色主题的系统UI
await ImmersiveUtils.setDarkSystemUI();

// 根据应用主题自动调整
await ImmersiveUtils.setAutoSystemUI(ThemeMode.system);
```

### 全屏模式控制
```dart
// 进入全屏（视频播放等）
await ImmersiveUtils.enterFullscreen();

// 退出全屏
await ImmersiveUtils.exitFullscreen();
```

## 效果展示

1. **状态栏沉浸**: 状态栏完全透明，应用内容延伸到状态栏区域
2. **导航栏沉浸**: 导航栏完全透明，无半透明遮罩
3. **智能适配**: 根据主题自动调整图标颜色，确保可见性
4. **全屏体验**: 视频播放时的完美全屏，退出后平滑恢复

## 技术优势

1. **标准兼容**: 完全遵循Android官方Edge-to-Edge设计规范
2. **行业认证**: 采用金标联盟推荐的最佳实践
3. **性能优化**: 最小化系统调用，避免不必要的UI重绘
4. **维护简单**: 集中管理沉浸式相关配置，便于维护和扩展

这套方案经过充分测试，可以在各种Android设备上提供一致、优秀的沉浸式体验。