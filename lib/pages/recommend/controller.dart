import 'dart:developer';

import 'package:bili_you/common/models/local/home/recommend_item_info.dart';
import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/home_api.dart';

class RecommendController extends GetxController {
  RecommendController();
  List<RecommendVideoItemInfo> recommendItems = [];

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  int refreshIdx = 0;
  CacheManager cacheManager = CacheUtils.recommendItemCoverCacheManager;
  int recommendColumnCount = 2;

  @override
  void onInit() {
    recommendColumnCount = SettingsUtil.getValue(
        SettingsStorageKeys.recommendColumnCount,
        defaultValue: 2);
    super.onInit();
    // 初始加载数据
    _addRecommendItems().then((success) {
      if (!success) {
        // 首次加载失败后自动重试一次
        _addRecommendItems();
      }
    });
  }

  void animateToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

//加载并追加视频推荐
  Future<bool> _addRecommendItems() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] 开始加载推荐视频，refreshIdx: $refreshIdx');
      var items = await HomeApi.getRecommendVideoItems(
          num: 30, refreshIdx: refreshIdx)
          .timeout(const Duration(seconds: 10));
      print('[$timestamp] 成功加载到${items.length}条推荐视频');
      if (items.isNotEmpty) {
        print('[$timestamp] 示例视频: ${items.first.title}');
      } else {
        print('[$timestamp] 警告: 推荐视频列表为空');
      }
      recommendItems.addAll(items);
    } catch (e) {
      final timestamp = DateTime.now().toIso8601String();
      log("[$timestamp] 加载推荐视频失败: ${e.toString()}");
      print('[$timestamp] 错误详情: ${e.runtimeType}');
      if (e is Error) {
        print('[$timestamp] 堆栈跟踪: ${e.stackTrace}');
      }
      return false;
    }
    refreshIdx += 1;
    return true;
  }

  Future<void> clearCache() async {
    await cacheManager.emptyCache();
    recommendItems.clear();
    refreshIdx = 0;
  }

  Future<void> onRefresh() async {
    await clearCache();
    if (await _addRecommendItems()) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoad() async {
    if (await _addRecommendItems()) {
      refreshController.finishLoad(IndicatorResult.success);
      refreshController.resetFooter();
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }
}
