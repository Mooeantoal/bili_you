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
                Obx(() {
                  return GestureDetector(
                    onTap: () {
                      // TODO: 实现查看大图头像功能
                      Get.snackbar('提示', '查看头像功能待实现');
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: controller.userAvatar.value.isNotEmpty
                          ? NetworkImage(controller.userAvatar.value)
                          : null,
                      child: controller.userAvatar.value.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  );
                }),
                const SizedBox(width: 16),
                // 用户名称和关注按钮
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.username.value,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // VIP标识
                            if (controller.isVip.value)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
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
            // 用户等级和性别信息
            Obx(() {
              return Row(
                children: [
                  // 等级
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Lv.${controller.level.value}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 性别
                  if (controller.sex.value.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          controller.sex.value == '男' ? Icons.male : Icons.female,
                          color: controller.sex.value == '男' ? Colors.blue : Colors.pink,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.sex.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  const SizedBox(width: 12),
                  // 生日
                  if (controller.birthday.value.isNotEmpty &&
                      controller.birthday.value != '0000-00-00')
                    Row(
                      children: [
                        const Icon(Icons.cake, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          controller.birthday.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // 粉丝和关注数量
            Obx(() {
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: 跳转到关注列表
                      Get.snackbar('提示', '关注列表功能待实现');
                    },
                    child: Text(
                      '关注 ${controller.followingCount.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      // TODO: 跳转到粉丝列表
                      Get.snackbar('提示', '粉丝列表功能待实现');
                    },
                    child: Text(
                      '粉丝 ${controller.followerCount.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '硬币 ${controller.coins.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // 认证信息
            Obx(() {
              if (controller.officialTitle.value.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.officialTitle.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            const SizedBox(height: 16),
            // 直播信息
            Obx(() {
              if (controller.isLiving.value) {
                return GestureDetector(
                  onTap: () {
                    // TODO: 跳转到直播间
                    Get.snackbar('提示', '跳转直播间功能待实现');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.live_tv, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '正在直播',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.liveRoomTitle.value,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}