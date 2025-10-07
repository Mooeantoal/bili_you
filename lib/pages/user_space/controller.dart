import 'dart:developer';

import 'package:bili_you/common/api/user_space_api.dart';
import 'package:bili_you/common/models/local/user_space/user_video_search.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class UserSpacePageController extends GetxController {
  UserSpacePageController({required this.mid});
  
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  CacheManager cacheManager = CacheUtils.searchResultItemCoverCacheManager;
  final int mid;
  int currentPage = 1;
  List<UserVideoItem> searchItems = [];
  RxString currentSortOrder = 'pubdate'.obs; // pubdate: 最新发布, click: 最多播放

  // 用户信息相关变量
  RxString username = ''.obs;
  RxString userAvatar = ''.obs;
  RxString userSign = ''.obs;
  RxInt followerCount = 0.obs;
  RxInt followingCount = 0.obs;
  RxBool isFollowing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载用户信息
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    try {
      // TODO: 实现获取用户详细信息的API调用
      // 这里暂时使用默认值
      username.value = "用户$mid";
      userAvatar.value = "";
      userSign.value = "这个用户很懒，什么都没有留下";
      followerCount.value = 0;
      followingCount.value = 0;
      isFollowing.value = false;
    } catch (e) {
      log("loadUserInfo error: $e");
    }
  }

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

  void followUser() {
    // 关注/取消关注用户
    isFollowing.value = !isFollowing.value;
    if (isFollowing.value) {
      followerCount.value++;
    } else {
      followerCount.value--;
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}