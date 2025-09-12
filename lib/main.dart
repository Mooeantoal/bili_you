import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/bili_video/index.dart';
import 'package:bili_you/pages/main/index.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BiliYouStorage.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // 初始化系统UI沉浸式设置 - 基于Android官方Edge-to-Edge指南
  _initializeSystemUI();
  
  runApp(const MyApp());
}

/// 初始化系统UI设置 - 遵循Android官方Edge-to-Edge最佳实践
void _initializeSystemUI() {
  // 启用Edge-to-Edge显示模式
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 设置首选屏幕方向
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // 配置系统UI样式 - 符合金标联盟和Android官方标准
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // 透明系统UI背景
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    
    // 优化状态栏内容可见性
    statusBarIconBrightness: Brightness.dark, // 默认深色图标适配浅色主题
    statusBarBrightness: Brightness.light, // iOS兼容性
    
    // 优化导航栏内容可见性
    systemNavigationBarIconBrightness: Brightness.dark,
    
    // 启用导航栏对比度增强（Android 10+）
    systemNavigationBarContrastEnforced: true,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
      return GetMaterialApp(
          onInit: () async {
            await HttpUtils().init();
          },
          navigatorObservers: [BiliVideoPage.routeObserver],
          useInheritedMediaQuery: true,
          themeMode: SettingsUtil.currentThemeMode,
          theme: ThemeData(
              colorScheme: SettingsUtil.currentTheme == BiliTheme.dynamic
                  ? lightDynamic ?? BiliTheme.dynamic.themeDataLight.colorScheme
                  : SettingsUtil.currentTheme.themeDataLight.colorScheme,
              useMaterial3: true),
          darkTheme: ThemeData(
              colorScheme: SettingsUtil.currentTheme == BiliTheme.dynamic
                  ? darkDynamic ?? BiliTheme.dynamic.themeDataDark.colorScheme
                  : SettingsUtil.currentTheme.themeDataDark.colorScheme,
              useMaterial3: true),
          home: const MainPage(),
          builder: (context, child) => child == null
              ? const SizedBox()
              : MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor *
                          SettingsUtil.getValue(
                              SettingsStorageKeys.textScaleFactor,
                              defaultValue: 1.0)),
                  child: child));
    }));
  }
}
