import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SettingsLabel extends StatelessWidget {
  const SettingsLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // 默认使用 Fluent UI 风格的样式
    return fluent.Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: fluent.Text(
        text,
        style: fluent.TextStyle(
          color: fluent.Colors.blue,
          fontWeight: fluent.FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}