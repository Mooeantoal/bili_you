import 'package:bili_you/common/widget/radio_list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
// 添加 Fluent UI 导入
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SettingsRadiosTile<T> extends StatefulWidget {
  const SettingsRadiosTile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.buildTrailingText,
      required this.itemNameValue,
      required this.buildGroupValue,
      required this.applyValue});
  final String title;
  final String subTitle;

  ///当前已选择项的名称
  final String Function() buildTrailingText;

  ///项的(名称--值)数据表
  final Map<String, T> itemNameValue;

  ///当前选择项的值
  final T Function() buildGroupValue;

  ///使当前选择值生效的回调函数
  final Function(T value) applyValue;

  @override
  State<SettingsRadiosTile<T>> createState() => _SettingsRadiosTileState<T>();
}

class _SettingsRadiosTileState<T> extends State<SettingsRadiosTile<T>> {
  @override
  Widget build(BuildContext context) {
    // 检查当前使用的 UI 框架
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    final bool useFluent = SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);
    
    if (useCupertino) {
      // 使用 Cupertino 风格的组件
      return CupertinoListTile(
        title: Text(widget.title),
        subtitle: Text(widget.subTitle),
        trailing: Text(widget.buildTrailingText()),
        onTap: () {
          showCupertinoDialog(
            context: context,
            builder: (context) => RadioListDialog(
              title: widget.title,
              itemNameValueMap: widget.itemNameValue,
              groupValue: widget.buildGroupValue(),
              onChanged: (value) {
                if (value != null) widget.applyValue(value);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          );
        },
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
                  Text(widget.title),
                  Text(widget.subTitle, style: fluent.FluentTheme.of(context).typography.caption),
                ],
              ),
              Text(widget.buildTrailingText()),
            ],
          ),
        ),
      );
    } else {
      // 使用 Material 风格的组件
      return ListTile(
        title: Text(widget.title),
        subtitle: Text(widget.subTitle),
        trailing: Text(widget.buildTrailingText()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => RadioListDialog(
              title: widget.title,
              itemNameValueMap: widget.itemNameValue,
              groupValue: widget.buildGroupValue(),
              onChanged: (value) {
                if (value != null) widget.applyValue(value);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          );
        },
      );
    }
  }
}