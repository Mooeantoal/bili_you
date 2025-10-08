import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/utils/num_utils.dart';

class PiliPlusIntroPanel extends StatefulWidget {
  final String bvid;
  final int cid;

  const PiliPlusIntroPanel({
    Key? key,
    required this.bvid,
    required this.cid,
  }) : super(key: key);

  @override
  State<PiliPlusIntroPanel> createState() => _PiliPlusIntroPanelState();
}

class _PiliPlusIntroPanelState extends State<PiliPlusIntroPanel> {
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
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: widget.bvid);
      setState(() {
        _videoInfo = videoInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty || _videoInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_errorMessage'),
            ElevatedButton(
              onPressed: _loadVideoInfo,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
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
            const SizedBox(height: 12),
            
            // 视频数据统计
            _buildVideoStats(),
            const SizedBox(height: 16),
            
            // UP主信息
            _buildUploaderInfo(),
            const SizedBox(height: 16),
            
            // 视频描述
            _buildVideoDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Icons.visibility, NumUtils.numFormat(_videoInfo!.playNum)),
        _buildStatItem(Icons.thumb_up_alt_outlined, NumUtils.numFormat(_videoInfo!.likeNum)),
        _buildStatItem(Icons.chat_bubble_outline, NumUtils.numFormat(_videoInfo!.danmaukuNum)),
        _buildStatItem(Icons.monetization_on_outlined, NumUtils.numFormat(_videoInfo!.coinNum)),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildUploaderInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(_videoInfo!.ownerFace),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _videoInfo!.ownerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UP主',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // 关注功能
            },
            child: const Text('关注'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDescription() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '视频简介',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _videoInfo!.describe,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}