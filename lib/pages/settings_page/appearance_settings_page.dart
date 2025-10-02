import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/common/widget/settings_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// 添加 Fluent UI 导入
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  // 检查当前是否使用 Cupertino UI
  bool get useCupertino => SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
  // 检查当前是否使用 Fluent UI
  bool get useFluent => SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);

  RadioListTile themeModeListTile(ThemeMode themeMode) {
    return RadioListTile<ThemeMode>(
      value: themeMode,
      groupValue: SettingsUtil.currentThemeMode,
      title: Text(themeMode.value),
      onChanged: (value) {
        SettingsUtil.changeThemeMode(value!);
        setState(() {});
        Navigator.pop(context);
      },
    );
  }

  List<RadioListTile> buildThemeModeList() {
    List<RadioListTile> list = [];
    for (var themeMode in ThemeMode.values) {
      list.add(themeModeListTile(themeMode));
    }
    return list;
  }

  RadioListTile themeListTile(BiliTheme theme) {
    return RadioListTile<BiliTheme>(
      value: theme,
      groupValue: SettingsUtil.currentTheme,
      title: Text(
        theme.value,
        style: TextStyle(
            color: theme == BiliTheme.dynamic ? null : theme.seedColor),
      ),
      onChanged: (value) {
        SettingsUtil.changeTheme(value!);
        setState(() {});
        Navigator.pop(context);
      },
    );
  }

  List<RadioListTile> buildThemeLists() {
    List<RadioListTile> list = [];
    for (var theme in BiliTheme.values) {
      list.add(themeListTile(theme));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (useCupertino) {
      // 使用 Cupertino 风格的页面
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("外观设置"),
        ),
        child: ListView(children: [
          const SettingsLabel(text: '主题'),
          // ... 其他设置项保持不变，因为已经使用了适配的组件
          const SettingsLabel(text: '字体和界面密度'),
          // 添加 Fluent UI 切换选项
          SettingsSwitchTile(
            title: '使用 Fluent UI',
            subTitle: '启用微软 Fluent Design 风格界面',
            settingsKey: SettingsStorageKeys.useFluentUI,
            defualtValue: false,
            apply: () async {
              // 应用新的 UI 设置
              await Get.forceAppUpdate();
            },
          ),
          // 添加 Cupertino UI 切换选项
          SettingsSwitchTile(
            title: '使用 Cupertino UI',
            subTitle: '启用苹果 iOS 风格界面',
            settingsKey: SettingsStorageKeys.useCupertinoUI,
            defualtValue: false,
            apply: () async {
              // 应用新的 UI 设置
              await Get.forceAppUpdate();
            },
          ),
          // ... 其他设置项保持不变
        ]),
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的页面
      // 直接返回内容而不是NavigationView，避免与主页面的导航结构冲突
      return fluent.ScaffoldPage(
        header: const fluent.PageHeader(
          title: Text("外观设置"),
        ),
        content: ListView(
          children: [
            const SettingsLabel(text: '主题'),
            // ... 其他设置项保持不变，因为已经使用了适配的组件
            const SettingsLabel(text: '字体和界面密度'),
            // 添加 Fluent UI 切换选项
            SettingsSwitchTile(
              title: '使用 Fluent UI',
              subTitle: '启用微软 Fluent Design 风格界面',
              settingsKey: SettingsStorageKeys.useFluentUI,
              defualtValue: false,
              apply: () async {
                // 应用新的 UI 设置
                await Get.forceAppUpdate();
              },
            ),
            // 添加 Cupertino UI 切换选项
            SettingsSwitchTile(
              title: '使用 Cupertino UI',
              subTitle: '启用苹果 iOS 风格界面',
              settingsKey: SettingsStorageKeys.useCupertinoUI,
              defualtValue: false,
              apply: () async {
                // 应用新的 UI 设置
                await Get.forceAppUpdate();
              },
            ),
            // ... 其他设置项保持不变
          ],
        ),
      );
    } else {
      // 使用 Material 风格的页面
      return Scaffold(
          appBar: AppBar(title: const Text("外观设置")),
          body: ListView(children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Text(
                "主题",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: const Text("主题模式"),
              subtitle: Text(SettingsUtil.currentThemeMode.value),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          scrollable: true,
                          title: const Text("主题模式"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("取消"))
                          ],
                          contentPadding: EdgeInsets.zero,
                          content: Column(children: buildThemeModeList()),
                        ));
              },
            ),
            ListTile(
              title: const Text("主题颜色"),
              subtitle: Text(SettingsUtil.currentTheme.value),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          scrollable: true,
                          title: const Text("主题"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("取消"))
                          ],
                          contentPadding: EdgeInsets.zero,
                          content: Column(
                            children: buildThemeLists(),
                          ),
                        ));
              },
            ),
            // 隐藏显示模式设置选项
            // const SettingsLabel(text: '显示模式 - 结合金标联盟标准和Android官方方案'),
            // const SettingsSwitchTile(
            //   title: '金标联盟合规模式',
            //   subTitle: '开启金标联盟（ITGSA）移动智能终端显示标准合规检查',
            //   settingsKey: SettingsStorageKeys.enableITGSACompliance,
            //   defualtValue: true,
            // ),
            // SettingsSwitchTile(
            //   title: '增强沉浸式体验',
            //   subTitle: '结合Android Edge-to-Edge技术与金标联盟用户体验优化',
            //   settingsKey: SettingsStorageKeys.enhancedImmersiveMode,
            //   defualtValue: true,
            //   apply: () async {
            //     // 立即应用新的显示模式设置
            //     try {
            //       await exitFullScreen(); // 先重置到默认状态
            //       // 这样下次进入全屏时会使用新的设置
            //     } catch (e) {
            //       // 忽略错误，确保设置切换不会失败
            //     }
            //   },
            // ),
            // SettingsSwitchTile(
            //   title: '自适应边到边显示',
            //   subTitle: '根据设备能力智能启用Edge-to-Edge显示模式',
            //   settingsKey: SettingsStorageKeys.adaptiveEdgeToEdge,
            //   defualtValue: true,
            //   apply: () async {
            //     // 立即应用新的边到边显示设置
            //     try {
            //       await exitFullScreen(); // 重置系统UI状态
            //     } catch (e) {
            //       // 忽略错误
            //     }
            //   },
            // ),
            const SettingsLabel(text: '字体和界面密度'),
            // 添加 Fluent UI 切换选项
            SettingsSwitchTile(
              title: '使用 Fluent UI',
              subTitle: '启用微软 Fluent Design 风格界面',
              settingsKey: SettingsStorageKeys.useFluentUI,
              defualtValue: false,
              apply: () async {
                // 应用新的 UI 设置
                await Get.forceAppUpdate();
              },
            ),
            // 添加 Cupertino UI 切换选项
            SettingsSwitchTile(
              title: '使用 Cupertino UI',
              subTitle: '启用苹果 iOS 风格界面',
              settingsKey: SettingsStorageKeys.useCupertinoUI,
              defualtValue: false,
              apply: () async {
                // 应用新的 UI 设置
                await Get.forceAppUpdate();
              },
            ),
            ListTile(
              title: const Text('字体缩放倍数'),
              subtitle: Text('当前: ${SettingsUtil.getValue(
                      SettingsStorageKeys.textScaleFactor,
                      defaultValue: 1.0).toStringAsFixed(2)}x'),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('字体缩放倍数'),
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      double currentValue = SettingsUtil.getValue(
                          SettingsStorageKeys.textScaleFactor,
                          defaultValue: 1.0);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('当前值: ${currentValue.toStringAsFixed(2)}x'),
                          const SizedBox(height: 16),
                          Slider(
                            value: currentValue,
                            min: 0.8,
                            max: 1.4,
                            divisions: 12,
                            label: '${currentValue.toStringAsFixed(2)}x',
                            onChanged: (value) async {
                              await SettingsUtil.setValue(
                                  SettingsStorageKeys.textScaleFactor, value);
                              setState(() {});
                              // 立即应用新设置
                              await Get.forceAppUpdate();
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text('推荐: 1.0x - 1.2x 避免界面过于拥挤',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('界面密度设置'),
              subtitle: const Text('调整列表和卡片间距，解决DPI过小导致的拥挤问题'),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('界面密度优化'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('这些设置可以解决DPI过小导致的界面元素拥挤问题'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // 优化预设: 适合大多数设备的舒适设置
                          await SettingsUtil.setValue(SettingsStorageKeys.textScaleFactor, 1.1);
                          await SettingsUtil.setValue(SettingsStorageKeys.interfaceDensity, 1.2);
                          await SettingsUtil.setValue(SettingsStorageKeys.cardPadding, 16.0);
                          await Get.forceAppUpdate();
                          Navigator.pop(context);
                          Get.rawSnackbar(
                            message: '已应用推荐设置：字体 1.1x，密度 1.2x，间距 16px',
                            duration: const Duration(seconds: 3),
                          );
                        },
                        child: const Text('一键优化（推荐）'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () async {
                          // 恢复默认设置
                          await SettingsUtil.setValue(SettingsStorageKeys.textScaleFactor, 1.0);
                          await SettingsUtil.setValue(SettingsStorageKeys.interfaceDensity, 1.0);
                          await SettingsUtil.setValue(SettingsStorageKeys.cardPadding, 12.0);
                          await Get.forceAppUpdate();
                          Navigator.pop(context);
                          Get.rawSnackbar(
                            message: '已恢复默认设置',
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Text('恢复默认'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
            )
          ]));
    }
  }
}