import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/test/reply/reply_controller.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/api/reply_api.dart';

class ReplyPage extends StatefulWidget {
  final String oid;
  final ReplyType type;
  final String videoTitle;

  const ReplyPage({
    Key? key,
    required this.oid,
    required this.type,
    this.videoTitle = '视频评论',
  }) : super(key: key);

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  late ReplyController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ReplyController(), tag: widget.oid);
    _controller.refreshReplies(widget.oid, widget.type);
    
    // 监听滚动事件，实现无限滚动加载
    _scrollController.addListener(_scrollListener);
  }

  // 滚动监听器
  void _scrollListener() {
    // 当滚动到接近底部时加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_controller.hasMore.value && !_controller.isLoading.value) {
        _controller.loadReplies(widget.oid, widget.type);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    // 注意：这里不删除控制器，因为它可能在其他地方被使用
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refreshReplies(widget.oid, widget.type),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.replies.isEmpty) {
          // 初次加载显示loading
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.isNotEmpty) {
          // 显示错误信息
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.refreshReplies(widget.oid, widget.type),
                  child: const Text('重新加载'),
                ),
              ],
            ),
          );
        }

        // 显示评论列表
        return RefreshIndicator(
          onRefresh: () async => _controller.refreshReplies(widget.oid, widget.type),
          child: ListView(
            controller: _scrollController,
            children: [
              // 热门评论
              if (_controller.hotReplies.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '热门评论',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                for (var comment in _controller.hotReplies)
                  _buildCommentItem(comment),
                const Divider(),
              ],
              // 普通评论
              if (_controller.replies.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '全部评论',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // 排序按钮
                          PopupMenuButton<ReplySort>(
                            icon: const Icon(Icons.sort, size: 20),
                            onSelected: (ReplySort sort) {
                              _controller.changeSortType(sort, widget.oid, widget.type);
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: ReplySort.time,
                                child: Text('按时间排序'),
                              ),
                              const PopupMenuItem(
                                value: ReplySort.like,
                                child: Text('按点赞排序'),
                              ),
                              const PopupMenuItem(
                                value: ReplySort.reply,
                                child: Text('按回复排序'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                for (var comment in _controller.replies)
                  _buildCommentItem(comment),
                // 加载更多指示器
                if (_controller.isLoading.value && _controller.replies.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else if (!_controller.hasMore.value) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '没有更多评论了',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ] else if (!_controller.isLoading.value)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '暂无评论',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // 构建评论项
  Widget _buildCommentItem(ReplyItem comment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Row(
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.member.avatarUrl.isNotEmpty
                      ? NetworkImage(comment.member.avatarUrl)
                      : null,
                  child: comment.member.avatarUrl.isEmpty
                      ? const Icon(Icons.account_circle, size: 32)
                      : null,
                ),
                const SizedBox(width: 8),
                // 用户名和时间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          // UP主标识
                          if (comment.member.mid == _controller.upMid.value)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'UP',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _formatTime(comment.replyTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // 点赞数
                Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      comment.likeCount.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 评论内容
            Text(
              comment.content.message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // 楼中楼评论 (只显示前3条)
            if (comment.preReplies.isNotEmpty) ...[
              const Divider(height: 16, thickness: 1),
              ...comment.preReplies.take(3).map((reply) => _buildSubReplyItem(reply)).toList(),
              // 如果还有更多回复，显示"共X条回复"文字
              if (comment.replyCount > 3) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '共${comment.replyCount}条回复',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ] else if (comment.replyCount > 0) ...[
              // 如果没有显示的回复但有回复数，显示"共X条回复"文字
              const Divider(height: 16, thickness: 1),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '共${comment.replyCount}条回复',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            // 回复按钮
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 显示回复界面
                  _showReplyDialog(comment);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  '回复',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建楼中楼回复项
  Widget _buildSubReplyItem(ReplyItem reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 回复用户信息
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: reply.member.avatarUrl.isNotEmpty
                    ? NetworkImage(reply.member.avatarUrl)
                    : null,
                child: reply.member.avatarUrl.isEmpty
                    ? const Icon(Icons.account_circle, size: 24)
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                reply.member.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(reply.replyTime),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 回复内容
          Text(
            reply.content.message,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 格式化时间
  String _formatTime(int timestamp) {
    if (timestamp == 0) return '';
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  // 显示回复对话框
  void _showReplyDialog(ReplyItem comment) {
    final TextEditingController textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '回复评论',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '请输入回复内容',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // 处理回复提交
                        String replyContent = textController.text.trim();
                        if (replyContent.isNotEmpty) {
                          // 这里应该调用API提交回复
                          print('提交回复: $replyContent');
                          Navigator.pop(context);
                          // 显示提交成功的提示
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('回复提交成功')),
                          );
                        }
                      },
                      child: const Text('提交'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}