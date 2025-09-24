import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'video_audio_player.dart';

class BiliVideoController extends GetxController with GetSingleTickerProviderStateMixin {
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

  late VideoAudioController biliVideoPlayerController;
  late TabController tabController;
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
      _initPlayer();
      _initTabController();
      _loadInteractionState();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();
    }
  }

  void _initPlayer() {
    biliVideoPlayerController = VideoAudioController();
  }

  void _initTabController() {
    tabController = TabController(length: 2, vsync: this);
  }

  Future _loadInteractionState() async {
    // 临时兼容，所有状态默认 false
    isLiked.value = false;
    isCoined.value = false;
    isFaved.value = false;
  }

  Future toggleLike() async {
    isLiked.value = !isLiked.value;
    likeCount.value += isLiked.value ? 1 : -1;
  }

  Future addCoin(int num) async {
    isCoined.value = true;
    coinCount.value += num;
  }

  Future toggleFav() async {
    // 临时兼容，不调用 API，直接切换状态
    isFaved.value = !isFaved.value;
    favCount.value += isFaved.value ? 1 : -1;
  }

  Future shareVideo() async {
    shareCount.value += 1;
  }

  void changeVideoPart(int partIndex, bool autoPlay) {}

  Future refreshReply() async {}

  @override
  void onClose() {
    biliVideoPlayerController.dispose();
    super.onClose();
  }
}
