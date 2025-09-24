import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 临时 VideoAudioState，用于兼容 UI
/// 注意：所有状态都是占位，不会随实际播放变化
class VideoAudioState {
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  bool isEnd = false;
  bool isBuffering = false;
  bool hasError = false;
  double width = 1920;
  double height = 1080;
  double speed = 1.0;
  List<Duration> buffered = [];
}

/// 临时 VideoAudioController，空实现
/// 注意：播放、暂停、seek、刷新、速度设置等都不会生效
class VideoAudioController {
  String? videoUrl;
  String? audioUrl;
  VideoAudioState state = VideoAudioState();

  Future<void> play() async {} // 占位，不播放
  Future<void> pause() async {} // 占位，不暂停
  Future<void> seekTo(Duration position) async {} // 占位，不跳转
  Future<void> refresh() async {} // 占位，不刷新
  Future<void> setPlayBackSpeed(double speed) async {} // 占位，不改变速度
  Future<void> dispose() async {} // 占位，不释放资源
  Future<void> init() async {} // 占位，不初始化

  void addListener(Function() listener) {} // 占位
  void removeListener(Function() listener) {} // 占位
  void addStateChangedListener(Function(VideoAudioState state) listener) {} // 占位
  void removeStateChangedListener(Function(VideoAudioState state) listener) {} // 占位
  void addSeekToListener(Function(Duration position) listener) {} // 占位
  void removeSeekToListener(Function(Duration position) listener) {} // 占位
}

/// 临时 PlayersSingleton 空实现
/// 注意：用于兼容旧代码，player 不会真正播放
class PlayersSingleton {
  static final PlayersSingleton _instance = PlayersSingleton._internal();
  factory PlayersSingleton() => _instance;
  PlayersSingleton._internal();

  int count = 0;
  dynamic player;

  Future<void> init() async {} // 占位
  Future<void> dispose() async {} // 占位
}

/// 视频播放器 Widget（UI 占位）
class VideoAudioPlayer extends StatefulWidget {
  const VideoAudioPlayer(this.controller,
      {super.key, this.width, this.height, this.asepectRatio, this.fit = BoxFit.contain});
  final VideoAudioController controller;
  final double? width;
  final double? height;
  final double? asepectRatio;
  final BoxFit fit;

  @override
  State<VideoAudioPlayer> createState() => _VideoAudioPlayerState();
}

class _VideoAudioPlayerState extends State<VideoAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    // 占位 UI
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
    );
  }
}
