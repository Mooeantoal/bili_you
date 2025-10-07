import 'package:bili_you/pages/user_space/controller.dart';
import 'package:bili_you/pages/user_space/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key, required this.mid});
  final int mid;

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with AutomaticKeepAliveClientMixin {
  late UserSpacePageController controller;

  @override
  void initState() {
    controller = Get.find<UserSpacePageController>(
      tag: "user_space:${widget.mid}",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息卡片
          UserInfoCard(controller: controller),
          
          // 用户统计数据
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '用户数据',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _UserStatItem(
                        icon: Icons.play_arrow,
                        label: '播放数',
                        value: '0',
                      ),
                      _UserStatItem(
                        icon: Icons.thumb_up,
                        label: '获赞数',
                        value: '0',
                      ),
                      _UserStatItem(
                        icon: Icons.comment,
                        label: '评论数',
                        value: '0',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 最新投稿预览
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最新投稿',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('暂无投稿'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _UserStatItem extends StatelessWidget {
  const _UserStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}