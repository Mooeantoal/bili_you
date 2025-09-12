import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'immersive_utils.dart';

//进入全屏显示
Future<void> enterFullScreen() async {
  await ImmersiveUtils.enterFullscreen();
}

//退出全屏显示
Future<void> exitFullScreen() async {
  await ImmersiveUtils.exitFullscreen();
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
