import 'package:bili_you/common/widget/player/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 通用播放器UI组件
class PlayerWidget extends StatefulWidget {
  final PlayerController controller;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BoxFit fit;

  const PlayerWidget({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.contain,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 检查是否有可用的VideoController
          if (widget.controller.videoController != null) {
            return Video(
              controller: widget.controller.videoController!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              aspectRatio: widget.aspectRatio,
            );
          }
          
          return const Center(
            child: Text('无法初始化播放器'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}