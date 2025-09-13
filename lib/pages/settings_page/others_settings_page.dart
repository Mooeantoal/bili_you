import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/common/utils/fullscreen.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          text: '界面密度测试',
        ),
        ListTile(
          title: const Text(
            "一键优化界面密度",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("解决DPI过小导致的界面元素拥挤问题"),
          onTap: () async {
            try {
              await SettingsUtil.applyDensityOptimization();
              await Get.forceAppUpdate();
              Get.rawSnackbar(
                message: '已应用界面密度优化设置！字体1.1x，密度1.2x，间距16px',
                duration: const Duration(seconds: 3),
              );
            } catch (e) {
              Get.rawSnackbar(
                message: '优化失败：$e',
                duration: const Duration(seconds: 2),
              );
            }
          },
        ),
        const SettingsLabel(
          text: '显示模式测试',
        ),
        // 更新简单直接全屏测试
        ListTile(
          title: const Text(
            "测试简单直接全屏",
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text("测试手动全屏模式切换"),
          onTap: () async {
            try {
              // 测试进入全屏模式
              await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              Get.rawSnackbar(
                message: '已进入全屏模式（immersiveSticky）',
                duration: const Duration(seconds: 2),
              );
              
              // 3秒后自动退出全屏模式，恢复默认模式
              Future.delayed(const Duration(seconds: 3), () async {
                await SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.manual,
                  overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
                );
                Get.rawSnackbar(
                  message: '已退出全屏模式，恢复默认显示',
                  duration: const Duration(seconds: 2),
                );
              });
            } catch (e) {
              Get.rawSnackbar(
                message: '全屏测试失败：$e',
                duration: const Duration(seconds: 2),
              );
            }
          },
        ),
        // 添加恢复默认显示模式的选项
        ListTile(
          title: const Text(
            "恢复默认显示模式",
            style: TextStyle(color: Colors.blue),
          ),
          subtitle: const Text("恢复状态栏和导航栏默认显示"),
          onTap: () async {
            try {
              await SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.manual,
                overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
              );
              Get.rawSnackbar(
                message: '已恢复默认显示模式',
                duration: const Duration(seconds: 2),
              );
            } catch (e) {
              Get.rawSnackbar(
                message: '恢复默认模式失败：$e',
                duration: const Duration(seconds: 2),
              );
            }
          },
        ),
      ]),
    );
  }
}
