import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/utils/device_ui_adapter.dart';
import 'package:bili_you/pages/bili_video2/widgets/introduction/introduction_page.dart';
import 'package:bili_you/pages/bili_video2/widgets/reply/reply_page.dart';
import 'package:bili_you/pages/bili_video2/bili_media.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiliMediaContentCubit extends Cubit<BiliMediaContent> {
  BiliMediaContentCubit(BiliMediaContent mediaContent) : super(mediaContent);
}

class BiliVideoPage2 extends StatelessWidget {
  const BiliVideoPage2({super.key, required this.media});

  final BiliMedia media;

  Widget _buildView(context, BiliMedia media) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            splashFactory: NoSplash.splashFactory,
            tabs: const [
              Tab(
                text: "简介",
              ),
              Tab(text: "评论")
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                IntroductionPage(
                  bvid: media.bvid,
                  cid: media.cid,
                  ssid: media.ssid,
                  isBangumi: media.isBangumi,
                ),
                ReplyPage(
                  replyId: media.bvid,
                  replyType: ReplyType.video,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        // 使用设备适配器获取导航栏样式
        value: DeviceUIAdapter.getOppoNavigationBarStyle(),
        child: Scaffold(
          // 添加extendBody属性以确保内容可以延伸到导航栏区域
          extendBody: true,
          body: Column(
            children: [
              Container(
                color: Colors.black,
                child: SafeArea(
                  left: false,
                  right: false,
                  bottom: false,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: FutureBuilder(
                      future: BiliMediaCubit(
                              bvid: media.bvid, cid: media.cid)
                          .getVideoPlayInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final mediaContent = snapshot.data!;
                            return FutureBuilder(
                              future: _selectValidUrls(mediaContent),
                              builder: (context, urlSnapshot) {
                                if (urlSnapshot.connectionState == ConnectionState.done) {
                                  final urls = urlSnapshot.data ?? {'video': null, 'audio': null};
                                  final videoUrl = urls['video'];
                                  final audioUrl = urls['audio'];
                                  
                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                          create: (_) =>
                                              BiliMediaContentCubit(mediaContent)),
                                      BlocProvider(
                                          create: (_) => BiliVideoPlayerCubit())
                                    ],
                                    child: BlocBuilder<BiliVideoPlayerCubit,
                                        BiliVideoPlayerState>(
                                      builder: (context, playerState) {
                                        // 如果有视频和音频URL，则开始播放
                                        if (videoUrl != null && audioUrl != null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            context
                                                .read<BiliVideoPlayerCubit>()
                                                .playMedia(videoUrl, audioUrl);
                                          });
                                        }
                                        return const BiliVideoPlayer();
                                      },
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                }
                              },
                            );
                          } else {
                            return const Center(
                                child: Text('无法获取视频播放信息'));
                          }
                        } else {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Colors.white,
                          ));
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildView(context, media))
            ],
          ),
        ));
  }

  // 添加URL选择方法
  Future<Map<String, String?>> _selectValidUrls(BiliMediaContent mediaContent) async {
    String? videoUrl;
    String? audioUrl;
    
    final cubit = BiliMediaCubit(bvid: '', cid: 0); // 临时创建用于URL测试
    
    // 选择视频URL
    if (mediaContent.videos.isNotEmpty) {
      final bestVideo = mediaContent.videos.first;
      if (bestVideo.urls.isNotEmpty) {
        videoUrl = await cubit.selectValidUrl(bestVideo.urls);
      }
    }

    // 选择音频URL
    if (mediaContent.audios.isNotEmpty) {
      final bestAudio = mediaContent.audios.first;
      if (bestAudio.urls.isNotEmpty) {
        audioUrl = await cubit.selectValidUrl(bestAudio.urls);
      }
    }
    
    return {'video': videoUrl, 'audio': audioUrl};
  }
}
