import 'dart:developer';

import 'package:bili_you/common/api/user_space_api.dart';
import 'package:bili_you/common/models/local/user_space/user_video_search.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/user_info_api.dart';
import 'package:bili_you/common/models/local/user/user_info.dart';

class UserSpacePageController extends GetxController {
  UserSpacePageController({required this.mid});
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  CacheManager cacheManager = CacheUtils.searchResultItemCoverCacheManager;
  final int mid;
  int currentPage = 1;
  List<UserVideoItem> searchItems = [];
  UserInfo? userInfo; // 添加用户信息字段
  bool isLoadingUserInfo = false; // 添加加载状态字段

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo(); // 初始化时加载用户信息
  }

  // 加载用户信息
  Future<void> _loadUserInfo() async {
    isLoadingUserInfo = true;
    update(); // 通知UI更新

    try {
      // 修复：使用正确的参数名 uid 而不是 mid
      final userData = await UserInfoApi.getUserInfo(uid: mid.toString());
      if (userData != null) {
        userInfo = UserInfo.fromJson(userData.toJson()); // 转换为本地模型
      }
    } catch (e) {
      log("Failed to load user info: $e");
    } finally {
      isLoadingUserInfo = false;
      update(); // 通知UI更新
    }
  }

  Future<bool> loadVideoItemWidgtLists() async {
    late UserVideoSearch userVideoSearch;
    try {
      userVideoSearch =
          await UserSpaceApi.getUserVideoSearch(mid: mid, pageNum: currentPage);
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
}