import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// 评论数据模型
class Comment {
  final String username;
  final String content;
  final int likeCount;
  final String avatarUrl;
  final String publishTime;
  final int replyCount;
  final bool isHot;

  Comment({
    required this.username,
    required this.content,
    required this.likeCount,
    required this.avatarUrl,
    required this.publishTime,
    required this.replyCount,
    this.isHot = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      username: json['member']['uname'] ?? '未知用户',
      content: json['content']['message'] ?? '',
      likeCount: json['like'] ?? 0,
      avatarUrl: json['member']['avatar'] ?? '',
      publishTime: json['ctime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] * 1000)
              .toString().substring(0, 19).replaceFirst(' ', '\n') 
          : '',
      replyCount: json['rcount'] ?? 0,
      isHot: json['isHot'] ?? false,
    );
  }

  // 从API响应创建热门评论
  factory Comment.fromHotComment(Map<String, dynamic> json) {
    return Comment(
      username: json['member']['uname'] ?? '未知用户',
      content: json['content']['message'] ?? '',
      likeCount: json['like'] ?? 0,
      avatarUrl: json['member']['avatar'] ?? '',
      publishTime: json['ctime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] * 1000)
              .toString().substring(0, 19).replaceFirst(' ', '\n') 
          : '',
      replyCount: json['rcount'] ?? 0,
      isHot: true,
    );
  }
}

class BiliCommentsPage extends StatefulWidget {
  final String videoId; // BV号或av号
  final String aid; // 视频的aid

  const BiliCommentsPage({
    Key? key,
    required this.videoId,
    required this.aid,
  }) : super(key: key);

  @override
  State<BiliCommentsPage> createState() => _BiliCommentsPageState();
}

class _BiliCommentsPageState extends State<BiliCommentsPage> {
  List<Comment> comments = [];
  List<Comment> hotComments = [];
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  String sortType = '0'; // 0=按时间, 1=按点赞, 2=按回复
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // 加载评论数据
  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 使用UAPI提供的API获取评论
      final url = 
        'https://uapis.cn/api/v1/social/bilibili/replies'
        '?oid=${widget.aid}'
        '&sort=$sortType'
        '&ps=20'
        '&pn=$currentPage';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 解析热门评论（仅第一页）
        if (currentPage == 1 && data['hots'] != null) {
          List<Comment> newHotComments = [];
          for (var hotComment in data['hots']) {
            newHotComments.add(Comment.fromHotComment(hotComment));
          }
          setState(() {
            hotComments = newHotComments;
          });
        }

        // 解析普通评论
        if (data['replies'] != null) {
          List<Comment> newComments = [];
          for (var comment in data['replies']) {
            newComments.add(Comment.fromJson(comment));
          }
          
          setState(() {
            comments = newComments;
            totalPages = data['page'] != null && data['page']['count'] != null 
                ? (data['page']['count'] / 20).ceil() 
                : 1;
          });
        }
      } else {
        setState(() {
          errorMessage = '获取评论失败: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '获取评论时出错: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 刷新评论
  void _refreshComments() {
    currentPage = 1;
    _loadComments();
  }

  // 加载下一页
  void _loadNextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
      _loadComments();
    }
  }

  // 加载上一页
  void _loadPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      _loadComments();
    }
  }

  // 更改排序方式
  void _changeSortType(String newSortType) {
    setState(() {
      sortType = newSortType;
      currentPage = 1;
    });
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频评论'),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComments,
          ),
          // 排序按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSortType,
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                value: '0',
                child: Text('按时间排序'),
              ),
              PopupMenuItem(
                value: '1',
                child: Text('按点赞排序'),
              ),
              PopupMenuItem(
                value: '2',
                child: Text('按回复排序'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 视频信息
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '视频: ${widget.videoId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('AID: ${widget.aid}'),
                const SizedBox(height: 8),
                Text('排序方式: ${sortType == '0' ? '按时间' : sortType == '1' ? '按点赞' : '按回复'}'),
              ],
            ),
          ),
          // 分割线
          const Divider(),
          // 评论内容
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshComments,
                              child: const Text('重新加载'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _refreshComments(),
                        child: ListView(
                          children: [
                            // 热门评论
                            if (hotComments.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '🔥 热门评论',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              for (var comment in hotComments)
                                _buildCommentItem(comment),
                              const Divider(),
                            ],
                            // 普通评论
                            if (comments.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '💬 全部评论',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              for (var comment in comments)
                                _buildCommentItem(comment),
                            ] else
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    '暂无评论',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ),
                            // 分页控件
                            if (comments.isNotEmpty)
                              _buildPaginationControls(),
                          ],
                        ),
                      ),
          ),
        ],
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
                  backgroundImage: comment.avatarUrl.isNotEmpty
                      ? NetworkImage(comment.avatarUrl)
                      : null,
                  child: comment.avatarUrl.isEmpty
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
                            comment.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (comment.isHot)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 16,
                              ),
                            ),
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
            // 点赞和回复信息
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  comment.likeCount.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.comment_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  comment.replyCount.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建分页控件
  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: currentPage > 1 ? _loadPreviousPage : null,
            child: const Text('上一页'),
          ),
          Text('第 $currentPage / $totalPages 页'),
          ElevatedButton(
            onPressed: currentPage < totalPages ? _loadNextPage : null,
            child: const Text('下一页'),
          ),
        ],
      ),
    );
  }
}