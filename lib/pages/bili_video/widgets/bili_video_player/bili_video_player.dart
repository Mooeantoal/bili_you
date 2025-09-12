import 'dart:async';
import 'dart:developer';

import 'package:bili_you/common/api/videoplayapi.dart';
import 'package:bili_you/common/models/local/video/audioplayitem.dart';
import 'package:bili_you/common/models/local/video/videoplayitem.dart';
import 'package:bili_you/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayerstate.dart';
import 'package:bili_you/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayerpanel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediakit/mediakit.dart';

class BiliVideoPlayer extends StatefulWidget {
  final VideoPlayItem videoPlayItem;
  final AudioPlayItem? audioPlayItem;
  final bool autoPlay;
  final bool showDanmaku;
  final double danmakuFontSize;
  final double danmakuOpacity;
  final double danmakuShowArea;
  final BoxFit fit;
  final double aspectRatio;
  final VideoQuality quality;

  const BiliVideoPlayer({
    super.key,
    required this.videoPlayItem,
    this.audioPlayItem,
    this.autoPlay = true,
    this.showDanmaku = true,
    this.danmakuFontSize = 16,
    this.danmakuOpacity = 1,
    this.danmakuShowArea = 1,
    this.fit = BoxFit.contain,
    this.aspectRatio = 16 / 9,
    this.quality = VideoQuality.auto,
  });

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  late final BiliVideoPlayerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BiliVideoPlayerCubit(
      videoPlayInfo: VideoPlayInfo(), // 需要传入实际VideoPlayInfo
      videoPlayItem: widget.videoPlayItem,
      audioPlayItem: widget.audioPlayItem,
    );
    
    // 初始化控制器
    _cubit.initializeController();
    
    // 设置初始播放状态
    if (widget.autoPlay) {
      _cubit.togglePlayPause();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocBuilder<BiliVideoPlayerCubit, BiliVideoPlayerState>(
        builder: (context, state) {
          return Stack(
            children: [
              if (state.videoController != null)
                Video(
                  controller: state.videoController!,
                  fit: state.fit,
                ),
              if (state.showDanmaku && state.videoController != null)
                BiliDanmaku(
                  controller: BiliDanmakuController(state.videoController!),
                ),
              BiliVideoPlayerPanel(
                controller: state.videoController!,
                cubit: _cubit,
              ),
            ],
          );
        },
      ),
    );
  }
}
