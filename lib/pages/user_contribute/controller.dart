import 'dart:developer';

import 'package:bili_you/common/api/user_space_api.dart';
import 'package:bili_you/common/models/local/user_space/user_video_search.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class UserContributeController extends GetxController {
  UserContributeController({required this.mid});
  
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  CacheManager cacheManager = CacheUtils.searchResultItemCoverCacheManager;
  final int mid;
  int currentPage = 1;
  List<UserVideoItem> searchItems = [];
  RxString currentSortOrder = 'pubdate'.obs; // pubdate: 最新发布, click: 最多播放

  Future<bool> loadVideoItemWidgtLists() async {
    late UserVideoSearch userVideoSearch;
    try {
      userVideoSearch = await UserSpaceApi.getUserVideoSearch(
        mid: mid, 
        pageNum: currentPage,
        order: currentSortOrder.value,
      );
    } catch (e) {
      log("loadVideoItemWidgtLists:$e");
      return false;
    }
    searchItems.addAll(userVideoSearch.videos);
    currentPage++;
    return true;
  }

  Future<void> onLoad() async {
    if (await loadVideoItemWidgtLists()) {
      refreshController.finishLoad(IndicatorResult.success);
      refreshController.resetFooter();
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> onRefresh() async {
    await cacheManager.emptyCache();
    searchItems.clear();
    currentPage = 1;
    bool success = await loadVideoItemWidgtLists();
    if (success) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  void toggleSortOrder() {
    // 切换排序方式
    currentSortOrder.value = currentSortOrder.value == 'pubdate' ? 'click' : 'pubdate';
    // 刷新数据
    onRefresh();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}