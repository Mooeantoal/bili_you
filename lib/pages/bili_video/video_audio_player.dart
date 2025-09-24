import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// 视频音频控制器
class VideoAudioController {
  final VideoPlayerController _videoController;
  bool _isInitialized = false;

  VideoAudioController(String videoUrl)
      : _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl)) {
    _initialize();
  }

  // 初始化播放器
  Future<void> _initialize() async {
    await _videoController.initialize();
    _isInitialized = true;
  }

  // 播放控制方法
  void play() => _videoController.play();
  void pause() => _videoController.pause();
  void dispose() => _videoController.dispose();

  // 获取播放状态
  bool get isInitialized => _isInitialized;
  VideoPlayerValue get value => _videoController.value;
}

// 视频播放器组件
class VideoAudioPlayer extends StatelessWidget {
  final VideoAudioController controller;

  const VideoAudioPlayer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return controller.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller._videoController),
          )
        : const Center(child: CircularProgressIndicator());
  }
}