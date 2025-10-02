import 'package:bili_you/common/models/network/user_relations/user_relation_types.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/pages/about/about_page.dart';
import 'package:bili_you/pages/history/history_page.dart';
import 'package:bili_you/pages/login/qrcode_login/view.dart';
import 'package:bili_you/pages/login/web_login/view.dart';
import 'package:bili_you/pages/settings_page/settings_page.dart';
import 'package:bili_you/pages/relation/view.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:bili_you/common/utils/settings.dart';

import 'controller.dart';

class MinePage extends GetView<MineController> {
  const MinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 检查当前使用的 UI 框架
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    final bool useFluent = SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);
    
    if (useCupertino) {
      // 使用 Cupertino 风格的页面
      return cupertino.CupertinoPageScaffold(
        navigationBar: const cupertino.CupertinoNavigationBar(
          middle: Text("我的"),
        ),
        child: _buildView(context),
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的页面
      return fluent.ScaffoldPage(
        header: const fluent.PageHeader(
          title: Text("我的"),
        ),
        content: _buildView(context),
      );
    } else {
      // 使用 Material 风格的页面
      return GetBuilder<MineController>(
        init: MineController(),
        id: "user_face",
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("我的"),
            ),
            body: _buildView(context),
          );
        },
      );
    }
  }
  
  // 为不同UI框架提供不同的视图构建方法
  Widget _buildView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(context),
          
          // 数据统计
          _buildStatsSection(context),
          
          // 功能列表
          _buildFunctionList(context),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 构建用户信息卡片
  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 用户头像和基本信息
            Row(
              children: [
                // 头像
                ClipOval(
                  child: FutureBuilder(
                    future: controller.loadOldFace(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ValueListenableBuilder(
                          valueListenable: BiliYouStorage.user
                              .listenable(keys: [UserStorageKeys.userFace]),
                          builder: (context, value, child) {
                            return CachedNetworkImage(
                              cacheWidth: (60 *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .toInt(),
                              cacheHeight: (60 *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .toInt(),
                              cacheManager: controller.cacheManager,
                              width: 60,
                              height: 60,
                              imageUrl: controller.faceUrl.value,
                              placeholder: () => const SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 用户名和等级
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            controller.name.value,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            "LV${controller.level.value}",
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary),
                          )),
                    ],
                  ),
                ),
                
                // 登录按钮（仅在未登录时显示）
                Obx(() => Offstage(
                      offstage: controller.islogin_.value,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 根据平台选择登录方式
                          if (Theme.of(context).platform == TargetPlatform.android ||
                              Theme.of(context).platform == TargetPlatform.iOS) {
                            Get.to(() => const WebLoginPage());
                          } else {
                            Get.to(() => const QrcodeLogin());
                          }
                        },
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text("登录"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    )),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 经验值进度条
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "经验值: ${controller.currentExp}/${controller.level.value != 6 ? controller.nextExp : '--'}",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      backgroundColor: Theme.of(context).dividerColor,
                      value: controller.nextExp.value > 0
                          ? controller.currentExp.value / controller.nextExp.value
                          : 0,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // 构建数据统计部分
  Widget _buildStatsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 动态
            _buildStatItem(
              context,
              controller.dynamicCount.value.toString(),
              "动态",
              () {},
            ),
            
            // 关注
            _buildStatItem(
              context,
              controller.followingCount.value.toString(),
              "关注",
              () async {
                if (await controller.hasLogin()) {
                  Navigator.of(context).push(GetPageRoute(
                      page: () => RelationPage(
                            mid: controller.userInfo.mid,
                            type: UserRelationType.following,
                          )));
                } else {
                  Get.rawSnackbar(message: '失败: 用户未登录');
                }
              },
            ),
            
            // 粉丝
            _buildStatItem(
              context,
              controller.followerCount.value.toString(),
              "粉丝",
              () async {
                if (await controller.hasLogin()) {
                  Navigator.of(context).push(GetPageRoute(
                      page: () => RelationPage(
                            mid: controller.userInfo.mid,
                            type: UserRelationType.follower,
                          )));
                } else {
                  Get.rawSnackbar(message: '失败: 用户未登录');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 构建单个统计数据项
  Widget _buildStatItem(BuildContext context, String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  // 构建功能列表
  Widget _buildFunctionList(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        
        // 历史记录
        MineListTile(
          icon: const Icon(Icons.history),
          title: '历史记录',
          onTap: () async {
            if (await controller.hasLogin()) {
              Navigator.of(context)
                  .push(GetPageRoute(page: () => const HistoryPage()));
            } else {
              Get.rawSnackbar(message: '失败: 用户未登录');
            }
          },
        ),
        
        // 设置
        MineListTile(
          icon: const Icon(Icons.settings),
          title: "设置",
          onTap: () {
            Navigator.of(context).push(GetPageRoute(
              page: () => const SettingsPage(),
            ));
          },
        ),
        
        // 关于
        MineListTile(
          icon: const Icon(Icons.info),
          title: "关于",
          onTap: () {
            Navigator.of(context).push(GetPageRoute(
              page: () => const AboutPage(),
            ));
          },
        ),
        
        // 退出登录
        Obx(() => Offstage(
              offstage: !controller.islogin_.value,
              child: MineListTile(
                icon: const Icon(Icons.logout_rounded),
                title: "退出登录",
                onTap: () async {
                  if (await controller.hasLogin()) {
                    _showLogoutDialog(context);
                  } else {
                    Get.rawSnackbar(message: '退出失败: 用户未登录');
                  }
                },
              ),
            )),
      ],
    );
  }

  // 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("退出登录"),
          content: const Text("是否确定要退出登录？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                controller.onLogout();
                Navigator.of(context).pop();
                Get.rawSnackbar(message: '退出成功');
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }
}

class MineListTile extends StatelessWidget {
  const MineListTile({
    super.key, 
    required this.icon, 
    required this.title, 
    this.onTap
  });
  
  final Function()? onTap;
  final Icon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    // 检查当前使用的 UI 框架
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    final bool useFluent = SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);
    
    if (useCupertino) {
      // 使用 Cupertino 风格的列表项
      return cupertino.CupertinoListTile(
        leading: icon,
        title: Text(title),
        trailing: const Icon(cupertino.CupertinoIcons.forward),
        onTap: onTap,
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的列表项
      return fluent.Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(title),
              ),
              Icon(
                fluent.FluentIcons.chevron_right,
                size: 16,
                color: fluent.FluentTheme.of(context).typography.caption?.color,
              ),
            ],
          ),
        ),
      );
    } else {
      // 使用 Material 风格的列表项
      return ListTile(
        leading: icon,
        title: Text(title),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onTap: onTap,
      );
    }
  }
}