import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart'; // 添加这行导入

class SettingsLabel extends StatelessWidget {
  const SettingsLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // 检查当前是否使用 Cupertino UI
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    
    if (useCupertino) {
      // 使用 Cupertino 风格的样式
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Text(
          text,
          style: const TextStyle(
            color: CupertinoColors.systemBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    } else {
      // 使用 Material 风格的样式
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
  }
}