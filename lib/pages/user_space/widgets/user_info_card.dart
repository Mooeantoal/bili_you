import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key, required this.controller});
  final UserSpacePageController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户基本信息行
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 30,
                  backgroundImage: controller.userAvatar.value.isNotEmpty
                      ? NetworkImage(controller.userAvatar.value)
                      : null,
                  child: controller.userAvatar.value.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 16),
                // 用户名称和关注按钮
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.username.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return ElevatedButton(
                          onPressed: controller.followUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isFollowing.value
                                ? theme.colorScheme.secondaryContainer
                                : theme.colorScheme.primary,
                            foregroundColor: controller.isFollowing.value
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onPrimary,
                          ),
                          child: Text(
                            controller.isFollowing.value ? '已关注' : '关注',
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 用户签名
            Obx(() {
              return Text(
                controller.userSign.value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              );
            }),
            const SizedBox(height: 16),
            // 粉丝和关注数量
            Obx(() {
              return Row(
                children: [
                  Text(
                    '关注 ${controller.followingCount.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '粉丝 ${controller.followerCount.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}