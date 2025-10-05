import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

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
      items.add(fluent.RadioButton(
        checked: widget.groupValue == value,
        content: fluent.Text(title),
        onChanged: (selected) {
          if (selected) {
            widget.onChanged?.call(value);
            setState(() {});
          }
        },
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 默认使用 Fluent UI 风格的对话框
    return fluent.ContentDialog(
      title: fluent.Text(widget.title),
      content: fluent.SizedBox(
        height: 200,
        child: fluent.SingleChildScrollView(
          child: fluent.Column(children: items),
        ),
      ),
      actions: [
        fluent.Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const fluent.Text('取消'),
        )
      ],
    );
  }
}