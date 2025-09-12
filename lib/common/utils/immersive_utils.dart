import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 沉浸式状态栏和导航栏工具类
/// 基于金标联盟和Android Edge-to-Edge方案
class ImmersiveUtils {
  
  /// 初始化沉浸式配置（应用启动时调用）
  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    
    // 启用Edge-to-Edge模式
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // 设置初始的系统UI样式
    await updateSystemUIOverlay();
  }
  
  /// 动态更新系统UI覆盖层样式
  static Future<void> updateSystemUIOverlay({
    Brightness? brightness,
    bool forceLight = false,
    bool forceDark = false,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    
    // 确定当前主题亮度
    Brightness currentBrightness = brightness ?? 
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    if (forceLight) currentBrightness = Brightness.light;
    if (forceDark) currentBrightness = Brightness.dark;
    
    final isDark = currentBrightness == Brightness.dark;
    
    await SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // 状态栏配置（金标联盟方案）
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      
      // 导航栏配置（Android Edge-to-Edge方案）
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      
      // 强制适配Edge-to-Edge，禁用对比度增强
      systemNavigationBarContrastEnforced: false,
    ));
  }
  
  /// 进入全屏模式（视频播放等场景）
  static Future<void> enterFullscreen() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    
    // 全屏时隐藏所有系统UI
    await SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }
  
  /// 退出全屏模式
  static Future<void> exitFullscreen() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    
    // 恢复Edge-to-Edge模式
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    
    // 恢复沉浸式状态栏和导航栏
    await updateSystemUIOverlay();
  }
  
  /// 设置浅色主题的系统UI
  static Future<void> setLightSystemUI() async {
    await updateSystemUIOverlay(forceLight: true);
  }
  
  /// 设置深色主题的系统UI
  static Future<void> setDarkSystemUI() async {
    await updateSystemUIOverlay(forceDark: true);
  }
  
  /// 根据主题自动调整系统UI
  static Future<void> setAutoSystemUI(ThemeMode themeMode) async {
    switch (themeMode) {
      case ThemeMode.light:
        await setLightSystemUI();
        break;
      case ThemeMode.dark:
        await setDarkSystemUI();
        break;
      case ThemeMode.system:
      default:
        await updateSystemUIOverlay();
        break;
    }
  }
}