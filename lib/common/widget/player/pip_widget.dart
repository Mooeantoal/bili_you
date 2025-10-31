import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/player/player_widget.dart';
import 'package:bili_you/common/widget/player/player_controller.dart';

/// 画中画组件
class PipWidget extends StatefulWidget {
  final PlayerController controller;
  final VoidCallback onExitPip;
  final VoidCallback onBackToFullScreen;

  const PipWidget({
    super.key,
    required this.controller,
    required this.onExitPip,
    required this.onBackToFullScreen,
  });

  @override
  State<PipWidget> createState() => _PipWidgetState();
}

class _PipWidgetState extends State<PipWidget> {
  bool _isControlsVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isControlsVisible = !_isControlsVisible;
        });
      },
      child: Stack(
        children: [
          // 视频播放器
          PlayerWidget(
            controller: widget.controller,
            fit: BoxFit.cover,
          ),
          
          // 控制面板
          if (_isControlsVisible)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // 顶部控制栏
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 退出画中画
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: widget.onExitPip,
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 底部控制栏
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 播放/暂停
                        IconButton(
                          icon: Icon(
                            widget.controller.state.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (widget.controller.state.isPlaying) {
                              widget.controller.pause();
                            } else {
                              widget.controller.play();
                            }
                          },
                        ),
                        
                        // 回到全屏
                        IconButton(
                          icon: const Icon(Icons.fullscreen, color: Colors.white),
                          onPressed: widget.onBackToFullScreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}