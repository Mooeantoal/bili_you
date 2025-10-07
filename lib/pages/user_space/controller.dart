import 'dart:developer';

import 'package:bili_you/common/api/user_space_api.dart';
import 'package:bili_you/common/models/local/user_space/user_video_search.dart';
import 'package:bili_you/common/models/network/user_space/user_space_info.dart';
import 'package:bili_you/common/models/network/user_space/user_space_stat.dart';
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
  RxInt level = 1.obs;
  RxString sex = ''.obs;
  RxString birthday = ''.obs;
  RxInt coins = 0.obs;
  RxBool isVip = false.obs;
  RxString officialTitle = ''.obs;
  RxString liveRoomTitle = ''.obs;
  RxString liveRoomCover = ''.obs;
  RxBool isLiving = false.obs;
  
  // 用户统计数据
  RxInt archiveViewCount = 0.obs; // 视频播放量
  RxInt articleViewCount = 0.obs; // 专栏阅读量
  RxInt likesCount = 0.obs; // 获赞数

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载用户信息
    loadUserInfo();
    loadUserStat();
  }

  Future<void> loadUserInfo() async {
    try {
      // 获取用户详细信息
      UserSpaceInfoData userInfo = await UserSpaceApi.getUserSpaceInfo(mid: mid);
      
      // 更新用户信息
      username.value = userInfo.name ?? "用户$mid";
      userAvatar.value = userInfo.face ?? "";
      userSign.value = userInfo.sign ?? "这个用户很懒，什么都没有留下";
      followerCount.value = userInfo.fansBadge == true ? 1 : 0; // 粉丝数需要另外接口获取
      followingCount.value = 0; // 关注数需要另外接口获取
      isFollowing.value = false; // 关注状态需要另外接口获取
      level.value = userInfo.level ?? 1;
      sex.value = userInfo.sex ?? "";
      birthday.value = userInfo.birthday ?? "";
      coins.value = (userInfo.coins ?? 0).toInt();
      isVip.value = userInfo.vip?.status == 1;
      officialTitle.value = userInfo.official?.title ?? "";
      
      // 直播信息
      if (userInfo.liveRoom != null) {
        liveRoomTitle.value = userInfo.liveRoom?.title ?? "";
        liveRoomCover.value = userInfo.liveRoom?.cover ?? "";
        isLiving.value = userInfo.liveRoom?.liveStatus == 1;
      }
    } catch (e) {
      log("loadUserInfo error: $e");
      // 出错时使用默认值
      username.value = "用户$mid";
      userAvatar.value = "";
      userSign.value = "这个用户很懒，什么都没有留下";
      followerCount.value = 0;
      followingCount.value = 0;
      isFollowing.value = false;
      level.value = 1;
      sex.value = "";
      birthday.value = "";
      coins.value = 0;
      isVip.value = false;
      officialTitle.value = "";
      liveRoomTitle.value = "";
      liveRoomCover.value = "";
      isLiving.value = false;
    }
  }

  Future<void> loadUserStat() async {
    try {
      // 获取用户统计数据
      UserSpaceStatData userStat = await UserSpaceApi.getUserSpaceStat(mid: mid);
      
      // 更新统计数据
      if (userStat.archive?.view != null) {
        // 处理不同的数据类型（可能是数字或字符串"--"）
        if (userStat.archive!.view is int) {
          archiveViewCount.value = userStat.archive!.view as int;
        } else if (userStat.archive!.view is String) {
          // 尝试解析字符串为数字
          String viewStr = userStat.archive!.view as String;
          if (viewStr != "--") {
            archiveViewCount.value = int.tryParse(viewStr) ?? 0;
          }
        }
      }
      
      articleViewCount.value = userStat.article?.view ?? 0;
      likesCount.value = userStat.likes?.likes ?? 0;
    } catch (e) {
      log("loadUserStat error: $e");
      // 出错时使用默认值
      archiveViewCount.value = 0;
      articleViewCount.value = 0;
      likesCount.value = 0;
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