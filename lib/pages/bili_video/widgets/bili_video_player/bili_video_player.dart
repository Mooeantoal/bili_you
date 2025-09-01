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
  // ... 现有代码 ...
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  late final VideoController _controller;
  late final BiliVideoPlayerCubit _cubit;
  Timer? _positionUpdateTimer;
  bool _wasPlayingBeforeDrag = false; // 记录拖动前的播放状态

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

    // 监听播放器状态变化
    _controller.player.stream.listen((event) {
      // 更新播放状态
      _cubit.updatePlayingState(event.isPlaying);
      
      // 更新视频时长
      if (event.duration != null) {
        _cubit.updateDuration(event.duration!);
      }
    });

    if (widget.autoPlay) {
      _controller.player.play();
    }

    // 启动位置更新定时器
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final currentState = _cubit.state;
      // 只在非拖动状态且正在播放时更新位置
      if (!currentState.isDragging && _controller.player.value.isPlaying) {
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

  // 处理进度条拖动开始
  void _onDragStart() {
    _wasPlayingBeforeDrag = _controller.player.value.isPlaying;
    if (_wasPlayingBeforeDrag) {
      _controller.player.pause();
    }
    _cubit.startDragging();
  }

  // 处理进度条拖动
  void _onDrag(double value) {
    final position = Duration(milliseconds: value.toInt());
    _cubit.updateDragPosition(position);
  }

  // 处理进度条拖动结束
  void _onDragEnd(double value) {
    final position = Duration(milliseconds: value.toInt());
    _controller.player.seek(position);
    _cubit.endDragging(position);
    
    if (_wasPlayingBeforeDrag) {
      _controller.player.play();
    }
  }

  // 处理播放/暂停
  void _togglePlayPause() {
    if (_controller.player.value.isPlaying) {
      _controller.player.pause();
    } else {
      _controller.player.play();
    }
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
                    controls: (state) => const SizedBox(), // 禁用默认控件
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
    // ... 保持不变 ...
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
          // 自定义进度条
          Slider(
            value: state.isDragging
                ? state.dragPosition.inMilliseconds.toDouble()
                : state.position.inMilliseconds.toDouble(),
            min: 0.0,
            max: state.duration.inMilliseconds.toDouble(),
            onChanged: _onDrag,
            onChangeStart: (_) => _onDragStart(),
            onChangeEnd: _onDragEnd,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
          ),
          const SizedBox(height: 8),
          // 控制按钮
          Row(
            children: [
              IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 8),
              Text(
                '${formatDuration(state.isDragging ? state.dragPosition : state.position)} / ${formatDuration(state.duration)}',
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
