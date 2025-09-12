import 'package:bili_you/common/models/local/home/recommend_item_info.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // 导入用于高斯模糊的库

class DualColumnVideoCard extends StatelessWidget {
  final RecommendVideoItemInfo item;
  final String? heroTag;

  const DualColumnVideoCard({
    super.key,
    required this.item,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            '/video?bvid=${item.bvid}&cid=${item.cid}',
            arguments: {
              'videoItem': item,
              'heroTag': heroTag ?? 'video_${item.bvid}',
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Image.network(
                    item.coverUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  if (item.timeLength > 0)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          // 添加轻微的阴影效果，模拟玻璃的立体感
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8), // 增大圆角
                          child: Stack(
                            children: [
                              // 背景模糊效果
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // 增加模糊度
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3), // 增加边框透明度
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              // 添加高光效果
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 文字内容
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                child: Text(
                                  StringFormatUtils.timeLengthFormat(item.timeLength),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600, // 加粗以提高可读性
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 视频信息
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // UP主和播放信息
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.upName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.play_arrow_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      Text(
                        StringFormatUtils.numFormat(item.playNum),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}