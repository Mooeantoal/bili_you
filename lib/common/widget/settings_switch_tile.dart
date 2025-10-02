import 'package:bili_you/common/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
// 添加 Fluent UI 导入
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.settingsKey,
      required this.defualtValue,
      this.apply});
  final String title;
  final String subTitle;
  final String settingsKey;
  final bool defualtValue;

  ///在开关切换且设置保存后进行调用，提供给外部进行应用该设置项
  final Function()? apply;

  @override
  Widget build(BuildContext context) {
    // 检查当前使用的 UI 框架
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    final bool useFluent = SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);
    
    if (useCupertino) {
      // 使用 Cupertino 风格的组件
      return CupertinoListTile(
        title: Text(title),
        subtitle: Text(subTitle),
        trailing: StatefulBuilder(builder: (context, setState) {
          return CupertinoSwitch(
            value: SettingsUtil.getValue(settingsKey, defaultValue: defualtValue),
            onChanged: (value) async {
              await SettingsUtil.setValue(settingsKey, value);
              setState(() {});
              apply?.call();
            },
          );
        }),
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的组件
      return fluent.Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  Text(subTitle, style: fluent.FluentTheme.of(context).typography.caption),
                ],
              ),
              StatefulBuilder(builder: (context, setState) {
                return fluent.ToggleSwitch(
                  checked: SettingsUtil.getValue(settingsKey, defaultValue: defualtValue),
                  onChanged: (value) async {
                    await SettingsUtil.setValue(settingsKey, value);
                    setState(() {});
                    apply?.call();
                  },
                );
              }),
            ],
          ),
        ),
      );
    } else {
      // 使用 Material 风格的组件
      return ListTile(
        title: Text(title),
        subtitle: Text(subTitle),
        trailing: StatefulBuilder(builder: (context, setState) {
          return Switch(
            value: SettingsUtil.getValue(settingsKey, defaultValue: defualtValue),
            onChanged: (value) async {
              await SettingsUtil.setValue(settingsKey, value);
              setState(() {});
              apply?.call();
            },
          );
        }),
      );
    }
  }
}