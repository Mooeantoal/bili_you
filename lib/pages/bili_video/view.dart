import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/values/index.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:bili_you/pages/bili_video/widgets/introduction/index.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/api/history_api.dart';
import '../../common/utils/bvid_avid_util.dart';
import 'index.dart';
import 'widgets/bili_video_player/bili_danmaku.dart';
import 'widgets/bili_video_player/bili_video_player_panel.dart';
import 'widgets/reply/controller.dart';

class BiliVideoPage extends StatefulWidget {
  static final RouteObserver routeObserver = RouteObserver();
  const BiliVideoPage(
      {Key? key,
      required this.bvid,
      required this.cid,
      this.isBangumi = false,
      this.ssid,
      this.progress})
      : tag = "BiliVideoPage:$bvid",
        super(key: key);
  final String bvid;
  final int cid;
  final int? ssid;
  final bool isBangumi;
  final int? progress;
  final String tag;
  @override
  State<BiliVideoPage> createState() => _BiliVideoPageState();
}

class _BiliVideoPageState extends State<BiliVideoPage>
    with RouteAware, WidgetsBindingObserver {
  int currentTabIndex = 0;
  late BiliVideoController controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (SettingsUtil.getValue(SettingsStorageKeys.isBackGroundPlay,
              defaultValue: true) ==
          false) {
        controller.biliVideoPlayerController.pause();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    BiliVideoPage.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPushNext() async {
    CacheUtils.clearAllCacheImageMem();
    await controller.biliVideoPlayerController.pause();
    super.didPushNext();
  }

  @override
  void didPopNext() async {
    await controller.biliVideoPlayerController.refreshPlayer();
    super.didPopNext();
  }

  @override
  void didPop() async {
    var second = controller.biliVideoPlayerController.position.inSeconds;
    await controller.biliVideoPlayerController.pause();
    await HistoryApi.reportVideoViewHistory(
        aid: BvidAvidUtil.bvid2Av(controller.bvid),
        cid: controller.cid,
        progress: second);
    CacheUtils.clearAllCacheImageMem();
    super.didPop();
  }

  @override
  void dispose() async {
    controller.dispose();
    BiliVideoPage.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    controller = Get.put(
      BiliVideoController(
          bvid: widget.bvid,
          cid: widget.cid,
          isBangumi: widget.isBangumi,
          progress: widget.progress,
          ssid: widget.ssid),
      tag: widget.tag,
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Widget _buildView(context, BiliVideoController controller) {
    return Column(
      children: [
        TabBar(
          controller: controller.tabController,
          splashFactory: NoSplash.splashFactory,
          tabs: const [Tab(text: "简介"), Tab(text: "评论")],
          onTap: (value) {
            if (value == currentTabIndex) {
              switch (value) {
                case 0:
                  Get.find<IntroductionController>(
                          tag: "IntroductionPage:${widget.bvid}")
                      .scrollController
                      .animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear);
                  break;
                case 1:
                  Get.find<ReplyController>(tag: "ReplyPage:${widget.bvid}")
                      .scrollController
                      .animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear);
                  break;
                default:
                  break;
              }
            } else {
              currentTabIndex = value;
            }
          },
        ),
        Expanded(
          child: TabBarView(
            controller: controller.tabController,
            children: [
              IntroductionPage(
                changePartCallback: (_, partIndex) =>
                    controller.changeVideoPart(partIndex, false),
                refreshReply: controller.refreshReply,
                bvid: controller.bvid,
                cid: controller.cid,
                ssid: controller.ssid,
                isBangumi: controller.isBangumi,
              ),
              Builder(builder: (context) {
                return ReplyPage(
                  replyId: controller.bvid,
                  replyType: ReplyType.video,
                );
              })
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          body: Column(
            children: [
              BiliVideoPlayerWidget(
                controller.biliVideoPlayerController,
                heroTagId: HeroTagId.lastId,
                buildControllPanel: () {
                  return BiliVideoPlayerPanel(
                    controller.biliVideoPlayerPanelController,
                  );
                },
                buildDanmaku: () {
                  return BiliDanmaku(
                      controller: controller.biliDanmakuController);
                },
              ),
              Expanded(child: _buildView(context, controller)),
            ],
          ),
        ));
  }
}
