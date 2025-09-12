import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:bili_you/common/utils/settings.dart';

/// 显示模式枚举 - 结合金标联盟标准和Android官方方案
enum DisplayMode {
  /// 标准模式 - 符合金标联盟基础要求
  standard,
  /// 增强沉浸式 - Android官方Edge-to-Edge + 金标联盟用户体验优化
  enhancedImmersive,
  /// 完全沉浸式 - 传统全屏模式
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

//进入全屏显示 - 结合两种方案的增强版本
Future<void> enterFullScreen() async {
  DisplayMode mode = await ITGSAComplianceHelper.getRecommendedDisplayMode();
  
  switch (mode) {
    case DisplayMode.enhancedImmersive:
      // 金标联盟 + Android官方Edge-to-Edge结合方案
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      break;
    case DisplayMode.fullImmersive:
      // 传统沉浸式模式
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      break;
    case DisplayMode.standard:
    default:
      // 标准模式，符合金标联盟基础要求
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
      break;
  }
}

//退出全屏显示 - 智能恢复模式
Future<void> exitFullScreen() async {
  late SystemUiMode mode;
  bool adaptiveEdge = SettingsUtil.getValue(
      SettingsStorageKeys.adaptiveEdgeToEdge, 
      defaultValue: true);
      
  if ((Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 29) ||
      !Platform.isAndroid) {
    // Android 10+ 或非Android平台：使用Edge-to-Edge模式（符合金标联盟现代化要求）
    mode = adaptiveEdge ? SystemUiMode.edgeToEdge : SystemUiMode.manual;
  } else {
    // 旧版Android：使用传统模式
    mode = SystemUiMode.manual;
  }
  
  await SystemChrome.setEnabledSystemUIMode(mode,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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
