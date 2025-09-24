import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 临时 VideoAudioState，用于兼容 UI
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
class VideoAudioController {
  String? videoUrl;
  String? audioUrl;
  VideoAudioState state = VideoAudioState();

  Future<void> play() async {}
  Future<void> pause() async {}
  Future<void> seekTo(Duration position) async {}
  Future<void> refresh() async {}
  Future<void> setPlayBackSpeed(double speed) async {}
  Future<void> dispose() async {}
  Future<void> init() async {}

  void addListener(Function() listener) {}
  void removeListener(Function() listener) {}
  void addStateChangedListener(Function(VideoAudioState state) listener) {}
  void removeStateChangedListener(Function(VideoAudioState state) listener) {}
  void addSeekToListener(Function(Duration position) listener) {}
  void removeSeekToListener(Function(Duration position) listener) {}
}

/// 临时 PlayersSingleton 空实现
class PlayersSingleton {
  static final PlayersSingleton _instance = PlayersSingleton._internal();
  factory PlayersSingleton() => _instance;
  PlayersSingleton._internal();

  int count = 0;
  dynamic player;

  Future<void> init() async {}
  Future<void> dispose() async {}
}

/// 视频播放器 Widget
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
    // 临时 UI 占位
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
    );
  }
}
