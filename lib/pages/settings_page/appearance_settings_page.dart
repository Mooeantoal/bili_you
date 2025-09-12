import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/common/widget/settings_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
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
          const SettingsLabel(text: '显示模式 - 结合金标联盟标准和Android官方方案'),
          const SettingsSwitchTile(
            title: '金标联盟合规模式',
            subTitle: '开启金标联盟（ITGSA）移动智能终端显示标准合规检查',
            settingsKey: SettingsStorageKeys.enableITGSACompliance,
            defualtValue: true,
          ),
          const SettingsSwitchTile(
            title: '增强沉浸式体验',
            subTitle: '结合Android Edge-to-Edge技术与金标联盟用户体验优化',
            settingsKey: SettingsStorageKeys.enhancedImmersiveMode,
            defualtValue: true,
          ),
          const SettingsSwitchTile(
            title: '自适应边到边显示',
            subTitle: '根据设备能力智能启用Edge-to-Edge显示模式',
            settingsKey: SettingsStorageKeys.adaptiveEdgeToEdge,
            defualtValue: true,
          ),
          const SettingsLabel(text: '字体'),
          ListTile(
            title: const Text('缩放倍数'),
            subtitle: Text(SettingsUtil.getValue(
                    SettingsStorageKeys.textScaleFactor,
                    defaultValue: 0.75)
                .toString()),
            onTap: () => showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text('缩放倍数'),
                children: [
                  Slider(
                    value: SettingsUtil.getValue(
                        SettingsStorageKeys.textScaleFactor,
                        defaultValue: 0.75),
                    min: 0.5,
                    max: 2,
                    divisions: 6,
                    onChanged: (value) async {
                      await SettingsUtil.setValue(
                          SettingsStorageKeys.textScaleFactor, value);
                      await Get.forceAppUpdate();
                    },
                  )
                ],
              ),
            ),
          )
        ]));
  }
}
