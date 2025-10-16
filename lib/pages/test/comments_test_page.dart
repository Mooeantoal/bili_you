import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math';

// 简化的评论数据模型
class Comment {
  final String id;
  final String username;
  final String content;
  final int likeCount;
  final String avatarUrl;
  final String publishTime;
  final int replyCount;
  final bool isHot;
  final String root; // 根评论ID，如果本身就是根评论则为""
  final String parent; // 父评论ID，如果本身就是根评论则为""
  final List<Comment> replies; // 楼中楼评论列表

  Comment({
    required this.id,
    required this.username,
    required this.content,
    required this.likeCount,
    required this.avatarUrl,
    required this.publishTime,
    required this.replyCount,
    this.isHot = false,
    this.root = "",
    this.parent = "",
    this.replies = const [],
  });

  // 生成模拟数据的方法
  factory Comment.generateMock(int index, {bool isReply = false, String? rootId, String? parentId}) {
    final random = Random();
    final usernames = ['用户A', '用户B', '用户C', '用户D', '用户E'];
    final contents = [
      '这是一条测试评论内容 $index',
      '我觉得这个视频很有意思 $index',
      '感谢分享，学到了很多 $index',
      '不太同意这个观点 $index',
      '支持UP主继续创作 $index',
    ];
    
    return Comment(
      id: 'comment_$index',
      username: usernames[random.nextInt(usernames.length)],
      content: contents[random.nextInt(contents.length)],
      likeCount: random.nextInt(100),
      avatarUrl: '',
      publishTime: '${random.nextInt(12) + 1}-${random.nextInt(28) + 1} ${random.nextInt(24)}:${random.nextInt(60).toString().padLeft(2, '0')}',
      replyCount: isReply ? 0 : random.nextInt(10),
      root: rootId ?? (isReply ? (parentId ?? "") : ""),
      parent: parentId ?? (isReply ? (rootId ?? "") : ""),
      replies: isReply ? [] : List.generate(
        min(3, random.nextInt(10)), 
        (i) => Comment.generateMock(index * 100 + i, isReply: true, rootId: 'comment_$index', parentId: 'comment_$index')
      ),
    );
  }
}

class CommentsTestPage extends StatefulWidget {
  const CommentsTestPage({Key? key}) : super(key: key);

  @override
  State<CommentsTestPage> createState() => _CommentsTestPageState();
}

class _CommentsTestPageState extends State<CommentsTestPage> {
  List<Comment> comments = [];
  final Dio _dio = Dio();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMockComments();
  }

  // 加载模拟评论数据
  Future<void> _loadMockComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 生成模拟数据
      final mockComments = List.generate(
        10, 
        (index) => Comment.generateMock(index)
      );
      
      setState(() {
        comments = mockComments;
        isLoading = false;
      });
    } catch (e) {
      print('加载评论时出错: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 刷新评论
  void _refreshComments() {
    _loadMockComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论测试页面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComments,
          ),
        ],
      ),
      body: isLoading && comments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _refreshComments(),
              child: ListView(
                children: [
                  // 热门评论
                  if (comments.where((c) => c.isHot).isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '热门评论',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    for (var comment in comments.where((c) => c.isHot))
                      _buildCommentItem(comment),
                    const Divider(),
                  ],
                  // 普通评论
                  if (comments.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '全部评论',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (var comment in comments)
                      _buildCommentItem(comment),
                  ] else if (!isLoading)
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
            ),
    );
  }

  // 构建评论项
  Widget _buildCommentItem(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  child: Text(comment.username[0]),
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
                            comment.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (comment.isHot)
                            const Icon(Icons.local_fire_department, 
                                size: 16, color: Colors.orange),
                        ],
                      ),
                      Text(
                        comment.publishTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 评论内容
            Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // 楼中楼评论 (只显示前3条)
            if (comment.replies.isNotEmpty) ...[
              const Divider(height: 16, thickness: 1),
              ...comment.replies.take(3).map((reply) => _buildReplyItem(reply, onTap: () {
                // 点击楼中楼评论时显示弹出式卡片，显示完整回复列表
                _showReplyDetail(reply, comment);
              })).toList(),
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
            // 点赞和回复信息
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      comment.likeCount.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      comment.replyCount.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建楼中楼回复项
  Widget _buildReplyItem(Comment reply, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  child: Text(reply.username[0]),
                ),
                const SizedBox(width: 6),
                Text(
                  reply.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reply.publishTime,
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
              reply.content,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 显示楼中楼评论详情（显示该评论的所有回复列表）
  void _showReplyDetail(Comment reply, Comment rootComment) {
    // 显示该根评论的所有回复列表
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 根评论信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Text(rootComment.username[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rootComment.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          rootComment.publishTime,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 根评论内容
              Text(
                rootComment.content,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                '回复列表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // 回复列表（这里我们显示所有回复用于测试）
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rootComment.replies.length,
                  itemBuilder: (context, index) {
                    final replyItem = rootComment.replies[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: replyItem.id == reply.id ? Colors.blue[50] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 回复用户信息
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text(replyItem.username[0]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                replyItem.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                replyItem.publishTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 回复内容
                          Text(
                            replyItem.content,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          // 点赞和回复信息
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.thumb_up, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    replyItem.likeCount.toString(),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  const Icon(Icons.comment, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    replyItem.replyCount.toString(),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}