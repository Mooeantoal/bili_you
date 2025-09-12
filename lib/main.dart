import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:bili_you/common/utils/immersive_utils.dart';
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
  
  // 初始化沉浸式配置（金标联盟 + Android Edge-to-Edge方案）
  await ImmersiveUtils.initialize();
  
  // 设置竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const MyApp());
}

// 动态更新系统UI覆盖层样式（保持向后兼容）
void _updateSystemUIOverlay() {
  ImmersiveUtils.updateSystemUIOverlay();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // 系统主题变化时自动调整系统UI
    ImmersiveUtils.updateSystemUIOverlay();
  }
  
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
      return GetMaterialApp(
          onInit: () async {
            await HttpUtils().init();
            // 初始化后调整系统UI
            await ImmersiveUtils.setAutoSystemUI(SettingsUtil.currentThemeMode);
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
