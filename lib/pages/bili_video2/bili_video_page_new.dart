import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:bili_you/pages/bili_video2/widgets/introduction/introduction_panel.dart';
import 'package:bili_you/pages/bili_video2/widgets/reply/reply_panel.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

class BiliVideoPageNew extends StatefulWidget {
  final String bvid;
  final int cid;

  const BiliVideoPageNew({
    Key? key,
    required this.bvid,
    required this.cid,
  }) : super(key: key);

  @override
  State<BiliVideoPageNew> createState() => _BiliVideoPageNewState();
}

class _BiliVideoPageNewState extends State<BiliVideoPageNew>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late VideoInfo _videoDetail;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVideoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVideoData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 获取视频详细信息
      _videoDetail = await VideoInfoApi.getVideoInfo(bvid: widget.bvid);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      Get.snackbar('错误', '加载视频信息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('加载失败: $_errorMessage'),
                      ElevatedButton(
                        onPressed: _loadVideoData,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 视频播放器
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 9 / 16,
                      child: BiliVideoPlayer(
                        bvid: widget.bvid,
                        cid: widget.cid,
                      ),
                    ),
                    // 标题和标签
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _videoDetail.title ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 视频信息
                          Row(
                            children: [
                              Text(
                                '${_videoDetail.playNum} 播放',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_videoDetail.danmaukuNum} 弹幕',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_videoDetail.likeNum} 点赞',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tab栏
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: '简介'),
                          Tab(text: '评论'),
                          Tab(text: '推荐'),
                        ],
                      ),
                    ),
                    // 内容区域
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 简介页面
                          VideoIntroPanel(
                            bvid: widget.bvid,
                            cid: widget.cid,
                          ),
                          // 评论页面
                          VideoReplyPanel(
                            bvid: widget.bvid,
                            oid: _videoDetail.ownerMid,
                          ),
                          // 推荐页面（暂时为空）
                          const Center(
                            child: Text('推荐内容'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}