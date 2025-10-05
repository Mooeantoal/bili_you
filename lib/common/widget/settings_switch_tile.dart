import 'package:bili_you/common/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    // 默认使用 Fluent UI 风格的组件
    return fluent.ListTile(
      title: fluent.Text(title),
      subtitle: fluent.Text(subTitle),
      trailing: fluent.StatefulBuilder(builder: (context, setState) {
        return fluent.ToggleSwitch(
          checked: SettingsUtil.getValue(settingsKey, defaultValue: defualtValue),
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