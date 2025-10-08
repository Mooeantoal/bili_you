import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

class VideoReplyPanel extends StatefulWidget {
  final String bvid;
  final int oid;

  const VideoReplyPanel({
    Key? key,
    required this.bvid,
    required this.oid,
  }) : super(key: key);

  @override
  State<VideoReplyPanel> createState() => _VideoReplyPanelState();
}

class _VideoReplyPanelState extends State<VideoReplyPanel>
    with AutomaticKeepAliveClientMixin {
  ReplyInfo? _replyInfo;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReplies();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreReplies();
    }
  }

  Future<void> _loadReplies() async {
    try {
      final replyInfo = await ReplyApi.getReply(
        oid: widget.bvid,
        pageNum: _currentPage,
        type: ReplyType.video,
      );
      setState(() {
        if (_currentPage == 1) {
          _replyInfo = replyInfo;
        } else {
          // 添加更多评论
          _replyInfo!.replies.addAll(replyInfo.replies);
        }
        _hasMore = replyInfo.replies.length == _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载评论失败: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreReplies() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    _currentPage++;
    await _loadReplies();
  }

  Future<void> _refreshReplies() async {
    setState(() {
      _currentPage = 1;
      _isLoading = true;
    });
    await _loadReplies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _refreshReplies,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _replyInfo == null
                  ? const Center(child: Text('无法获取评论信息'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12.0),
                      itemCount: _replyInfo!.replies.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _replyInfo!.replies.length) {
                          final reply = _replyInfo!.replies[index];
                          return _buildReplyItem(reply, theme);
                        } else {
                          // 显示加载更多指示器
                          return _buildLoadMoreIndicator();
                        }
                      },
                    ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ElevatedButton(
            onPressed: _loadMoreReplies,
            child: const Text('加载更多'),
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('没有更多评论了')),
      );
    }
  }

  Widget _buildReplyItem(ReplyItem reply, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(reply.member.avatarUrl),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(reply.replyTime * 1000)
                          .toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 评论内容
            Text(reply.content.message),
            const SizedBox(height: 8),
            
            // 评论操作
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    reply.hasLike ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    size: 16,
                  ),
                  onPressed: () {
                    // 点赞/取消点赞
                  },
                ),
                Text('${reply.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  onPressed: () {
                    // 回复评论
                  },
                ),
                Text('${reply.replyCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}