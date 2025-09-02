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

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp();

  // 开启 App Check
  await FirebaseAppCheck.instance.activate();

  // 捕获 Flutter 未捕获异常到 Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await BiliYouStorage.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const MyApp());

  // 状态栏、导航栏沉浸
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    super.initState();
    _initFirebaseFeatures();
  }

  Future<void> _initFirebaseFeatures() async {
    // 初始化 Remote Config
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();

    // 打印一个远程配置的值（比如欢迎语）
    final welcome = _remoteConfig.getString('welcome_message');
    debugPrint("🎉 Remote Config welcome_message: $welcome");

    // 发送一个 Analytics 事件
    await _analytics.logEvent(
      name: 'app_start',
      parameters: {'time': DateTime.now().toIso8601String()},
    );
    debugPrint("📊 Analytics event [app_start] sent");
  }

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
