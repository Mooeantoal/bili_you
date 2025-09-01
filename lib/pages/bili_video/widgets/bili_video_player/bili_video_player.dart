import 'dart:async';
import 'dart:developer';

import 'package:biliyou/common/api/videoplayapi.dart';
import 'package:biliyou/common/models/local/video/audioplayitem.dart';
import 'package:biliyou/common/models/local/video/videoplayitem.dart';
import 'package:biliyou/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayerstate.dart';
import 'package:biliyou/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayerpanel.dart';
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
      videoPlayItem: widget.videoPlayItem,
      audioPlayItem: widget.audioPlayItem,
      autoPlay: widget.autoPlay,
      showDanmaku: widget.showDanmaku,
      danmakuFontSize: widget.danmakuFontSize,
      danmakuOpacity: widget.danmakuOpacity,
      danmakuShowArea: widget.danmakuShowArea,
      fit: widget.fit,
      aspectRatio: widget.aspectRatio,
      quality: widget.quality,
    );
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
                // 弹幕组件
                Container(),
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

class BiliVideoPlayerCubit extends Cubit<BiliVideoPlayerState> {
  BiliVideoPlayerCubit({
    required VideoPlayItem videoPlayItem,
    AudioPlayItem? audioPlayItem,
    bool autoPlay = true,
    bool showDanmaku = true,
    double danmakuFontSize = 16,
    double danmakuOpacity = 1,
    double danmakuShowArea = 1,
    BoxFit fit = BoxFit.contain,
    double aspectRatio = 16 / 9,
    VideoQuality quality = VideoQuality.auto,
  }) : super(BiliVideoPlayerState(
          videoPlayItem: videoPlayItem,
          audioPlayItem: audioPlayItem,
          showDanmaku: showDanmaku,
          danmakuFontSize: danmakuFontSize,
          danmakuOpacity: danmakuOpacity,
          danmakuShowArea: danmakuShowArea,
          fit: fit,
          aspectRatio: aspectRatio,
          quality: quality,
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    final videoController = VideoController(
      VideoPlayerController.networkUrl(
        Uri.parse(state.videoPlayItem.urls[state.quality]!),
      ),
    );
    await videoController.initialize();
    if (state.autoPlay) {
      videoController.play();
    }

    // 监听播放状态
    videoController.position.listen((position) {
      if (!state.isDragging) {
        emit(state.copyWith(position: position));
      }
    });

    // 监听缓冲状态
    videoController.buffered.listen((buffered) {
      emit(state.copyWith(bufferedPosition: buffered));
    });

    // 监听播放完成
    videoController.completed.listen((_) {
      emit(state.copyWith(isPlaying: false));
    });

    emit(state.copyWith(
      videoController: videoController,
      isInitialized: true,
      isPlaying: state.autoPlay,
      duration: videoController.value.duration,
    ));
  }

  void togglePlayPause() {
    if (state.videoController == null) return;
    if (state.isPlaying) {
      state.videoController!.pause();
    } else {
      state.videoController!.play();
    }
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  void startDragging() {
    emit(state.copyWith(isDragging: true));
  }

  void updateDragPosition(Duration position) {
    emit(state.copyWith(dragPosition: position));
  }

  void endDragging() {
    if (state.videoController == null) return;
    state.videoController!.seekTo(state.dragPosition);
    emit(state.copyWith(
      isDragging: false,
      position: state.dragPosition,
    ));
  }

  void setPlaybackSpeed(double speed) {
    if (state.videoController == null) return;
    state.videoController!.setPlaybackSpeed(speed);
  }

  void setVolume(double volume) {
    if (state.videoController == null) return;
    state.videoController!.setVolume(volume);
  }

  void setBrightness(double brightness) {
    // 设置屏幕亮度，需要平台特定实现
  }

  void setQuality(VideoQuality quality) {
    // 切换画质，需要重新初始化播放器
  }

  void setShowDanmaku(bool show) {
    emit(state.copyWith(showDanmaku: show));
  }

  void setDanmakuFontSize(double size) {
    emit(state.copyWith(danmakuFontSize: size));
  }

  void setDanmakuOpacity(double opacity) {
    emit(state.copyWith(danmakuOpacity: opacity));
  }

  void setDanmakuShowArea(double area) {
    emit(state.copyWith(danmakuShowArea: area));
  }
}
