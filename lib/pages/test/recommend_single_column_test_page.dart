import 'package:bili_you/common/api/home_api.dart';
import 'package:bili_you/common/models/local/home/recommend_item_info.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/common/widget/video_tile_item.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';

class RecommendSingleColumnTestPage extends StatefulWidget {
  const RecommendSingleColumnTestPage({Key? key}) : super(key: key);

  @override
  State<RecommendSingleColumnTestPage> createState() => _RecommendSingleColumnTestPageState();
}

class _RecommendSingleColumnTestPageState extends State<RecommendSingleColumnTestPage> {
  List<RecommendVideoItemInfo> recommendItems = [];
  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  int refreshIdx = 0;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    scrollController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  //加载并追加视频推荐
  Future<bool> _addRecommendItems() async {
    try {
      recommendItems.addAll(await HomeApi.getRecommendVideoItems(
          num: 30, refreshIdx: refreshIdx));
    } catch (e) {
      print("加载推荐视频失败:${e.toString()}");
      return false;
    }
    refreshIdx += 1;
    return true;
  }

  Future<void> _onRefresh() async {
    recommendItems.clear();
    refreshIdx = 0;
    if (await _addRecommendItems()) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> _onLoad() async {
    if (await _addRecommendItems()) {
      refreshController.finishLoad(IndicatorResult.success);
      refreshController.resetFooter();
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐单列测试页面'),
      ),
      body: SimpleEasyRefresher(
        easyRefreshController: refreshController,
        onLoad: _onLoad,
        onRefresh: _onRefresh,
        childBuilder: (context, physics) => ListView.builder(
          controller: scrollController,
          physics: physics,
          padding: const EdgeInsets.all(12),
          itemCount: recommendItems.length,
          itemBuilder: (context, index) {
            var i = recommendItems[index];
            var heroTagId = HeroTagId.id++;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VideoTileItem(
                picUrl: i.coverUrl,
                bvid: i.bvid,
                title: i.title,
                upName: i.upName,
                duration: StringFormatUtils.timeLengthFormat(i.timeLength),
                playNum: i.playNum,
                pubDate: 0, // RecommendVideoItemInfo中没有pubDate字段，使用默认值0
                cacheManager: CacheUtils.recommendItemCoverCacheManager,
                heroTagId: heroTagId,
                onTap: (context) {
                  HeroTagId.lastId = heroTagId;
                  Navigator.of(context).push(GetPageRoute(
                    page: () => BiliVideoPage(
                      key: ValueKey("BiliVideoPage:${i.bvid}"),
                      bvid: i.bvid,
                      cid: i.cid,
                    ),
                  ));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}