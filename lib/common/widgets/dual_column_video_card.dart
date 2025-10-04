import 'package:bili_you/common/models/local/home/recommend_item_info.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // 导入用于毛玻璃效果的库

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
      elevation: 0, // 关闭阴影
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              StringFormatUtils.timeLengthFormat(item.timeLength),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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