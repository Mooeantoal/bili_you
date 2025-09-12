import 'package:bili_you/common/models/local/home/recommend_item_info.dart';
import 'package:flutter/material.dart';

class BiliVideoCard extends StatelessWidget {
  final RecommendVideoItemInfo item;
  final double width;

  const BiliVideoCard({
    super.key,
    required this.item,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.coverUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 视频信息
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.play_arrow_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    Text(
                      item.playNum.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}