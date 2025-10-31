import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/player/player_controller.dart';

/// 播放器控制面板
class PlayerControlPanel extends StatefulWidget {
  final PlayerController controller;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onClose;
  final VoidCallback? onToggleDanmaku;
  final bool isDanmakuEnabled;
  final VoidCallback? onShowQualitySelector;
  final VoidCallback? onShowSpeedSelector;
  final VoidCallback? onShowMoreOptions;

  const PlayerControlPanel({
    super.key,
    required this.controller,
    this.onToggleFullscreen,
    this.onClose,
    this.onToggleDanmaku,
    this.isDanmakuEnabled = false,
    this.onShowQualitySelector,
    this.onShowSpeedSelector,
    this.onShowMoreOptions,
  });

  @override
  State<PlayerControlPanel> createState() => _PlayerControlPanelState();
}

class _PlayerControlPanelState extends State<PlayerControlPanel> {
  bool _isControlsVisible = true;
  bool _isSeeking = false;
  double _seekPosition = 0.0;
  double _volume = 1.0;
  double _brightness = 0.5;
  bool _isLongPressing = false;
  double _originalSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _volume = widget.controller.state.volume;
  }

  void _togglePlayPause() {
    if (widget.controller.state.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  void _onSeekStart(double position) {
    setState(() {
      _isSeeking = true;
      _seekPosition = position;
    });
  }

  void _onSeekUpdate(double position) {
    setState(() {
      _seekPosition = position;
    });
  }

  void _onSeekEnd(double position) {
    final duration = widget.controller.state.duration.inMilliseconds;
    final seekPosition = Duration(milliseconds: (position * duration).toInt());
    widget.controller.seekTo(seekPosition);
    
    setState(() {
      _isSeeking = false;
      _seekPosition = position;
    });
  }

  void _onDoubleTapLeft() {
    // 左侧双击，通常是后退
    final currentPosition = widget.controller.state.position.inMilliseconds;
    final newPosition = Duration(milliseconds: (currentPosition - 10000).clamp(0, double.infinity).toInt());
    widget.controller.seekTo(newPosition);
  }

  void _onDoubleTapRight() {
    // 右侧双击，通常是快进
    final currentPosition = widget.controller.state.position.inMilliseconds;
    final duration = widget.controller.state.duration.inMilliseconds;
    final newPosition = Duration(milliseconds: (currentPosition + 10000).clamp(0, duration.toDouble()).toInt());
    widget.controller.seekTo(newPosition);
  }

  void _onLongPressStart() {
    setState(() {
      _isLongPressing = true;
      _originalSpeed = widget.controller.state.speed;
    });
    // 设置2倍速播放
    widget.controller.setPlaybackSpeed(_originalSpeed * 2);
  }

  void _onLongPressEnd() {
    setState(() {
      _isLongPressing = false;
    });
    // 恢复原来的速度
    widget.controller.setPlaybackSpeed(_originalSpeed);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.controller.state.position;
    final duration = widget.controller.state.duration;
    final progress = duration.inMilliseconds == 0 
        ? 0.0 
        : position.inMilliseconds / duration.inMilliseconds;

    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTap: _togglePlayPause,
      onLongPressStart: (_) => _onLongPressStart(),
      onLongPressEnd: (_) => _onLongPressEnd(),
      child: Stack(
        children: [
          // 手势识别层
          Positioned.fill(
            child: Row(
              children: [
                // 左侧区域（后退）
                Expanded(
                  child: GestureDetector(
                    onTap: _onDoubleTapLeft,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                // 中间区域（播放/暂停）
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                // 右侧区域（快进）
                Expanded(
                  child: GestureDetector(
                    onTap: _onDoubleTapRight,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 控制面板
          AnimatedOpacity(
            opacity: _isControlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
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
                  _buildTopControls(),
                  
                  // 中间播放按钮
                  const Spacer(),
                  _buildCenterControls(),
                  const Spacer(),
                  
                  // 底部进度条和控制
                  _buildBottomControls(progress, position, duration),
                ],
              ),
            ),
          ),
          
          // 长按速度指示器
          if (_isLongPressing)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fast_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_originalSpeed * 2).toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // 关闭按钮
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onClose,
            ),
          
          const Spacer(),
          
          // 弹幕开关
          if (widget.onToggleDanmaku != null)
            IconButton(
              icon: Icon(
                widget.isDanmakuEnabled ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: widget.onToggleDanmaku,
            ),
          
          // 画质选择
          if (widget.onShowQualitySelector != null)
            TextButton(
              onPressed: widget.onShowQualitySelector,
              child: const Text(
                '1080P',
                style: TextStyle(color: Colors.white),
              ),
            ),
          
          // 播放速度
          TextButton(
            onPressed: widget.onShowSpeedSelector,
            child: Text(
              '${widget.controller.state.speed.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          
          // 更多选项
          if (widget.onShowMoreOptions != null)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: widget.onShowMoreOptions,
            ),
          
          // 全屏按钮
          if (widget.onToggleFullscreen != null)
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: widget.onToggleFullscreen,
            ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Center(
      child: IconButton(
        icon: Icon(
          widget.controller.state.isPlaying 
              ? Icons.pause_circle_filled 
              : Icons.play_circle_filled,
          size: 60,
          color: Colors.white,
        ),
        onPressed: _togglePlayPause,
      ),
    );
  }

  Widget _buildBottomControls(double progress, Duration position, Duration duration) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // 进度条
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.red,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.red,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackHeight: 3,
            ),
            child: Slider(
              value: _isSeeking ? _seekPosition : progress,
              onChanged: _onSeekUpdate,
              onChangeStart: _onSeekStart,
              onChangeEnd: _onSeekEnd,
            ),
          ),
          
          // 时间和控制按钮
          Row(
            children: [
              // 当前时间
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              
              const Spacer(),
              
              // 播放/暂停按钮
              IconButton(
                icon: Icon(
                  widget.controller.state.isPlaying 
                      ? Icons.pause 
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _togglePlayPause,
              ),
              
              const Spacer(),
              
              // 总时间
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}