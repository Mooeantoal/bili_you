import 'package:bili_you/common/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    // 检查当前是否使用 Cupertino UI
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    
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