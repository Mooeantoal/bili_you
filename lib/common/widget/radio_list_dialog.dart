import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';

class RadioListDialog<T> extends StatefulWidget {
  const RadioListDialog(
      {super.key,
      required this.title,
      required this.itemNameValueMap,
      required this.groupValue,
      this.onChanged});
  final String title;
  final Map<String, T> itemNameValueMap;
  final T groupValue;
  final Function(T? value)? onChanged;

  @override
  State<RadioListDialog<T>> createState() => _RadioListDialogState<T>();
}

class _RadioListDialogState<T> extends State<RadioListDialog<T>> {
  late List<Widget> items;
  @override
  void initState() {
    items = <Widget>[];
    widget.itemNameValueMap.forEach((title, value) {
      items.add(RadioListTile(
        value: value,
        groupValue: widget.groupValue,
        title: Text(title),
        onChanged: (value) {
          widget.onChanged?.call(value);
          setState(() {});
        },
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 检查当前是否使用 Cupertino UI
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    
    if (useCupertino) {
      // 使用 Cupertino 风格的对话框
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(children: items),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          )
        ],
      );
    } else {
      // 使用 Material 风格的对话框
      return AlertDialog(
        scrollable: true,
        title: Text(widget.title),
        content: Column(children: items),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'))
        ],
      );
    }
  }
}