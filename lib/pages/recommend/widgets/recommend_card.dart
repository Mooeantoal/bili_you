import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:get/get.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({
    super.key,
    required this.imageUrl,
    required this.cacheManager,
    required this.heroTagId,
    String? title,
    String? upName,
    String? timeLength,
    String? playNum,
    String? danmakuNum,
    String? bvid,
    int? cid,
  })  : title = title ?? "--",
        upName = upName ?? "--",
        timeLength = timeLength ?? "--",
        playNum = playNum ?? "--",
        danmakuNum = danmakuNum ?? "--",
        bvid = bvid ?? "BV17x411w7KC",
        cid = cid ?? 279786;

  final CacheManager cacheManager;
  final String imageUrl;
  final String title;
  final String upName;
  final String timeLength;
  final String playNum;
  final String danmakuNum;
  final String bvid;
  final int cid;
  final int heroTagId;

  void onTap(BuildContext context) {
    HeroTagId.lastId = heroTagId;
    Navigator.of(context).push(GetPageRoute(
      page: () => BiliVideoPage(
        key: ValueKey('BiliVideoPage:$bvid'),
        bvid: bvid,
        cid: cid,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    String formattedPlayNum =
        StringFormatUtils.numFormat(int.tryParse(playNum) ?? 0);
    String formattedDanmakuNum =
        StringFormatUtils.numFormat(int.tryParse(danmakuNum) ?? 0);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onTap(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图 + 时长
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    cacheManager: cacheManager,
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: () => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    errorWidget: () => const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
              // 视频时长
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timeLength,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // UP主信息 (保持在封面图上)
          Positioned(
            left: 6,
            bottom: 6,
            child: Text(
              upName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  )
                ],
              ),
            ),
          ),

          // 封面下方信息区域
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                // 播放量和弹幕数
                Row(
                  children: [
                    Text(
                      "▶ $formattedPlayNum",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "💬 $formattedDanmakuNum",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
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
