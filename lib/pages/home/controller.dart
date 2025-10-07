import 'dart:developer';

import 'package:bili_you/common/api/index.dart'; // 保留API导入，因为需要LoginApi
import 'package:bili_you/common/models/local/login/login_user_info.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/cache_util.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController();
  CacheManager cacheManager = CacheUtils.userFaceCacheManager;
  RxString faceUrl = ApiConstants.noface.obs;
  late LoginUserInfo userInfo;

  final List<Map<String, String>> tabsList = [
    // 删除了动态标签
    {'text': '直播', 'id': '', 'controller': 'LiveTabPageController'},
    {'text': '推荐', 'id': '', 'controller': 'RecommendController'},
    {'text': '热门', 'id': '', 'controller': 'PopularVideoController'},
    {'text': '番剧', 'id': '', 'controller': ''}
  ];
  final int tabInitIndex = 1;
  RxInt tabIndex = 1.obs;
  RxString selectedTab = "推荐".obs; // 添加选中的标签状态

  _initData() async {
    // 移除了与搜索相关的初始化代码
  }

  // 移除了刷新搜索框默认词的方法

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() async {
    super.onReady();
    _initData();
  }

  Future<void> refreshFace() async {
    try {
      userInfo = await LoginApi.getLoginUserInfo();
      faceUrl.value = userInfo.avatarUrl;
    } catch (e) {
      faceUrl.value = ApiConstants.noface;
      log(e.toString());
    }
  }

  Future<void> loadOldFace() async {
    var box = BiliYouStorage.user;
    faceUrl.value = box.get(UserStorageKeys.userFace) ?? ApiConstants.noface;
  }
}