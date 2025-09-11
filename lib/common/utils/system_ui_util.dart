import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 系统UI工具类 - 统一管理沉浸式状态栏和导航栏
class SystemUIUtil {
  /// 设置沉浸式系统UI（适用于普通页面）
  static Future<void> setImmersiveSystemUI({
    bool isDarkMode = false,
  }) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // 状态栏配置
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      
      // 导航栏配置
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      
      // 禁用系统强制对比度
      systemNavigationBarContrastEnforced: false,
    ));
  }

  /// 设置视频播放时的系统UI（全沉浸）
  static Future<void> setVideoPlayerSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  /// 设置全屏模式的系统UI
  static Future<void> setFullScreenSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  /// 恢复普通模式的系统UI
  static Future<void> restoreNormalSystemUI({bool isDarkMode = false}) async {
    late SystemUiMode mode;
    if (Platform.isAndroid) {
      mode = SystemUiMode.edgeToEdge;
    } else {
      mode = SystemUiMode.manual;
    }
    
    await SystemChrome.setEnabledSystemUIMode(mode,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    
    await setImmersiveSystemUI(isDarkMode: isDarkMode);
  }

  /// 根据主题动态获取SystemUiOverlayStyle
  static SystemUiOverlayStyle getSystemUiOverlayStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    );
  }
}