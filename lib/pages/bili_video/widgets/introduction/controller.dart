import 'dart:developer';

import 'package:bili_you/common/api/index.dart';
import 'package:bili_you/common/api/video_operation_api.dart';
import 'package:bili_you/common/models/local/video_tile/video_tile_info.dart';
import 'package:bili_you/common/models/local/video/click_add_coin_result.dart';
import 'package:bili_you/common/models/local/video/click_add_share_result.dart';
import 'package:bili_you/common/models/local/video/click_like_result.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class IntroductionController extends GetxController {
  IntroductionController(
      {required this.bvid,
      required this.cid,
      required this.ssid,
      required this.isBangumi,
      required this.changePartCallback,
      required this.refreshReply});
  String bvid;
  int? cid;
  int? ssid;
  RxString title = "".obs;
  RxString describe = "".obs;

  VideoInfo? videoInfo; // 允许为null，直到加载完成
  RxBool isInitialized = false.obs;
  RxBool isLoading = false.obs;

  final bool isBangumi;
  final Function(String bvid, int cid) changePartCallback;
  final Function() refreshReply;
  Function()? refreshOperationButton; //刷新操作按钮(如点赞之类的按钮)
  final CacheManager cacheManager =
      CacheUtils.relatedVideosItemCoverCacheManager;
  final ScrollController scrollController = ScrollController();

  final List<Widget> partButtons = []; //分p按钮列表
  final List<VideoTileInfo> relatedVideoInfos = []; //相关视频列表

  //加载视频信息
  Future<bool> loadVideoInfo() async {
    // 如果已经在加载或已初始化，则直接返回
    if (isLoading.value || isInitialized.value) {
      return isInitialized.value;
    }
    
    isLoading.value = true;
    try {
      videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      // 确保videoInfo不为null
      if (videoInfo == null) {
        isLoading.value = false;
        isInitialized.value = true; // 标记为已初始化但失败
        return false;
      }
    } catch (e) {
      log("loadVideoInfo:$e");
      isLoading.value = false;
      isInitialized.value = true; // 标记为已初始化但失败
      return false;
    }
    
    try {
      title.value = videoInfo!.title;
      describe.value = videoInfo!.describe;
    } catch (e) {
      log("设置标题或描述时出错:$e");
    }
    
    // 清空之前的分P按钮
    partButtons.clear();
    
    try {
      if (!isBangumi) {
        //当是普通视频时
        //初始化时构造分p按钮
        _loadVideoPartButtons();
        //构造相关视频
        await _loadRelatedVideos();
      } else {
        //如果是番剧
        await _loadBangumiPartButtons();
      }
    } catch (e) {
      log("加载分P按钮或相关视频时出错:$e");
      // 即使这部分出错，也不影响主要信息显示
    }
    
    isInitialized.value = true;
    isLoading.value = false;
    return true;
  }

  //添加一个分p/剧集按钮
  void _addAButtion(String bvid, int cid, String text, int index) {
    partButtons.add(
      Padding(
        padding: const EdgeInsets.all(2),
        child: MaterialButton(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Theme.of(Get.context!).colorScheme.primaryContainer,
            onPressed: () async {
              //点击切换分p
              changePartCallback(bvid, cid);
              if (isBangumi) {
                //如果是番剧的还，切换时还需要改变标题，简介
                try {
                  videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
                  //刷新操作按钮(如点赞之类的按钮)
                  refreshOperationButton?.call();
                  if (videoInfo != null) {
                    title.value = videoInfo!.title;
                    describe.value = videoInfo!.describe;
                  }
                  //评论区也要刷新
                  refreshReply();
                } catch (e) {
                  log("切换番剧分集时出错:$e");
                  Get.snackbar("错误", "切换分集失败");
                }
              }
            },
            child: Text(text)),
      ),
    );
  }

  //构造分p按钮列表
  void _loadVideoPartButtons() {
    if (videoInfo != null && videoInfo!.parts.length > 1) {
      for (int i = 0; i < videoInfo!.parts.length; i++) {
        _addAButtion(bvid, videoInfo!.parts[i].cid, videoInfo!.parts[i].title, i);
      }
    }
  }

  //构造番剧剧集按钮
  Future<void> _loadBangumiPartButtons() async {
    // 确保ssid不为null
    if (ssid == null) {
      return;
    }
    try {
      var bangumiInfo = await BangumiApi.getBangumiInfo(ssid: ssid);
      for (int i = 0; i < bangumiInfo.episodes.length; i++) {
        _addAButtion(bangumiInfo.episodes[i].bvid, bangumiInfo.episodes[i].cid,
            bangumiInfo.episodes[i].title, i);
      }
    } catch (e) {
      log("加载番剧剧集按钮时出错:$e");
    }
  }

  //构造相关视频
  Future<void> _loadRelatedVideos() async {
    List<VideoTileInfo> list = [];
    try {
      list = await RelatedVideoApi.getRelatedVideo(bvid: bvid);
    } catch (e) {
      log("构造相关视频失败:${e.toString()}");
      return;
    }
    relatedVideoInfos.addAll(list);
  }

  ///点赞按钮点击时
  Future<void> onLikePressed() async {
    // 确保videoInfo不为null
    if (videoInfo == null) {
      Get.snackbar("提示", "视频信息未加载完成");
      return;
    }
    
    try {
      ClickLikeResult result = await VideoOperationApi.clickLike(
          bvid: videoInfo!.bvid, likeOrCancelLike: !videoInfo!.hasLike);
      
      if (result.isSuccess) {
        videoInfo!.hasLike = result.haslike;
        if (result.haslike) {
          log('${result.haslike}');
          videoInfo!.likeNum++;
        } else {
          log('${result.haslike}');
          videoInfo!.likeNum--;
        }
      } else {
        Get.showSnackbar(GetSnackBar(
          message: "失败:${result.error}",
          duration: const Duration(milliseconds: 1000),
        ));
      }
      refreshOperationButton!.call();
    } catch (e) {
      log('onLikePressed错误:$e');
      Get.showSnackbar(GetSnackBar(
        message: "操作失败，请重试",
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }

  Future<void> onAddCoinPressed() async {
    // 确保videoInfo不为null
    if (videoInfo == null) {
      Get.snackbar("提示", "视频信息未加载完成");
      return;
    }
    
    try {
      ClickAddCoinResult result = await VideoOperationApi.addCoin(bvid: bvid);
      if (result.isSuccess) {
        videoInfo!.hasAddCoin = result.isSuccess;
        videoInfo!.coinNum++;
        refreshOperationButton!.call();
        Get.snackbar("提示", "投币成功");
      } else {
        Get.showSnackbar(GetSnackBar(
          message: "失败:${result.error}",
          duration: const Duration(milliseconds: 1000),
        ));
      }
    } catch (e) {
      log('onAddCoinPressed错误:$e');
      Get.showSnackbar(GetSnackBar(
        message: "投币失败，请重试",
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }

  Future<void> onAddSharePressed() async {
    // 确保videoInfo不为null
    if (videoInfo == null) {
      Get.snackbar("提示", "视频信息未加载完成");
      return;
    }
    
    try {
      ClickAddShareResult result = await VideoOperationApi.share(bvid: bvid);
      if (result.isSuccess) {
        videoInfo!.shareNum = result.currentShareNum;
        Get.snackbar("提示", "分享成功");
      } else {
        log('分享失败:${result.error}');
        Get.snackbar("提示", "分享失败: ${result.error}");
      }
      Share.share('${ApiConstants.bilibiliBase}/video/$bvid');
    } catch (e) {
      log('onAddSharePressed错误:$e');
      Get.rawSnackbar(message: '分享失败:$e');
    }
    refreshOperationButton!.call();
  }

  @override
  void onClose() {
    try {
      cacheManager.emptyCache();
    } catch (e) {
      log("清空缓存时出错:$e");
    }
    super.onClose();
  }
}