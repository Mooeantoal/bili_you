import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/pages/video_test/video_test_page.dart';
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
          text: '视频',
        ),
        ListTile(
          title: const Text('视频测试'),
          subtitle: const Text('测试视频播放和评论功能'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Get.to(() => const VideoTestPage());
          },
        ),
        // 移除了新搜索页面测试入口
      ]),
    );
  }
}