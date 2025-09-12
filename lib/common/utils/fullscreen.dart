import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:flutter/material.dart';

/// 显示模式枚举 - 结合金标联盟标准和Android官方方案
enum DisplayMode {
  /// 标准模式 - 符合金标联盟基础要求，保持系统UI可见
  standard,
  /// 增强沉浸式 - Android官方Edge-to-Edge + 金标联盟用户体验优化
  enhancedImmersive,
  /// 完全沉浸式 - 传统全屏模式，完全隐藏系统UI
  fullImmersive,
}

/// 金标联盟（ITGSA）合规检查和优化
class ITGSAComplianceHelper {
  /// 检查设备是否符合金标联盟显示标准
  static Future<bool> checkDisplayCompliance() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // 金标联盟要求Android 5.0+支持现代显示模式
      if (androidInfo.version.sdkInt >= 21) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取推荐的显示模式（基于设备能力和用户设置）
  static Future<DisplayMode> getRecommendedDisplayMode() async {
    bool itgsaEnabled = SettingsUtil.getValue(
        SettingsStorageKeys.enableITGSACompliance, 
        defaultValue: true);
    bool enhancedMode = SettingsUtil.getValue(
        SettingsStorageKeys.enhancedImmersiveMode, 
        defaultValue: true);
    bool adaptiveEdge = SettingsUtil.getValue(
        SettingsStorageKeys.adaptiveEdgeToEdge, 
        defaultValue: true);
        
    if (!await checkDisplayCompliance()) {
      return DisplayMode.standard;
    }
    
    if (itgsaEnabled && enhancedMode && adaptiveEdge) {
      return DisplayMode.enhancedImmersive;
    } else if (enhancedMode) {
      return DisplayMode.fullImmersive;
    }
    
    return DisplayMode.standard;
  }
}

/// 设置沉浸式系统UI样式 - 基于Android官方Edge-to-Edge指南
void _setImmersiveSystemUIStyle() {
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

//进入全屏显示 - 结合两种方案的增强版本
Future<void> enterFullScreen() async {
  DisplayMode mode = await ITGSAComplianceHelper.getRecommendedDisplayMode();
  
  switch (mode) {
    case DisplayMode.enhancedImmersive:
      // 金标联盟 + Android官方Edge-to-Edge结合方案
      // 使用edgeToEdge模式，保持系统UI可见但内容延伸到边缘
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      _setImmersiveSystemUIStyle();
      break;
      
    case DisplayMode.fullImmersive:
      // 传统沉浸式模式 - 完全隐藏系统UI
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      break;
      
    case DisplayMode.standard:
    default:
      // 标准模式，符合金标联盟基础要求
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      break;
  }
}

//退出全屏显示 - 智能恢复到应用默认的沉浸式状态
Future<void> exitFullScreen() async {
  // 恢复到应用启动时设置的Edge-to-Edge模式
  // 这与main.dart中的初始化设置保持一致
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 恢复应用默认的系统UI样式
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
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
