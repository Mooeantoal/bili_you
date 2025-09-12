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

/// 初始化系统UI设置 - 专门针对导航栏沉浸优化
void _initializeSystemUI() {
  // 使用手动模式，不显示任何系统UI覆盖层
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [], // 关键：不显示任何覆盖层，实现真正的沉浸
  );
  
  // 设置首选屏幕方向
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // 强制设置完全透明的系统UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // 完全透明的背景
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    
    // 状态栏图标颜色
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light, // iOS兼容
    
    // 导航栏图标颜色
    systemNavigationBarIconBrightness: Brightness.dark,
    
    // 关闭导航栏对比度增强，避免系统强制显示背景
    systemNavigationBarContrastEnforced: false,
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
              useMaterial3: true,
              // MD2风格的BottomNavigationBar主题设置
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: null, // 使用主题色
                unselectedItemColor: null, // 使用默认色
                elevation: 8.0, // MD2风格的阴影
                showSelectedLabels: true,
                showUnselectedLabels: true,
              ),),
          darkTheme: ThemeData(
              colorScheme: SettingsUtil.currentTheme == BiliTheme.dynamic
                  ? darkDynamic ?? BiliTheme.dynamic.themeDataDark.colorScheme
                  : SettingsUtil.currentTheme.themeDataDark.colorScheme,
              useMaterial3: true,
              // MD2风格的BottomNavigationBar暗色主题设置
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: null, // 使用主题色
                unselectedItemColor: null, // 使用默认色
                elevation: 8.0, // MD2风格的阴影
                showSelectedLabels: true,
                showUnselectedLabels: true,
              ),),
          home: const MainPage(),
          builder: (context, child) => child == null
              ? const SizedBox()
              : MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    // 字体缩放 - 提高默认值以避免界面过于拥挤
                    textScaleFactor: MediaQuery.of(context).textScaleFactor *
                        SettingsUtil.getValue(
                            SettingsStorageKeys.textScaleFactor,
                            defaultValue: 1.0), // 改为1.0避免界面过小
                    // 视觉密度优化 - 增加界面元素间距
                    accessibleNavigation: false,
                    // 移除gestureSettings.copyWith调用，因为API不存在
                  ),
                  child: child));
    }));
  }
}
