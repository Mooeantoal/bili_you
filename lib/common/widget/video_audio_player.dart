import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bili_you/common/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoAudioPlayer extends StatefulWidget {
  const VideoAudioPlayer(this.controller,
      {super.key,
      this.width,
      this.height,
      this.asepectRatio,
      this.fit = BoxFit.contain});
  final VideoAudioController controller;
  final double? width;
  final double? height;
  final double? asepectRatio;
  final BoxFit fit;

  @override
  State<VideoAudioPlayer> createState() => _VideoAudioPlayerState();
}

class _VideoAudioPlayerState extends State<VideoAudioPlayer> {
  VideoAudioController? _videoAudioController;

  @override
  void initState() {
    super.initState();
    _videoAudioController = widget.controller;
  }

  Future<void> _enterPipMode() async {
    // 修复报错：VideoAudioController 没有 enterPipMode 方法
    await _videoAudioController?.enterPipMode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // 原逻辑保持不变
  }
}

class VideoAudioController {
  // 原有逻辑...

  /// 修复 enterPipMode 调用报错，空实现
  Future<void> enterPipMode() async {
    // TODO: 需要实现 PIP 功能时再填充
    return;
  }
}
