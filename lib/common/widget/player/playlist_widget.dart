import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/player/player_controller.dart';

/// 播放列表项数据模型
class PlaylistItem {
  final String title;
  final String url;
  final String thumbnailUrl;
  final Duration duration;

  PlaylistItem({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
  });
}

/// 播放列表组件
class PlaylistWidget extends StatefulWidget {
  final List<PlaylistItem> items;
  final int currentIndex;
  final Function(int) onItemSelected;
  final PlayerController controller;

  const PlaylistWidget({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    required this.controller,
  });

  @override
  State<PlaylistWidget> createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isExpanded ? 300 : 60,
      decoration: const BoxDecoration(
        color: Colors.black87,
      ),
      child: Column(
        children: [
          // 播放列表标题栏
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.playlist_play,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '播放列表',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.currentIndex + 1}/${widget.items.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          
          // 播放列表内容
          if (_isExpanded)
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.currentIndex;
                  
                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: Colors.white10,
                    onTap: () {
                      widget.onItemSelected(index);
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        item.thumbnailUrl,
                        width: 60,
                        height: 34,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDuration(item.duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.play_arrow,
                            color: Colors.red,
                            size: 20,
                          )
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}