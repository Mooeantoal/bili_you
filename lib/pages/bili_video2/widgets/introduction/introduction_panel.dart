import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/utils/num_utils.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';

class VideoIntroPanel extends StatefulWidget {
  final String bvid;
  final int cid;

  const VideoIntroPanel({
    Key? key,
    required this.bvid,
    required this.cid,
  }) : super(key: key);

  @override
  State<VideoIntroPanel> createState() => _VideoIntroPanelState();
}

class _VideoIntroPanelState extends State<VideoIntroPanel> {
  VideoInfo? _videoInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadVideoInfo();
  }

  Future<void> _loadVideoInfo() async {
    try {
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: widget.bvid);
      setState(() {
        _videoInfo = videoInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载视频信息失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _videoInfo == null
                  ? const Center(child: Text('无法获取视频信息'))
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _videoInfo!.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                _isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isExpanded)
                            _buildExpandedContent(theme)
                          else
                            _buildCollapsedContent(theme),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildCollapsedContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UP主信息
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(_videoInfo!.ownerFace),
            ),
            const SizedBox(width: 8),
            Text(_videoInfo!.ownerName),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                // 关注功能
              },
              child: const Text('关注'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 视频统计信息
        Row(
          children: [
            Icon(Icons.visibility, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.playNum)),
            const SizedBox(width: 16),
            Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.danmaukuNum)),
            const SizedBox(width: 16),
            Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.likeNum)),
          ],
        ),
        const SizedBox(height: 8),
        // 视频描述（截断显示）
        Text(
          _videoInfo!.describe,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UP主信息
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(_videoInfo!.ownerFace),
            ),
            const SizedBox(width: 8),
            Text(
              _videoInfo!.ownerName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                // 关注功能
              },
              child: const Text('关注'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 视频统计信息
        Row(
          children: [
            Icon(Icons.visibility, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.playNum)),
            const SizedBox(width: 16),
            Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.danmaukuNum)),
            const SizedBox(width: 16),
            Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.likeNum)),
            const SizedBox(width: 16),
            Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.coinNum)),
            const SizedBox(width: 16),
            Icon(Icons.star_border, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(NumUtils.numFormat(_videoInfo!.favariteNum)),
          ],
        ),
        const SizedBox(height: 12),
        // 视频描述（完整显示）
        Text(
          _videoInfo!.describe,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        // 分P信息
        if (_videoInfo!.parts.isNotEmpty) ...[
          const Text(
            '分P列表',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _videoInfo!.parts.length,
            itemBuilder: (context, index) {
              final part = _videoInfo!.parts[index];
              return ListTile(
                title: Text('${index + 1}. ${part.title}'),
                onTap: () {
                  // 切换分P
                  Get.snackbar('提示', '切换到分P: ${part.title}');
                },
              );
            },
          ),
        ],
      ],
    );
  }
}