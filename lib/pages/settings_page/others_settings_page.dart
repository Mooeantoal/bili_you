import 'package:bili_you/common/widget/settings_label.dart';
import 'package:bili_you/common/utils/fullscreen.dart';
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
          text: '显示模式测试',
        ),
        ListTile(
          title: const Text(
            "测试金标联盟+Android结合方案",
          ),
          subtitle: const Text("点击测试新的显示模式效果"),
          onTap: () async {
            try {
              // 测试进入全屏
              await enterFullScreen();
              Get.rawSnackbar(
                message: '已进入增强沉浸式显示模式（金标联盟+Android结合）',
                duration: const Duration(seconds: 2),
              );
              
              // 3秒后自动退出
              Future.delayed(const Duration(seconds: 3), () async {
                await exitFullScreen();
                Get.rawSnackbar(
                  message: '已退出全屏模式，恢复正常显示',
                  duration: const Duration(seconds: 2),
                );
              });
            } catch (e) {
              Get.rawSnackbar(
                message: '测试失败：$e',
                duration: const Duration(seconds: 2),
              );
            }
          },
        ),
        ListTile(
          title: const Text(
            "查看当前显示模式状态",
          ),
          onTap: () async {
            DisplayMode mode = await ITGSAComplianceHelper.getRecommendedDisplayMode();
            bool compliance = await ITGSAComplianceHelper.checkDisplayCompliance();
            
            String modeText = '';
            switch (mode) {
              case DisplayMode.enhancedImmersive:
                modeText = '增强沉浸式（金标联盟+Android结合）';
                break;
              case DisplayMode.fullImmersive:
                modeText = '完全沉浸式（传统模式）';
                break;
              case DisplayMode.standard:
                modeText = '标准模式';
                break;
            }
            
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('显示模式状态'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('金标联盟合规性：${compliance ? "支持" : "不支持"}'),
                    const SizedBox(height: 8),
                    Text('推荐显示模式：$modeText'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            );
          },
        )
      ]),
    );
  }
}
