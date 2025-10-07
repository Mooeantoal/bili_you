import 'package:bili_you/pages/user_contribute/view.dart';
import 'package:bili_you/pages/user_dynamic/view.dart';
import 'package:bili_you/pages/user_home/view.dart';
import 'package:bili_you/pages/user_space/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class FullUserSpacePage extends StatefulWidget {
  const FullUserSpacePage({super.key, required this.mid});
  final int mid;

  @override
  State<FullUserSpacePage> createState() => _FullUserSpacePageState();
}

class _FullUserSpacePageState extends State<FullUserSpacePage>
    with SingleTickerProviderStateMixin {
  late UserSpacePageController controller;
  late TabController _tabController;

  @override
  void initState() {
    controller = Get.put(
      UserSpacePageController(mid: widget.mid),
      tag: "user_space:${widget.mid}",
    );
    
    // 初始化TabController，包含主页、动态、投稿三个标签页
    _tabController = TabController(length: 3, vsync: this);
    
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<UserSpacePageController>(tag: "user_space:${widget.mid}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.username.value)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "主页"),
            Tab(text: "动态"),
            Tab(text: "投稿"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('分享'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 19),
                    SizedBox(width: 10),
                    Text('举报'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'share') {
                // 实现分享功能
                String shareText = '快来关注${controller.username.value}的B站空间吧！\n'
                    'https://space.bilibili.com/${widget.mid}';
                await Share.share(shareText);
              } else if (value == 'report') {
                // 实现举报功能
                Get.defaultDialog(
                  title: "举报用户",
                  content: const Text("请选择举报原因"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar('提示', '举报成功，我们会尽快处理');
                      },
                      child: const Text("违规内容"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar('提示', '举报成功，我们会尽快处理');
                      },
                      child: const Text("骚扰他人"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar('提示', '举报成功，我们会尽快处理');
                      },
                      child: const Text("其他"),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 主页标签页
          UserHomePage(mid: widget.mid),
          
          // 动态标签页
          UserDynamicPage(mid: widget.mid),
          
          // 投稿标签页（使用我们已有的实现）
          UserContributePage(mid: widget.mid),
        ],
      ),
    );
  }
}