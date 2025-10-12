import 'dart:developer';

import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/video/part_info.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/common/widget/video_tile_item.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:bili_you/pages/user_space/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/models/local/user/user_info.dart'; // 导入用户信息模型

class UserSpacePage extends StatefulWidget {
  const UserSpacePage({super.key, required this.mid}) : tag = "user_space:$mid";
  final int mid;
  final String tag;

  @override
  State<UserSpacePage> createState() => _UserSpacePageState();
}

class _UserSpacePageState extends State<UserSpacePage>
    with AutomaticKeepAliveClientMixin {
  late UserSpacePageController controller;
  @override
  void initState() {
    controller =
        Get.put(UserSpacePageController(mid: widget.mid), tag: widget.tag);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: const Text("用户投稿")),
        body: GetBuilder<UserSpacePageController>(
          builder: (controller) {
            return controller.isLoadingUserInfo
                ? const Center(child: CircularProgressIndicator())
                : controller.userInfo == null
                    ? SimpleEasyRefresher(
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
                                                videoParts =
                                                    await VideoInfoApi
                                                        .getVideoParts(
                                                            bvid: item.bvid);
                                              } catch (e) {
                                                log("加载cid失败,${e.toString()}");
                                              }
                                            }),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                return BiliVideoPage(
                                                  key: ValueKey(
                                                      'BiliVideoPage:${item.bvid}'),
                                                  bvid: item.bvid,
                                                  cid: videoParts.first.cid,
                                                );
                                              } else {
                                                return const Scaffold(
                                                  body: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              }
                                            })));
                                  }),
                            );
                          },
                        ))
                    : Column(
                        children: [
                          // 用户信息头部
                          _buildUserInfoHeader(controller.userInfo!),
                          // 用户投稿视频列表
                          Expanded(
                            child: SimpleEasyRefresher(
                              easyRefreshController:
                                  controller.refreshController,
                              onLoad: controller.onLoad,
                              onRefresh: controller.onRefresh,
                              childBuilder: (context, physics) =>
                                  ListView.builder(
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
                                          Navigator.of(context)
                                              .push(GetPageRoute(
                                                  page: () => FutureBuilder(
                                                      future: Future(() async {
                                                        try {
                                                          videoParts =
                                                              await VideoInfoApi
                                                                  .getVideoParts(
                                                                      bvid:
                                                                          item.bvid);
                                                        } catch (e) {
                                                          log("加载cid失败,${e.toString()}");
                                                        }
                                                      }),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .done) {
                                                          return BiliVideoPage(
                                                            key: ValueKey(
                                                                'BiliVideoPage:${item.bvid}'),
                                                            bvid: item.bvid,
                                                            cid: videoParts
                                                                .first.cid,
                                                          );
                                                        } else {
                                                          return const Scaffold(
                                                            body: Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          );
                                                        }
                                                      })));
                                        }),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
          },
        ));
  }

  // 构建用户信息头部
  Widget _buildUserInfoHeader(UserInfo userInfo) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                backgroundImage: userInfo.face.isNotEmpty
                    ? NetworkImage(userInfo.face)
                    : null,
                child: userInfo.face.isEmpty
                    ? const Icon(Icons.account_circle, size: 60)
                    : null,
              ),
              const SizedBox(width: 16),
              // 用户名称和等级
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userInfo.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 用户等级
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Lv${userInfo.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 关注和粉丝信息
                    Row(
                      children: [
                        Text('关注: ${userInfo.followingCount}'),
                        const SizedBox(width: 16),
                        Text('粉丝: ${userInfo.follower}'),
                        const SizedBox(width: 16),
                        Text('投稿: ${userInfo.archiveCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 用户签名
          if (userInfo.sign.isNotEmpty)
            Text(
              userInfo.sign,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 8),
          // 其他统计信息
          Wrap(
            spacing: 16,
            children: [
              Text('获赞: ${userInfo.likeNum}'),
              Text('硬币: ${userInfo.coins}'),
              Text('文章: ${userInfo.articleCount}'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}