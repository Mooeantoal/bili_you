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
  final int root; // 根评论ID，如果本身就是根评论则为0
  final int parent; // 父评论ID，如果本身就是根评论则为0
  final List<Comment> replies; // 楼中楼评论列表

  Comment({
    required this.username,
    required this.content,
    required this.likeCount,
    required this.avatarUrl,
    required this.publishTime,
    required this.replyCount,
    this.isHot = false,
    this.root = 0,
    this.parent = 0,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // 解析楼中楼评论
    List<Comment> replies = [];
    if (json['replies'] != null && json['replies'] is List) {
      for (var reply in json['replies']) {
        replies.add(Comment.fromJson(reply));
      }
    }
    
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
      root: json['root'] ?? 0,
      parent: json['parent'] ?? 0,
      replies: replies,
    );
  }

  // 从API响应创建热门评论
  factory Comment.fromHotComment(Map<String, dynamic> json) {
    // 解析楼中楼评论
    List<Comment> replies = [];
    if (json['replies'] != null && json['replies'] is List) {
      for (var reply in json['replies']) {
        replies.add(Comment.fromJson(reply));
      }
    }
    
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
      root: json['root'] ?? 0,
      parent: json['parent'] ?? 0,
      replies: replies,
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
  final TextEditingController _pageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
            // 添加调试信息
            print('页面数据: ${data['page']}');
            totalPages = data['page'] != null && data['page']['count'] != null 
                ? (data['page']['count'] / 20).ceil() 
                : 1;
            print('总页数: $totalPages');
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
      // 移除AppBar以减少高度
      appBar: null,
      body: Column(
        children: [
          // 移除视频信息部分
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
                          controller: _scrollController,
                          children: [
                            // 热门评论（移除图标）
                            if (hotComments.isNotEmpty) ...[
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
                              for (var comment in hotComments)
                                _buildCommentItem(comment),
                              const Divider(),
                            ],
                            // 普通评论（移除图标，添加刷新和排序按钮）
                            if (comments.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '全部评论',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // 刷新按钮
                                        IconButton(
                                          icon: const Icon(Icons.refresh, size: 20),
                                          onPressed: _refreshComments,
                                        ),
                                        // 排序按钮
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.sort, size: 20),
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
                                  ],
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
                          // 移除热门评论的火焰图标
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
            // 楼中楼评论
            if (comment.replies.isNotEmpty) ...[
              const Divider(height: 16, thickness: 1),
              ...comment.replies.map((reply) => _buildReplyItem(reply, onTap: () {
                // 点击楼中楼评论时显示弹出式卡片
                _showReplyDetail(reply);
              })).toList(),
              const SizedBox(height: 8),
            ],
            // 点赞和回复信息（添加文字标识）
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
                    const Text(
                      ' 点赞',
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
                    const Text(
                      ' 回复',
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
                  backgroundImage: reply.avatarUrl.isNotEmpty
                      ? NetworkImage(reply.avatarUrl)
                      : null,
                  child: reply.avatarUrl.isEmpty
                      ? const Icon(Icons.account_circle, size: 24)
                      : null,
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

  // 构建分页控件
  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 首页按钮
              ElevatedButton(
                onPressed: currentPage > 1 ? () {
                  setState(() {
                    currentPage = 1;
                  });
                  _loadComments();
                } : null,
                child: const Text('首页'),
              ),
              const SizedBox(width: 8),
              // 上一页按钮
              ElevatedButton(
                onPressed: currentPage > 1 ? _loadPreviousPage : null,
                child: const Text('上一页'),
              ),
              const SizedBox(width: 8),
              // 下一页按钮
              ElevatedButton(
                onPressed: currentPage < totalPages ? _loadNextPage : null,
                child: const Text('下一页'),
              ),
              const SizedBox(width: 8),
              // 尾页按钮
              ElevatedButton(
                onPressed: currentPage < totalPages ? () {
                  print('跳转到尾页: $totalPages');
                  setState(() {
                    currentPage = totalPages;
                  });
                  _loadComments();
                  
                  // 滚动到分页控件位置
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                } : null,
                child: const Text('尾页'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('第 $currentPage / $totalPages 页'),
              const SizedBox(width: 16),
              // 页码输入框和跳转按钮
              SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '输入页码',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (value) {
                    _jumpToPage(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _pageController.text;
                  _jumpToPage(text);
                },
                child: const Text('跳转'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 跳转到指定页码
  void _jumpToPage(String pageText) {
    if (pageText.isEmpty) return;
    
    final page = int.tryParse(pageText);
    if (page == null || page < 1 || page > totalPages) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入有效的页码 (1-$totalPages)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      currentPage = page;
      // 清空输入框
      _pageController.clear();
    });
    _loadComments();
    
    // 滚动到分页控件位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 显示楼中楼评论详情（显示该评论的所有回复列表）
  void _showReplyDetail(Comment reply) {
    // 查找包含该回复的根评论
    Comment? rootComment;
    for (var comment in comments) {
      if (comment.replies.any((r) => r == reply)) {
        rootComment = comment;
        break;
      }
    }
    
    // 如果找不到根评论，则直接显示该回复的详情
    if (rootComment == null) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: reply.avatarUrl.isNotEmpty
                          ? NetworkImage(reply.avatarUrl)
                          : null,
                      child: reply.avatarUrl.isEmpty
                          ? const Icon(Icons.account_circle, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            reply.publishTime,
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
                const SizedBox(height: 16),
                // 评论内容
                Text(
                  reply.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // 点赞和回复信息
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          reply.likeCount.toString(),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const Text(
                          ' 点赞',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.comment, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          reply.replyCount.toString(),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const Text(
                          ' 回复',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      return;
    }
    
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
                    backgroundImage: rootComment!.avatarUrl.isNotEmpty
                        ? NetworkImage(rootComment!.avatarUrl)
                        : null,
                    child: rootComment!.avatarUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rootComment!.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          rootComment!.publishTime,
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
                rootComment!.content,
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
              // 回复列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rootComment!.replies.length,
                  itemBuilder: (context, index) {
                    final replyItem = rootComment!.replies[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: replyItem == reply ? Colors.blue[50] : Colors.grey[100],
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
                                backgroundImage: replyItem.avatarUrl.isNotEmpty
                                    ? NetworkImage(replyItem.avatarUrl)
                                    : null,
                                child: replyItem.avatarUrl.isEmpty
                                    ? const Icon(Icons.account_circle, size: 32)
                                    : null,
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
                                  const Text(
                                    ' 点赞',
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
                                  const Text(
                                    ' 回复',
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

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
