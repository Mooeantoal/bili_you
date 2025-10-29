import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;

// 评论数据模型
class Comment {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final int likeCount;
  final bool isPinned;
  final bool isHeartedByUploader;
  final DateTime uploadDate;
  final int replyCount;
  final String? replyUrl;
  final List<String>? images;

  Comment({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.likeCount,
    required this.isPinned,
    required this.isHeartedByUploader,
    required this.uploadDate,
    required this.replyCount,
    this.replyUrl,
    this.images,
  });

  // 从API响应创建Comment对象
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['rpid'].toString(),
      authorName: json['member']?['uname'] ?? '未知用户',
      authorAvatarUrl: json['member']?['avatar'] ?? '',
      content: json['content']?['message'] ?? '',
      likeCount: json['like'] ?? 0,
      isPinned: json['is_top'] == 1,
      isHeartedByUploader: json['is_up'] == 1,
      uploadDate: DateTime.fromMillisecondsSinceEpoch(
        (json['ctime'] ?? 0) * 1000,
      ),
      replyCount: json['rcount'] ?? 0,
      replyUrl: json['replies'] != null ? 'reply_url' : null,
      images: [], // B站评论通常不包含图片
    );
  }
}

class PipePipeCommentsPage extends StatefulWidget {
  const PipePipeCommentsPage({Key? key}) : super(key: key);

  @override
  State<PipePipeCommentsPage> createState() => _PipePipeCommentsPageState();
}

class _PipePipeCommentsPageState extends State<PipePipeCommentsPage> {
  final Dio _dio = Dio();
  List<Comment> _comments = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final String _videoId = '928861104'; // 示例视频ID (aid)

  @override
  void initState() {
    super.initState();
    _loadComments();
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
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreComments();
      }
    }
  }

  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 使用UAPI平台提供的API获取评论
      final url =
          'https://uapis.cn/api/v1/social/bilibili/replies?oid=$_videoId&sort=0&ps=20&pn=1';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        List<Comment> newComments = [];

        // 解析评论
        if (data['replies'] != null) {
          for (var commentJson in data['replies']) {
            newComments.add(Comment.fromJson(commentJson));
          }
        }

        setState(() {
          _comments = newComments;
          _currentPage = 1;
          _hasMore = data['replies'] != null && data['replies'].length == 20;
        });
      } else {
        setState(() {
          _errorMessage = '获取评论失败: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '获取评论时出错: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final url =
          'https://uapis.cn/api/v1/social/bilibili/replies?oid=$_videoId&sort=0&ps=20&pn=$nextPage';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        List<Comment> newComments = [];

        // 解析评论
        if (data['replies'] != null) {
          for (var commentJson in data['replies']) {
            newComments.add(Comment.fromJson(commentJson));
          }
        }

        setState(() {
          _comments.addAll(newComments);
          _currentPage = nextPage;
          _hasMore = data['replies'] != null && data['replies'].length == 20;
        });
      }
    } catch (e) {
      // 静默处理错误，不显示给用户
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 格式化相对时间
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 格式化数字显示
  String _formatCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PipePipe评论'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 评论列表
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadComments();
              },
              child: _buildCommentsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _loadComments,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return const Center(
        child: Text('暂无评论'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _comments.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _comments.length) {
          // 加载更多指示器
          return _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final comment = _comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          ClipOval(
            child: comment.authorAvatarUrl.isNotEmpty
                ? Image.network(
                    comment.authorAvatarUrl,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 42,
                        height: 42,
                        color: Colors.grey[300],
                        child: const Icon(Icons.account_circle, size: 42),
                      );
                    },
                  )
                : Container(
                    width: 42,
                    height: 42,
                    color: Colors.grey[300],
                    child: const Icon(Icons.account_circle, size: 42),
                  ),
          ),
          const SizedBox(width: 12),
          // 评论内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 作者信息行
                Row(
                  children: [
                    if (comment.isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 评论内容
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Text(
                    comment.content,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                // 底部信息行
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(comment.likeCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (comment.isHeartedByUploader) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatRelativeTime(comment.uploadDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // 回复和图片信息
                if (comment.replyCount > 0 || (comment.images?.isNotEmpty ?? false)) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        if (comment.replyCount > 0) ...[
                          Text(
                            '共${comment.replyCount}条回复',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                        if (comment.replyCount > 0 && (comment.images?.isNotEmpty ?? false)) ...[
                          const Spacer(),
                        ],
                        if (comment.images?.isNotEmpty ?? false) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.image,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '查看图片${comment.images!.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}