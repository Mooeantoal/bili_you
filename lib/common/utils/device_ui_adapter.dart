import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加这个导入

class DeviceUIAdapter {
  static bool _isOppoDevice = false;
  static bool _isInitialized = false;

  /// 初始化设备信息
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final brand = androidInfo.brand.toLowerCase();
        
        // 检查是否为OPPO设备
        _isOppoDevice = brand.contains('oppo');
      }
    } catch (e) {
      // 如果获取设备信息失败，不影响正常使用
      print('获取设备信息失败: $e');
    }
    
    _isInitialized = true;
  }

  /// 是否为OPPO设备
  static bool isOppoDevice() => _isOppoDevice;

  /// 获取底部安全区域填充
  static EdgeInsets getBottomSafeAreaPadding(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // OPPO设备可能需要额外的底部填充
    if (_isOppoDevice) {
      return EdgeInsets.only(bottom: bottomPadding + 2.0);
    }
    
    return EdgeInsets.only(bottom: bottomPadding);
  }

  /// 获取适用于OPPO设备的导航栏样式
  static SystemUiOverlayStyle getOppoNavigationBarStyle() {
    if (_isOppoDevice) {
      // OPPO设备可能需要特定的导航栏样式
      return const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      );
    }
    
    // 默认样式
    return const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    );
  }
}