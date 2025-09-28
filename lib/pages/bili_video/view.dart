import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controller.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/api/history_api.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';
import 'widgets/bili_video_player/bili_video_player.dart';
import 'widgets/bili_video_player/bili_video_player_panel.dart';
import 'widgets/bili_video_player/bili_danmaku.dart';
import 'widgets/introduction/index.dart';
import 'widgets/reply/view.dart';

class BiliVideoPage extends StatefulWidget {
  // 添加 routeObserver 静态属性
  static final RouteObserver routeObserver = RouteObserver();

  const BiliVideoPage({
    super.key,
    required this.bvid,
    required this.cid,
    this.isBangumi = false,
    this.ssid,
    this.progress,
  }) : tag = "BiliVideoPage:$bvid", super(key: key); // 新增 tag 参数

  final String bvid;
  final int cid;
  final int? ssid;
  final bool isBangumi;
  final int? progress;
  final String tag; // 新增 tag 属性

  @override
  State createState() => _BiliVideoPageState();
}

class _BiliVideoPageState extends State<BiliVideoPage> 
  with RouteAware, WidgetsBindingObserver { // 新增 RouteAware 混入

  int currentTabIndex = 0; // 新增标签页索引
  late BiliVideoController controller;

  @override
  void initState() {
    controller = Get.put(
      BiliVideoController(
        bvid: widget.bvid,
        cid: widget.cid,
        isBangumi: widget.isBangumi,
        progress: widget.progress,
        ssid: widget.ssid,
      ),
      tag: widget.tag, // 新增 tag 参数
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // 新增路由监听订阅
  @override
  void didChangeDependencies() {
    BiliVideoPage.routeObserver.subscribe(
      this,
      ModalRoute.of(context) as PageRoute,
    );
    super.didChangeDependencies();
  }

  // 新增应用生命周期监听
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && 
        !SettingsUtil.getValue(SettingsStorageKeys.isBackGroundPlay, defaultValue: true)) {
      controller.biliVideoPlayerController.pause();
    }
    super.didChangeAppLifecycleState(state);
  }

  // 新增路由切换生命周期方法
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
      progress: second,
    );
    CacheUtils.clearAllCacheImageMem();
    super.didPop();
  }

  @override
  void dispose() {
    controller.dispose();
    BiliVideoPage.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Column(
          children: [
            // 替换视频播放器为参考项目实现
            BiliVideoPlayerWidget(
              controller.biliVideoPlayerController,
              heroTagId: "BiliVideoPage:${widget.bvid}",
              buildControllPanel: () => BiliVideoPlayerPanel(
                controller.biliVideoPlayerPanelController,
              ),
              buildDanmaku: () => BiliDanmaku(
                controller: controller.biliDanmakuController,
              ),
            ),
            // 实现标签页（简介+评论）
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: controller.tabController,
                    splashFactory: NoSplash.splashFactory,
                    tabs: const [
                      Tab(text: "简介"),
                      Tab(text: "评论"),
                    ],
                    onTap: (value) {
                      if (value == currentTabIndex) {
                        switch (value) {
                          case 0:
                            Get.find<IntroductionController>(tag: widget.bvid)
                                .scrollController
                                .animateTo(0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.linear);
                            break;
                          case 1:
                            Get.find<ReplyController>(tag: widget.bvid)
                                .scrollController
                                .animateTo(0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.linear);
                            break;
                        }
                      } else {
                        setState(() => currentTabIndex = value);
                      }
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controller.tabController,
                      children: [
                        IntroductionPage(
                          changePartCallback: controller.changeVideoPart,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}