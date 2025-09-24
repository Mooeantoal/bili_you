import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_operation_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player_panel.dart';
import 'package:get/get.dart';

class BiliVideoController extends GetxController {
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
  late BiliVideoPlayerPanelController panelController;
  final cacheManager = CacheUtils.biliYouCacheManager;
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
      await _loadVideoPlayInfo();
      _initPlayer();
      _initPanelController();
      _loadInteractionState();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();
      rethrow;
    }
  }

  Future<void> _loadVideoInfo() async {
    videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
  }

  Future<void> _loadVideoPlayInfo() async {
    videoPlayInfo = await VideoPlayApi.getVideoPlayInfo(
      bvid: bvid,
      cid: cid,
      isBangumi: isBangumi,
      ssid: ssid,
    );
  }

  void _initPlayer() {
    biliVideoPlayerController = BiliVideoPlayerController(
      videoPlayInfo: videoPlayInfo,
      initialPosition: progress != null ? Duration(seconds: progress!) : null,
    );
  }

  void _initPanelController() {
    panelController = BiliVideoPlayerPanelController(
      biliVideoPlayerController: biliVideoPlayerController,
    );
  }

  Future<void> _loadInteractionState() async {
    var state = await VideoOperationApi.getVideoInteractionState(bvid: bvid);
    isLiked.value = state.isLiked;
    isCoined.value = state.isCoined;
    isFaved.value = state.isFaved;
    likeCount.value = state.likeCount;
    coinCount.value = state.coinCount;
    favCount.value = state.favCount;
    shareCount.value = state.shareCount;
  }

  Future<void> toggleLike() async {
    var result = await VideoOperationApi.clickLike(
      bvid: bvid,
      isCancel: isLiked.value,
    );
    isLiked.value = !isLiked.value;
    likeCount.value += isLiked.value ? 1 : -1;
  }

  Future<void> addCoin(int num) async {
    var result = await VideoOperationApi.addCoin(
      bvid: bvid,
      num: num,
    );
    isCoined.value = true;
    coinCount.value += num;
  }

  Future<void> toggleFav() async {
    var result = await VideoOperationApi.toggleFav(
      bvid: bvid,
      isCancel: isFaved.value,
    );
    isFaved.value = !isFaved.value;
    favCount.value += isFaved.value ? 1 : -1;
  }

  Future<void> shareVideo() async {
    shareCount.value += 1;
  }

  @override
  void onClose() {
    biliVideoPlayerController.dispose();
    super.onClose();
  }
}