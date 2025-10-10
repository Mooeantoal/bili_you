import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/pages/bili_video2/video_test_route.dart';
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
          text: '视频测试',
        ),
        ListTile(
          title: const Text('基础视频测试'),
          subtitle: const Text('测试基本视频播放功能'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            VideoTestRoute.openVideoTestPage();
          },
        ),
        ListTile(
          title: const Text('高级视频调试'),
          subtitle: const Text('测试多种视频流格式和参数'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            VideoTestRoute.openAdvancedVideoDebugPage();
          },
        ),
        ListTile(
          title: const Text('详细API诊断'),
          subtitle: const Text('详细分析API响应结构'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            VideoTestRoute.openDetailedApiDebugPage();
          },
        ),
        ListTile(
          title: const Text('DASH流诊断'),
          subtitle: const Text('专门诊断DASH流信息缺失问题'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            VideoTestRoute.openDashStreamDebugPage();
          },
        ),
      ]),
    );
  }
}