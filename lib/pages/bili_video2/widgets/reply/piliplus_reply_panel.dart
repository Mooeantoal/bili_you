import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/utils/num_utils.dart';

class PiliPlusReplyPanel extends StatefulWidget {
  final String bvid;
  final String oid;

  const PiliPlusReplyPanel({
    Key? key,
    required this.bvid,
    required this.oid,
  }) : super(key: key);

  @override
  State<PiliPlusReplyPanel> createState() => _PiliPlusReplyPanelState();
}

class _PiliPlusReplyPanelState extends State<PiliPlusReplyPanel> {
  ReplyInfo? _replyInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies({bool loadMore = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final replyInfo = await ReplyApi.getReply(
        oid: widget.oid,
        pageNum: loadMore ? _currentPage + 1 : 1,
        type: ReplyType.video,
      );

      setState(() {
        if (loadMore && _replyInfo != null) {
          // 合并新的评论到现有评论列表
          _replyInfo!.replies.addAll(replyInfo.replies);
          _currentPage++;
        } else {
          _replyInfo = replyInfo;
          _currentPage = 1;
        }
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
    if (_isLoading && (_replyInfo == null)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && (_replyInfo == null)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_errorMessage'),
            ElevatedButton(
              onPressed: _loadReplies,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadReplies();
      },
      child: _replyInfo == null
          ? const Center(child: Text('暂无评论'))
          : ListView.builder(
              itemCount: _replyInfo!.replies.length + 1,
              itemBuilder: (context, index) {
                if (index == _replyInfo!.replies.length) {
                  // 加载更多按钮
                  return _buildLoadMoreButton();
                }
                return _buildReplyItem(_replyInfo!.replies[index]);
              },
            ),
    );
  }

  Widget _buildReplyItem(ReplyItem reply) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
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
              Expanded(
                child: Column(
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
                      'LV${reply.member.level}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                reply.replyTime.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 评论内容
          Text(
            reply.content.message,
            style: const TextStyle(
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          
          // 点赞和回复
          Row(
            children: [
              IconButton(
                icon: Icon(
                  reply.hasLike ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: reply.hasLike ? Colors.blue : null,
                ),
                onPressed: () {
                  // 点赞功能
                },
              ),
              Text(
                NumUtils.numFormat(reply.likeCount),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.reply, size: 16),
                onPressed: () {
                  // 回复功能
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            _loadReplies(loadMore: true);
          },
          child: const Text('加载更多'),
        ),
      ),
    );
  }
}