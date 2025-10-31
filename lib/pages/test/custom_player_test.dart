import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/player/player_widget.dart';
import 'package:bili_you/common/widget/player/player_controller.dart';
import 'package:bili_you/common/widget/player/player_control_panel.dart';
import 'package:bili_you/common/widget/player/player_settings_dialog.dart';
import 'package:bili_you/common/widget/player/playlist_widget.dart';
import 'package:bili_you/common/widget/player/player_manager.dart';

class CustomPlayerTestPage extends StatefulWidget {
  const CustomPlayerTestPage({Key? key}) : super(key: key);

  @override
  State<CustomPlayerTestPage> createState() => _CustomPlayerTestPageState();
}

class _CustomPlayerTestPageState extends State<CustomPlayerTestPage> {
  late PlayerController _playerController;
  final String testVideoUrl = 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
  bool _isDanmakuEnabled = false;
  bool _isFullscreen = false;
  int _currentPlaylistIndex = 0;

  // 播放列表数据
  final List<PlaylistItem> _playlistItems = [
    PlaylistItem(
      title: 'Big Buck Bunny',
      url: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      thumbnailUrl: 'https://sample-videos.com/img/sample-png-1.png',
      duration: const Duration(minutes: 1),
    ),
    PlaylistItem(
      title: 'Elephants Dream',
      url: 'https://sample-videos.com/video123/mp4/720/elephants-dream-720p_1mb.mp4',
      thumbnailUrl: 'https://sample-videos.com/img/sample-png-2.png',
      duration: const Duration(minutes: 1),
    ),
    PlaylistItem(
      title: 'For Bigger Blazes',
      url: 'https://sample-videos.com/video123/mp4/720/for-bigger-blazes-720p_1mb.mp4',
      thumbnailUrl: 'https://sample-videos.com/img/sample-png-3.png',
      duration: const Duration(minutes: 1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _playerController = PlayerManager().createPlayer('test_player')!;
    _playerController.setMediaSource(testVideoUrl);
  }

  @override
  void dispose() {
    PlayerManager().disposePlayer('test_player');
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return PlayerSettingsDialog(
          controller: _playerController,
          availableQualities: ['1080P', '720P', '480P', '360P'],
          currentQuality: '720P',
          onQualityChanged: (quality) {
            // 这里应该实现画质切换逻辑
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('切换到 $quality'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onSpeedChanged: (speed) {
            _playerController.setPlaybackSpeed(speed);
          },
          onVolumeChanged: (volume) {
            _playerController.setVolume(volume);
          },
          onToggleDanmaku: () {
            setState(() {
              _isDanmakuEnabled = !_isDanmakuEnabled;
            });
          },
          isDanmakuEnabled: _isDanmakuEnabled,
        );
      },
    );
  }

  void _onPlaylistItemSelected(int index) {
    setState(() {
      _currentPlaylistIndex = index;
      _playerController.setMediaSource(_playlistItems[index].url);
      _playerController.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义播放器测试'),
      ),
      body: Column(
        children: [
          // 视频信息
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '自定义播放器测试',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('测试视频URL:'),
                Text(
                  testVideoUrl,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // 分割线
          const Divider(),
          
          // 播放器区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 播放器
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        PlayerWidget(
                          controller: _playerController,
                          aspectRatio: 16 / 9,
                        ),
                        // 播放器控制面板
                        PlayerControlPanel(
                          controller: _playerController,
                          onToggleFullscreen: _toggleFullscreen,
                          onToggleDanmaku: () {
                            setState(() {
                              _isDanmakuEnabled = !_isDanmakuEnabled;
                            });
                          },
                          isDanmakuEnabled: _isDanmakuEnabled,
                          onShowQualitySelector: () {
                            // 显示画质选择
                            _showQualitySelector();
                          },
                          onShowSpeedSelector: () {
                            // 显示速度选择
                            _showSpeedSelector();
                          },
                          onShowMoreOptions: _showSettingsDialog,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 播放列表
                  Expanded(
                    flex: 1,
                    child: PlaylistWidget(
                      items: _playlistItems,
                      currentIndex: _currentPlaylistIndex,
                      onItemSelected: _onPlaylistItemSelected,
                      controller: _playerController,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQualitySelector() {
    final qualities = ['1080P', '720P', '480P', '360P'];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: qualities.map((quality) {
            return ListTile(
              title: Text(quality),
              onTap: () {
                Navigator.of(context).pop();
                // 这里应该实现画质切换逻辑
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('切换到 $quality'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: speeds.map((speed) {
            return ListTile(
              title: Text('${speed}x'),
              onTap: () {
                Navigator.of(context).pop();
                _playerController.setPlaybackSpeed(speed);
              },
            );
          }).toList(),
        );
      },
    );
  }
}