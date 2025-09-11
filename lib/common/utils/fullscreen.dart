import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:bili_you/common/utils/system_ui_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

//进入全屏显示
Future<void> enterFullScreen() async {
  await SystemUIUtil.setFullScreenSystemUI();
}

//退出全屏显示
Future<void> exitFullScreen() async {
  await SystemUIUtil.restoreNormalSystemUI();
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
