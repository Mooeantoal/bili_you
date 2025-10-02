import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:flutter/material.dart';

/// 导航栏沉浸工具类 - 专门解决导航栏沉浸问题
class NavigationBarImmersive {
  /// 设置完全沉浸的导航栏
  static Future<void> enableFullImmersive() async {
    // 使用manual模式，不显示任何系统UI
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // 关键：空数组意味着不显示任何覆盖层
    );
    
    // 强制设置透明样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false, // 关闭对比度增强
    ));
  }
  
  /// 恢复到默认的沉浸状态
  static Future<void> restoreDefault() async {
    // 恢复到默认的manual模式（与应用初始化一致）
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // 保持沉浸状态
    );
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));
  }
}

//进入全屏显示 - 使用新的导航栏沉浸方案
Future<void> enterFullScreen() async {
  bool useSticky = SettingsUtil.getValue(
      SettingsStorageKeys.enhancedImmersiveMode, 
      defaultValue: false); // 默认不使用sticky模式
      
  if (useSticky) {
    // 使用传统的immersiveSticky模式
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else {
    // 使用新的导航栏沉浸方案
    await NavigationBarImmersive.enableFullImmersive();
  }
}

//退出全屏显示 - 恢复导航栏沉浸状态
Future<void> exitFullScreen() async {
  await NavigationBarImmersive.restoreDefault();
}

// 兼容性函数
Future<void> enterEnhancedImmersiveMode() async {
  await NavigationBarImmersive.enableFullImmersive();
}

// 兼容性类型定义
enum DisplayMode {
  standard,
  enhancedImmersive,
  fullImmersive,
}

class ITGSAComplianceHelper {
  static Future<bool> checkDisplayCompliance() async {
    return true; // 简化，默认支持
  }
  
  static Future<DisplayMode> getRecommendedDisplayMode() async {
    return DisplayMode.enhancedImmersive;
  }
}

/// 设置沉浸式系统UI样式 - 基于Android官方Edge-to-Edge指南
void setImmersiveSystemUIStyle() {
  // Android官方推荐的Edge-to-Edge系统UI样式
  // 参考：https://developer.android.com/develop/ui/views/layout/edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // 透明状态栏和导航栏背景 - 官方enableEdgeToEdge()的默认行为
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    
    // 状态栏内容可见性 - 根据官方文档自动适配主题
    statusBarIconBrightness: Brightness.dark, // 深色图标适配浅色背景
    statusBarBrightness: Brightness.light, // iOS兼容性
    
    // 导航栏内容可见性 - 确保按钮可见
    systemNavigationBarIconBrightness: Brightness.dark,
    
    // 启用导航栏对比度增强（Android 10+）- 官方推荐的可访问性特性
    systemNavigationBarContrastEnforced: true,
  ));
  
  // 注意：在实际应用中，还应该使用WindowInsetsCompat处理边距
  // 以避免内容与系统UI重叠，这在Flutter中通过SafeArea和MediaQuery.viewInsets处理
}

//横屏
Future<void> landScape() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await AutoOrientation.landscapeAutoMode(forceSensor: true);
  }
}

//竖屏
Future<void> portraitUp() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}