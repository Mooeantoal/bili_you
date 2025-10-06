import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/pages/search_test/view.dart'; // 添加导入
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cache_management_page.dart';

class OthersSettingsPage extends StatelessWidget {
  const OthersSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("其他设置"),
      ),
      body: ListView(children: [
        const SettingsLabel(
          text: '缓存',
        ),
        ListTile(
          title: const Text(
            "缓存管理",
          ),
          onTap: () {
            Navigator.of(context).push(GetPageRoute(
              page: () => const CacheManagementPage(),
            ));
          },
        ),
        const SettingsLabel(
          text: '测试功能',
        ),
        ListTile(
          title: const Text(
            "新搜索页面测试",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("从PiliPlus-main移植的搜索页面"),
          onTap: () {
            Navigator.of(context).push(GetPageRoute(
              page: () => const SearchTestPage(),
            ));
          },
        )
      ]),
    );
  }
}