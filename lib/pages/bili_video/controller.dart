import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_operation_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_danmaku.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BiliVideoController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final String bvid;
  final int cid;
  final bool isBangumi;
  final int? ssid;
  final int? progress;

  BiliVideoController({
    required this.bvid,
    required this.cid,
    this.isBangumi = false,
    this.ssid,
    this.progress,
  });

  late VideoInfo videoInfo;
  late VideoPlayInfo videoPlayInfo;
  late BiliVideoPlayerController biliVideoPlayerController;
  late BiliVideoPlayerPanelController biliVideoPlayerPanelController;
  late BiliDanmakuController biliDanmakuController;
  late TabController tabController;
  final cacheManager = CacheUtils.bigImageCacheManager;
  final isLoading = true.obs;
  final isError = false.obs;
  final errorMessage = "".obs;
  final isLiked = false.obs;
  final isCoined = false.obs;
  final isFaved = false.obs;
  final likeCount = 0.obs;
  final coinCount = 0.obs;
  final favCount = 0.obs;
  final shareCount = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    try {
      await _loadVideoInfo();
      videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      _initPlayer();
      _initPanelController();
      _initTabController();
      await _loadInteractionState();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();
      rethrow;
    }
  }

  Future _loadVideoInfo() async {
    videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
    likeCount.value = videoInfo.likeNum;
    coinCount.value = videoInfo.coinNum;
    favCount.value = videoInfo.favariteNum;
    shareCount.value = videoInfo.shareNum;
  }

  void _initPlayer() {
    biliVideoPlayerController = BiliVideoPlayerController(
      bvid: bvid,
      cid: cid,
      initVideoPosition:
          progress != null ? Duration(seconds: progress!) : Duration.zero,
    );
  }

  void _initPanelController() {
    biliVideoPlayerPanelController = BiliVideoPlayerPanelController(
      biliVideoPlayerController: biliVideoPlayerController,
    );
  }

  void _initTabController() {
    tabController = TabController(length: 2, vsync: this);
  }

  Future _loadInteractionState() async {
    isLiked.value = await VideoOperationApi.hasLike(bvid: bvid);
    isCoined.value = await VideoOperationApi.hasAddCoin(bvid: bvid);
    isFaved.value = await VideoOperationApi.hasFavourite(bvid: bvid);
  }

  Future toggleLike() async {
    await VideoOperationApi.clickLike(
      bvid: bvid,
      likeOrCancelLike: !isLiked.value,
    );
    isLiked.value = !isLiked.value;
    likeCount.value += isLiked.value ? 1 : -1;
  }

  Future addCoin(int num) async {
    await VideoOperationApi.addCoin(bvid: bvid, num: num);
    isCoined.value = true;
    coinCount.value += num;
  }

  Future toggleFav() async {
    await VideoOperationApi.addFavourite( // ✅ 修正方法名
      bvid: bvid,
      isCancel: isFaved.value,
    );
    isFaved.value = !isFaved.value;
    favCount.value += isFaved.value ? 1 : -1;
  }

  Future shareVideo() async {
    shareCount.value += 1;
  }

  void changeVideoPart(String _, int partIndex) {
    if (partIndex < videoInfo.parts.length) {
      int newCid = videoInfo.parts[partIndex].cid;
      biliVideoPlayerController = BiliVideoPlayerController(
        bvid: bvid,
        cid: newCid,
        initVideoPosition: Duration.zero,
      );
      update(); // 通知UI更新播放器
    }
  }

  Future refreshReply() async {
    try {
      update(); // 通知UI更新评论区
    } catch (e) {
      errorMessage.value = "刷新评论失败: $e";
    }
  }

  @override
  void onClose() {
    biliVideoPlayerController.dispose();
    tabController.dispose();
    super.onClose();
  }
}
