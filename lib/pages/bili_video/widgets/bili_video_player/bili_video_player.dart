import 'dart:async';
import 'dart:developer';

import 'package:biliyou/common/api/videoplayapi.dart';
import 'package:biliyou/common/models/local/video/audioplayitem.dart';
import 'package:biliyou/common/models/local/video/videoplayinfo.dart';
import 'package:biliyou/common/models/local/video/videoplayitem.dart';
import 'package:biliyou/common/utils/index.dart';
import 'package:biliyou/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayer_cubit.dart';
import 'package:biliyou/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediakit/mediakit.dart';
import 'package:mediakit_video/mediakit_video.dart';

class BiliVideoPlayer extends StatefulWidget {
  final VideoPlayInfo videoPlayInfo;
  final VideoPlayItem videoPlayItem;
  final AudioPlayItem? audioPlayItem;
  final String? cid;
  final bool autoPlay;

  const BiliVideoPlayer({
    super.key,
    required this.videoPlayInfo,
    required this.videoPlayItem,
    this.audioPlayItem,
    this.cid,
    this.autoPlay = true,
  });

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  late final VideoController _controller;
  late final BiliVideoPlayerCubit _cubit;
  Timer? _positionUpdateTimer;

  @override
  void initState() {
    super.initState();
    _cubit = BiliVideoPlayerCubit(
      videoPlayInfo: widget.videoPlayInfo,
      videoPlayItem: widget.videoPlayItem,
      audioPlayItem: widget.audioPlayItem,
    );

    // 初始化mediakit控制器
    _controller = VideoController(
      VideoSource.uri(
        Uri.parse(widget.videoPlayItem.url),
        type: VideoType.network,
      ),
    );

    if (widget.autoPlay) {
      _controller.player.play();
    }

    // 启动位置更新定时器
    _positionUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller.player.value.isPlaying) {
        _cubit.updatePosition(_controller.player.value.position);
      }
    });
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<BiliVideoPlayerCubit, BiliVideoPlayerState>(
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                // 视频播放器
                Positioned.fill(
                  child: Video(
                    controller: _controller,
                    fit: state.fit,
                    aspectRatio: state.aspectRatio,
                    controls: (state) => AdaptiveVideoControls(state),
                  ),
                ),
                
                // 弹幕层
                if (state.showDanmaku)
                  Positioned.fill(
                    child: DanmakuView(
                      cid: widget.cid,
                      fontSize: state.danmakuFontSize,
                      opacity: state.danmakuOpacity,
                      showArea: state.danmakuShowArea,
                    ),
                  ),
                
                // 顶部控制栏
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopControls(context, state),
                ),
                
                // 底部控制栏
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControls(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopControls(BuildContext context, BiliVideoPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              state.showDanmaku ? Icons.comment : Icons.comment_outlined,
              color: Colors.white,
            ),
            onPressed: () => _cubit.toggleDanmaku(),
          ),
          PopupMenuButton<VideoFit>(
            icon: const Icon(Icons.aspect_ratio, color: Colors.white),
            onSelected: (fit) => _cubit.updateFit(fit),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: VideoFit.contain,
                child: Text('适应'),
              ),
              const PopupMenuItem(
                value: VideoFit.cover,
                child: Text('填充'),
              ),
              const PopupMenuItem(
                value: VideoFit.fill,
                child: Text('拉伸'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, BiliVideoPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          VideoProgressBar(
            controller: _controller,
            bufferedColor: Colors.white.withOpacity(0.3),
            playedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          // 控制按钮
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _controller.player.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_controller.player.value.isPlaying) {
                    _controller.player.pause();
                  } else {
                    _controller.player.play();
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                '${formatDuration(_controller.player.value.position)} / ${formatDuration(_controller.player.value.duration)}',
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              // 清晰度选择
              PopupMenuButton<VideoPlayItem>(
                icon: const Icon(Icons.high_quality, color: Colors.white),
                onSelected: (item) => _cubit.changeQuality(item),
                itemBuilder: (context) => state.videoPlayInfo.qualityList
                    .map((item) => PopupMenuItem(
                          value: item,
                          child: Text(item.quality),
                        ))
                    .toList(),
              ),
              // 播放速度
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed, color: Colors.white),
                onSelected: (speed) => _controller.player.setPlaybackSpeed(speed),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  // 实现全屏逻辑
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
