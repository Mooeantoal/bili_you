import 'package:flutter/material.dart';
import 'package:bili_you/common/models/local/home/recommend_item_info.dart';

class PiliPlusVideoCard extends StatelessWidget {
  final RecommendVideoItemInfo item;
  final VoidCallback? onTap;
  final String? heroTag;
  
  const PiliPlusVideoCard({
    super.key,
    required this.item,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // 关闭阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            Hero(
              tag: heroTag ?? 'videoCover_${item.bvid}',
              child: AspectRatio(
                aspectRatio: 16/9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    item.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  // UP主和播放信息
                  Row(
                    children: [
                      Text(
                        item.upName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      const Icon(Icons.play_arrow, size: 14),
                      Text(
                        '${item.playNum}',
                        style: Theme.of(context).textTheme.bodySmall,
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