import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiMode;
import 'package:get/get.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/utils/num_utils.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:bili_you/pages/bili_video2/widgets/introduction/piliplus_intro_panel.dart';
import 'package:bili_you/pages/bili_video2/widgets/reply/piliplus_reply_panel.dart';

class BiliVideoPageFull extends StatefulWidget {
  final String bvid;
  final int cid;

  const BiliVideoPageFull({
    Key? key,
    required this.bvid,
    required this.cid,
  }) : super(key: key);

  @override
  State<BiliVideoPageFull> createState() => _BiliVideoPageFullState();
}

class _BiliVideoPageFullState extends State<BiliVideoPageFull>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late VideoInfo _videoInfo;
  ReplyInfo? _replyInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  late final ScrollController _scrollController = ScrollController();
  
  // 播放器相关
  bool _isFullScreen = false;
  double _videoHeight = 0;
  final double _minVideoHeight = 200;
  final double _maxVideoHeight = 400;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _videoHeight = _minVideoHeight;
    _loadVideoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVideoData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 获取视频详细信息
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: widget.bvid);
      setState(() {
        _videoInfo = videoInfo;
      });

      // 获取评论信息
      try {
        final replyInfo = await ReplyApi.getReply(
          oid: widget.bvid,
          pageNum: 1,
          type: ReplyType.video,
        );
        setState(() {
          _replyInfo = replyInfo;
        });
      } catch (e) {
        debugPrint('获取评论失败: $e');
      }

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

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _videoHeight = (_videoHeight - details.delta.dy).clamp(
        _minVideoHeight,
        _maxVideoHeight,
      );
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    
    // 隐藏或显示状态栏
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              : PopScope(
                  canPop: !_isFullScreen,
                  onPopInvoked: (bool didPop) {
                    if (_isFullScreen) {
                      _toggleFullScreen();
                    }
                  },
                  child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          expandedHeight: _isFullScreen 
                              ? MediaQuery.of(context).size.height
                              : _videoHeight,
                          floating: false,
                          pinned: true,
                          backgroundColor: Colors.black,
                          flexibleSpace: FlexibleSpaceBar(
                            background: GestureDetector(
                              onVerticalDragUpdate: _onVerticalDragUpdate,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // 视频播放器
                                  BiliVideoPlayer(
                                    bvid: widget.bvid,
                                    cid: widget.cid,
                                  ),
                                  // 全屏按钮
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          _isFullScreen 
                                              ? Icons.fullscreen_exit
                                              : Icons.fullscreen,
                                          color: Colors.white,
                                        ),
                                        onPressed: _toggleFullScreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: Column(
                      children: [
                        // 视频标题和信息
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _videoInfo.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(_videoInfo.ownerFace),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_videoInfo.ownerName),
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
                                  Text(NumUtils.numFormat(_videoInfo.playNum)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(NumUtils.numFormat(_videoInfo.danmaukuNum)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(NumUtils.numFormat(_videoInfo.likeNum)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(NumUtils.numFormat(_videoInfo.coinNum)),
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
                              PiliPlusIntroPanel(
                                bvid: widget.bvid,
                                cid: widget.cid,
                              ),
                              // 评论页面
                              PiliPlusReplyPanel(
                                bvid: widget.bvid,
                                oid: _videoInfo.ownerMid.toString(),
                              ),
                              // 推荐页面
                              const Center(
                                child: Text('推荐内容'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}