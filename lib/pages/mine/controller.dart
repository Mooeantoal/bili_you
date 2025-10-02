import 'dart:developer';

import 'package:bili_you/common/api/index.dart';
import 'package:bili_you/common/models/local/login/login_user_info.dart';
import 'package:bili_you/common/models/local/login/login_user_stat.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:get/get.dart';

class MineController extends GetxController {
  MineController() {
    print('MineController constructor called');
  }
  
  CacheManager cacheManager = CacheUtils.userFaceCacheManager;
  RxString faceUrl = ''.obs;
  RxString name = '测试用户'.obs;
  RxInt level = 1.obs;
  RxInt currentExp = 0.obs;
  RxInt nextExp = 100.obs;
  RxInt dynamicCount = 0.obs;
  RxInt followingCount = 0.obs;
  RxInt followerCount = 0.obs;

  RxBool islogin_ = false.obs;

  late LoginUserInfo userInfo;
  late LoginUserStat userStat;
  
  //用戶信息
  _initData() async {
    print('MineController _initData called');
    try {
      // 先设置一些默认数据，确保页面能正常显示
      name.value = '测试用户';
      level.value = 1;
      islogin_.value = false;
      faceUrl.value = 'https://i0.hdslb.com/bfs/face/member/noface.jpg';
      currentExp.value = 0;
      nextExp.value = 100;
      dynamicCount.value = 0;
      followerCount.value = 0;
      followingCount.value = 0;
      
      print('Setting default data completed');
      
      // 尝试获取真实数据
      print('Attempting to get user info...');
      userInfo = await LoginApi.getLoginUserInfo();
      print('User info retrieved successfully');
      print('User info: mid=${userInfo.mid}, name=${userInfo.name}, isLogin=${userInfo.isLogin}');
      
      print('Attempting to get user stat...');
      userStat = await LoginApi.getLoginUserStat();
      print('User stat retrieved successfully');
      print('User stat: follower=${userStat.followerCount}, following=${userStat.followingCount}, dynamic=${userStat.dynamicCount}');
      
      // 更新界面数据
      faceUrl.value = userInfo.avatarUrl;
      name.value = userInfo.name;
      level.value = userInfo.levelInfo.currentLevel;
      currentExp.value = userInfo.levelInfo.currentExp;
      nextExp.value = userInfo.levelInfo.nextExp;
      dynamicCount.value = userStat.dynamicCount;
      followerCount.value = userStat.followerCount;
      followingCount.value = userStat.followingCount;
      islogin_.value = userInfo.isLogin;
      
      print('Controller values updated:');
      print('  faceUrl: ${faceUrl.value}');
      print('  name: ${name.value}');
      print('  level: ${level.value}');
      print('  isLogin: ${islogin_.value}');
      print('  currentExp: ${currentExp.value}');
      print('  nextExp: ${nextExp.value}');
    } catch (e, stackTrace) {
      print('Error in _initData: $e');
      print('Stack trace: $stackTrace');
      log(e.toString());
      // 即使出错也保持默认数据，确保页面能显示
      name.value = '测试用户';
      level.value = 1;
      islogin_.value = false;
      faceUrl.value = 'https://i0.hdslb.com/bfs/face/member/noface.jpg';
      currentExp.value = 0;
      nextExp.value = 100;
      dynamicCount.value = 0;
      followerCount.value = 0;
      followingCount.value = 0;
    }
    // update(["user_face"]);
  }

  void onTap() {}

  // @override
  // void onInit() async {
  //   super.onInit();

  // }
  Future<void> loadOldFace() async {
    print('loadOldFace called');
    var box = BiliYouStorage.user;
    if (!await hasLogin()) {
      faceUrl.value = 'https://i0.hdslb.com/bfs/face/member/noface.jpg';
    } else {
      faceUrl.value = box.get("userFace") ?? 'https://i0.hdslb.com/bfs/face/member/noface.jpg';
    }
    print('faceUrl.value: ${faceUrl.value}');
    return;
  }

  void resetRX() {
    faceUrl.value = 'https://i0.hdslb.com/bfs/face/member/noface.jpg';
    name.value = '游客';
    level.value = 0;
    currentExp.value = 0;
    nextExp.value = 0;
    dynamicCount.value = 0;
    followingCount.value = 0;
    followerCount.value = 0;
  }

  @override
  void onReady() async {
    print('MineController onReady called');
    super.onReady();
    _initData();
  }
  
//登出
  onLogout() async {
    print('onLogout called');
    HttpUtils.cookieManager.cookieJar.deleteAll();
    resetRX();
    var box = BiliYouStorage.user;
    box.put(UserStorageKeys.hasLogin, false);
    cacheManager.emptyCache();
    islogin_.value = false;
  }
//檢查用戶是否登錄
  Future<bool> hasLogin() async {
    final result = BiliYouStorage.user.get(UserStorageKeys.hasLogin) ?? false;
    print('hasLogin result: $result');
    return result;
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
  
  // 添加公共方法来重新加载数据
  void reloadData() {
    print('MineController reloadData called');
    _initData();
  }
}