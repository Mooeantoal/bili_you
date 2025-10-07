import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:flutter/material.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage(
      {super.key,
      required this.bvid,
      required this.cid,
      this.ssid,
      this.isBangumi = false});

  final String bvid;
  final int cid;
  final int? ssid;
  final bool isBangumi;

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  VideoInfo? _videoInfo;
  bool _isLoading = true;
  String _errorMessage = '';

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_videoInfo == null) {
      return const Center(child: Text('无法获取视频信息'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频标题
            Text(
              _videoInfo!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 视频描述
            Text(
              _videoInfo!.describe,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // 视频统计信息
            Row(
              children: [
                Icon(Icons.visibility, size: 16),
                const SizedBox(width: 4),
                Text('${_videoInfo!.playNum}'),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16),
                const SizedBox(width: 4),
                Text('${_videoInfo!.danmaukuNum}'),
                const SizedBox(width: 16),
                Icon(Icons.thumb_up_alt_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${_videoInfo!.likeNum}'),
              ],
            ),
            const SizedBox(height: 16),
            
            // UP主信息
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_videoInfo!.ownerFace),
                ),
                const SizedBox(width: 8),
                Text(_videoInfo!.ownerName),
              ],
            ),
            const SizedBox(height: 16),
            
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
                    title: Text(part.title),
                    onTap: () {
                      // 切换到对应的分P
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}