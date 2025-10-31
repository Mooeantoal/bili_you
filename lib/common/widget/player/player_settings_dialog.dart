import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/player/player_controller.dart';

/// 播放器设置对话框
class PlayerSettingsDialog extends StatefulWidget {
  final PlayerController controller;
  final List<String> availableQualities;
  final String currentQuality;
  final Function(String) onQualityChanged;
  final Function(double) onSpeedChanged;
  final Function(double) onVolumeChanged;
  final VoidCallback onToggleDanmaku;
  final bool isDanmakuEnabled;

  const PlayerSettingsDialog({
    super.key,
    required this.controller,
    required this.availableQualities,
    required this.currentQuality,
    required this.onQualityChanged,
    required this.onSpeedChanged,
    required this.onVolumeChanged,
    required this.onToggleDanmaku,
    required this.isDanmakuEnabled,
  });

  @override
  State<PlayerSettingsDialog> createState() => _PlayerSettingsDialogState();
}

class _PlayerSettingsDialogState extends State<PlayerSettingsDialog> {
  late double _speed;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _speed = widget.controller.state.speed;
    _volume = widget.controller.state.volume;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('播放器设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 画质选择
            const Text(
              '画质',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableQualities.map((quality) {
                return ChoiceChip(
                  label: Text(quality),
                  selected: quality == widget.currentQuality,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onQualityChanged(quality);
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 播放速度
            const Text(
              '播放速度',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSpeedSelector(),
            
            const SizedBox(height: 16),
            
            // 音量控制
            const Text(
              '音量',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildVolumeControl(),
            
            const SizedBox(height: 16),
            
            // 弹幕设置
            const Text(
              '弹幕',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('显示弹幕'),
              value: widget.isDanmakuEnabled,
              onChanged: (value) {
                widget.onToggleDanmaku();
              },
            ),
            
            const SizedBox(height: 16),
            
            // 其他设置
            const Text(
              '其他',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('定时关闭'),
              trailing: const Icon(Icons.timer),
              onTap: () {
                _showSleepTimerDialog(context);
              },
            ),
            ListTile(
              title: const Text('画面比例'),
              trailing: const Icon(Icons.aspect_ratio),
              onTap: () {
                _showAspectRatioDialog(context);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    return Column(
      children: speeds.map((speed) {
        return RadioListTile<double>(
          title: Text('${speed}x'),
          value: speed,
          groupValue: _speed,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _speed = value;
              });
              widget.onSpeedChanged(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildVolumeControl() {
    return Column(
      children: [
        Slider(
          value: _volume,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          label: '${(_volume * 100).toInt()}%',
          onChanged: (value) {
            setState(() {
              _volume = value;
            });
            widget.onVolumeChanged(value);
            widget.controller.setVolume(value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.volume_down),
              onPressed: () {
                final newVolume = (_volume - 0.1).clamp(0.0, 1.0);
                setState(() {
                  _volume = newVolume;
                });
                widget.onVolumeChanged(newVolume);
                widget.controller.setVolume(newVolume);
              },
            ),
            Text('${(_volume * 100).toInt()}%'),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {
                final newVolume = (_volume + 0.1).clamp(0.0, 1.0);
                setState(() {
                  _volume = newVolume;
                });
                widget.onVolumeChanged(newVolume);
                widget.controller.setVolume(newVolume);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final times = [5, 10, 15, 30, 60];
        return AlertDialog(
          title: const Text('定时关闭'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: times.map((minutes) {
              return ListTile(
                title: Text('$minutes 分钟后关闭'),
                onTap: () {
                  Navigator.of(context).pop();
                  // 这里应该实现定时关闭逻辑
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已设置 $minutes 分钟后关闭'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAspectRatioDialog(BuildContext context) {
    final ratios = ['默认', '16:9', '4:3', '1:1'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('画面比例'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ratios.map((ratio) {
              return ListTile(
                title: Text(ratio),
                onTap: () {
                  Navigator.of(context).pop();
                  // 这里应该实现画面比例调整逻辑
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已设置画面比例为 $ratio'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}