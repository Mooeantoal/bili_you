import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/video/part_info.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/common/widget/video_tile_item.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:bili_you/pages/user_contribute/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';

class UserContributePage extends StatefulWidget {
  const UserContributePage({super.key, required this.mid});
  final int mid;

  @override
  State<UserContributePage> createState() => _UserContributePageState();
}

class _UserContributePageState extends State<UserContributePage>
    with AutomaticKeepAliveClientMixin {
  late UserContributeController controller;

  @override
  void initState() {
    controller = Get.put(
      UserContributeController(mid: widget.mid),
      tag: "user_contribute:${widget.mid}",
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<UserContributeController>(tag: "user_contribute:${widget.mid}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("用户投稿"),
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                controller.currentSortOrder.value == 'pubdate'
                    ? Icons.access_time
                    : Icons.remove_red_eye,
              ),
              onPressed: controller.toggleSortOrder,
              tooltip: controller.currentSortOrder.value == 'pubdate'
                  ? '按最新发布排序'
                  : '按最多播放排序',
            );
          }),
        ],
      ),
      body: SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onLoad: controller.onLoad,
        onRefresh: controller.onRefresh,
        childBuilder: (context, physics) => ListView.builder(
          padding: const EdgeInsets.all(12),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          physics: physics,
          itemCount: controller.searchItems.length,
          itemBuilder: (context, index) {
            var item = controller.searchItems[index];
            int heroTagId = HeroTagId.id++;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VideoTileItem(
                picUrl: item.coverUrl,
                bvid: item.bvid,
                title: item.title,
                upName: item.author,
                duration: item.duration,
                playNum: item.playCount,
                pubDate: item.pubDate,
                cacheManager: controller.cacheManager,
                heroTagId: heroTagId,
                onTap: (context) {
                  HeroTagId.lastId = heroTagId;
                  late List<PartInfo> videoParts;
                  Navigator.of(context).push(GetPageRoute(
                      page: () => FutureBuilder(
                            future: Future(() async {
                              try {
                                videoParts = await VideoInfoApi.getVideoParts(
                                    bvid: item.bvid);
                              } catch (e) {
                                log("加载cid失败,${e.toString()}");
                              }
                            }),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return BiliVideoPage(
                                  key: ValueKey('BiliVideoPage:${item.bvid}'),
                                  bvid: item.bvid,
                                  cid: videoParts.first.cid,
                                );
                              } else {
                                return const Scaffold(
                                  body: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                            },
                          )));
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}