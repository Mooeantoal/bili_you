// 完整替换此文件的内容为以下代码
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard(
      {super.key,
      required this.imageUrl,
      required this.cacheManager,
      required this.heroTagId,
      String? title,
      String? upName,
      String? timeLength,
      String? playNum,
      String? danmakuNum,
      String? bvid,
      int? cid})
      : title = title ?? "--",
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
    TextStyle playInfoTextStyle = TextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 10,
        overflow: TextOverflow.ellipsis);
    Color iconColor = Theme.of(context).hintColor;
    
    // 优化：格式化数字，例如10000显示为1万
    String formattedPlayNum = StringFormatUtils.numFormat(int.tryParse(playNum) ?? 0);
    String formattedDanmakuNum = StringFormatUtils.numFormat(int.tryParse(danmakuNum) ?? 0);

    return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 16 / 9, // 从16/10改为16/9，更符合主流视频比例
                  child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Hero(
                        tag: heroTagId,
                        transitionOnUserGestures: true,
                        child: CachedNetworkImage(
                          cacheWidth: (boxConstraints.maxWidth *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(),
                          cacheHeight: (boxConstraints.maxHeight *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(),
                          cacheManager: cacheManager,
                          fit: BoxFit.cover,
                          imageUrl: imageUrl,
                          placeholder: () => Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          errorWidget: () => const Center(
                            child: Icon(Icons.error),
                          ),
                          filterQuality: FilterQuality.none,
                        ));
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 优化标题：限制为单行，避免占用过多空间
                    Text(
                      title,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 优化信息行：将所有信息放在一行，更紧凑
                    Row(
                      children: [
                        // 播放量
                        Expanded(
                          flex: 2,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.slideshow_rounded,
                                    color: iconColor,
                                    size: 10,
                                  ),
                                ),
                                TextSpan(
                                  text: ' $formattedPlayNum',
                                  style: playInfoTextStyle,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 弹幕数
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.format_list_bulleted_rounded,
                                    color: iconColor,
                                    size: 10,
                                  ),
                                ),
                                TextSpan(
                                  text: ' $formattedDanmakuNum',
                                  style: playInfoTextStyle,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 时长
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.timer_outlined,
                                    color: iconColor,
                                    size: 10,
                                  ),
                                ),
                                TextSpan(
                                  text: ' $timeLength',
                                  style: playInfoTextStyle,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // 作者名 - 使用更小的字体
                    Text(
                      upName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).hintColor,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(context),
              ))
        ]));
  }
}