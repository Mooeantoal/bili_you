# 悬浮式底部导航栏实现说明

## 功能介绍

本文档介绍了如何在BiliYou项目中实现悬浮式底部导航栏。通过使用[floating_bottom_navigation_bar](https://pub.dev/packages/floating_bottom_navigation_bar)第三方包，我们能够轻松地将传统的底部导航栏替换为现代化的悬浮式设计。

## 实现原理

1. 使用[floating_bottom_navigation_bar](https://pub.dev/packages/floating_bottom_navigation_bar)包实现悬浮效果
2. 保持与原有导航栏相同的导航逻辑和页面切换功能
3. 适配不同主题和颜色方案
4. 支持圆角、阴影等视觉效果

## 技术细节

### 依赖包

在`pubspec.yaml`中添加了以下依赖：

```yaml
dependencies:
  floating_bottom_navigation_bar: ^1.5.0
```

### 核心组件

创建了`BiliYouFloatingBottomNavBar`组件来封装悬浮式底部导航栏：

- 文件路径：[lib/common/widget/floating_bottom_nav_bar.dart](file:///d:/Downloads/bili_you/lib/common/widget/floating_bottom_nav_bar.dart)
- 继承自`StatelessWidget`
- 使用`FloatingNavbar`作为基础组件

### 样式配置

悬浮式底部导航栏的主要样式配置包括：

1. **背景色**：使用主题色的半透明效果
2. **选中项背景色**：主色调的淡色效果
3. **选中项颜色**：主色调
4. **未选中项颜色**：表面颜色的淡色效果
5. **圆角**：16dp的圆角
6. **项目圆角**：8dp的圆角
7. **阴影**：10dp的阴影效果

### 集成到主页面

在[lib/pages/main/view.dart](file:///d:/Downloads/bili_you/lib/pages/main/view.dart)中集成了悬浮式底部导航栏：

1. 导入自定义组件：
   ```dart
   import 'package:bili_you/common/widget/floating_bottom_nav_bar.dart';
   ```

2. 替换原有的`BottomNavigationBar`：
   ```dart
   bottomNavigationBar: MediaQuery.of(context).size.width < 640
       ? Container(
           // 抬高导航栏，避免与系统导航条冲突
           padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
           child: BiliYouFloatingBottomNavBar(
             currentIndex: controller.selectedIndex.value,
             onTap: onDestinationSelected,
           ),
         )
       : null,
   ```

## 使用方法

1. 确保已安装依赖包：
   ```bash
   flutter pub get
   ```

2. 运行应用，当屏幕宽度小于640dp时，将自动显示悬浮式底部导航栏

3. 导航栏将悬浮在内容之上，具有以下特点：
   - 圆角设计
   - 半透明背景
   - 阴影效果
   - 选中项高亮显示

## 自定义配置

可以通过修改[BiliYouFloatingBottomNavBar](file:///d:/Downloads/bili_you/lib/common/widget/floating_bottom_nav_bar.dart#L5-L50)组件来自定义悬浮式底部导航栏的外观：

```dart
FloatingNavbar(
  items: [
    FloatingNavbarItem(icon: Icons.home_outlined, title: '首页'),
    FloatingNavbarItem(icon: Icons.star_border_outlined, title: '动态'),
    FloatingNavbarItem(icon: Icons.person_outline, title: '我的'),
    FloatingNavbarItem(icon: Icons.bug_report, title: '测试'),
  ],
  currentIndex: currentIndex,
  onTap: onTap,
  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
  selectedBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
  selectedItemColor: Theme.of(context).colorScheme.primary,
  unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  elevation: 10,
  borderRadius: 16,
  itemBorderRadius: 8,
)
```

## 注意事项

1. 悬浮式底部导航栏仅在移动端显示（屏幕宽度小于640dp）
2. 在桌面端仍然使用侧边栏导航
3. 保持了原有的导航逻辑和页面切换功能
4. 与系统的安全区域（如刘海屏底部）兼容

## 参考资料

- [floating_bottom_navigation_bar package](https://pub.dev/packages/floating_bottom_navigation_bar)
- [Flutter Bottom Navigation Bar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)