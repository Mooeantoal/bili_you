import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:flutter/material.dart';

class ReplyPage extends StatefulWidget {
  const ReplyPage({super.key, required this.replyId, required this.replyType});

  final String replyId;
  final ReplyType replyType;

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  ReplyInfo? _replyInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    try {
      final replyInfo = await ReplyApi.getReply(
        oid: widget.replyId,
        pageNum: _currentPage,
        type: widget.replyType,
      );
      setState(() {
        _replyInfo = replyInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载评论失败: $e';
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

    if (_replyInfo == null) {
      return const Center(child: Text('无法获取评论信息'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        await _loadReplies();
      },
      child: ListView.builder(
        itemCount: _replyInfo!.replies.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // 头部显示评论总数
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '评论 (${_replyInfo!.replyCount})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final reply = _replyInfo!.replies[index - 1];
          return _buildReplyItem(reply);
        },
      ),
    );
  }

  Widget _buildReplyItem(ReplyItem reply) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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