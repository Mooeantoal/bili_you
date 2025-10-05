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
// 添加 Fluent UI 导入
import 'package:fluent_ui/fluent_ui.dart' as fluent;
// 添加 Cupertino 导入 (注意：项目中其他文件已导入cupertino，这里使用别名避免冲突)
import 'package:flutter/cupertino.dart' as cupertino;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BiliYouStorage.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
  //状态栏、导航栏沉浸
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
      // 检查是否启用 Cupertino 主题
      if (SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false)) {
        // 使用 Cupertino UI
        return const cupertino.CupertinoApp(
          theme: cupertino.CupertinoThemeData(),
          home: MainPage(),
        );
      }
      // 检查是否启用 Fluent UI 主题
      else if (SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false)) {
        // 使用 Fluent UI
        return fluent.FluentApp(
          theme: fluent.FluentThemeData(
            accentColor: fluent.Colors.blue,
          ),
          darkTheme: fluent.FluentThemeData(
            accentColor: fluent.Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: SettingsUtil.currentThemeMode,
          home: const MainPage(),
        );
      } else {
        // 使用默认的 Material UI
        return GetMaterialApp(
            onInit: () async {
              await HttpUtils().init();
            },
            navigatorObservers: [BiliVideoPage.routeObserver],
            useInheritedMediaQuery: true,
            themeMode: SettingsUtil.currentThemeMode,
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0078d4)),
                useMaterial3: true), // 使用MD3风格并应用FluentUI蓝色
            darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0078d4), brightness: Brightness.dark),
                useMaterial3: true), // 使用MD3风格并应用FluentUI蓝色
            home: const MainPage(),
            builder: (context, child) => child == null
                ? const SizedBox()
                : MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor *
                            SettingsUtil.getValue(
                                SettingsStorageKeys.textScaleFactor,
                                defaultValue: 1.0))),
                    child: child));
      }
    }));
  }
}