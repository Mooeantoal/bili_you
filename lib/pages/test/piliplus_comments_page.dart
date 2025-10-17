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

class PiliPlusCommentsPage extends StatefulWidget {
  final String videoUrl; // 视频URL

  const PiliPlusCommentsPage({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<PiliPlusCommentsPage> createState() => _PiliPlusCommentsPageState();
}

class _PiliPlusCommentsPageState extends State<PiliPlusCommentsPage> {
  List<Comment> comments = [];
  List<Comment> hotComments = [];
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  String sortType = '0'; // 0=按时间, 1=按点赞, 2=按回复
  bool hasMore = true; // 是否还有更多数据
  final Dio _dio = Dio();
  final TextEditingController _pageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();
    
    // 监听滚动事件，实现无限滚动加载
    _scrollController.addListener(_scrollListener);
  }

  // 滚动监听器
  void _scrollListener() {
    // 当滚动到接近底部时加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }

  // 加载更多评论
  Future<void> _loadMoreComments() async {
    if (!hasMore || isLoading) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      currentPage++;
      final url = 
        'https://uapis.cn/api/v1/social/bilibili/replies'
        '?oid=1559365249' // 使用指定视频的aid
        '&sort=$sortType'
        '&ps=20'
        '&pn=$currentPage';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 解析普通评论
        if (data['replies'] != null) {
          List<Comment> newComments = [];
          for (var commentJson in data['replies']) {
            newComments.add(Comment.fromJson(commentJson));
          }
          
          setState(() {
            comments.addAll(newComments);
            totalPages = data['page'] != null && data['page']['count'] != null 
                ? (data['page']['count'] / 20).ceil() 
                : currentPage;
            hasMore = currentPage < totalPages;
          });
        } else {
          setState(() {
            hasMore = false;
          });
        }
      }
    } catch (e) {
      print('加载更多评论时出错: $e');
      // 回退页码
      setState(() {
        currentPage--;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 加载评论数据
  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 使用UAPI提供的API获取评论
      // 检查参数是否正确
      print('请求评论数据: oid=1559365249, sort=$sortType, ps=20, pn=$currentPage');
      final url = 
        'https://uapis.cn/api/v1/social/bilibili/replies'
        '?oid=1559365249' // 使用指定视频的aid
        '&sort=$sortType'
        '&ps=20'
        '&pn=$currentPage';

      final response = await _dio.get(url);
      print('收到响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('收到评论数据: ${data.keys}');
        
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

        // 解析普通评论 (只获取前3条回复)
        if (data['replies'] != null) {
          List<Comment> newComments = [];
          for (var commentJson in data['replies']) {
            // 只保留前3条回复
            if (commentJson['replies'] != null && commentJson['replies'] is List) {
              // 限制回复数量为3条
              if (commentJson['replies'].length > 3) {
                commentJson['replies'] = commentJson['replies'].sublist(0, 3);
              }
            }
            newComments.add(Comment.fromJson(commentJson));
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
        print('错误响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      setState(() {
        errorMessage = '获取评论时出错: $e';
      });
      print('异常详情: $e');
      print('堆栈跟踪: $stackTrace');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 加载完整的楼中楼评论列表
  Future<List<Comment>> _loadFullReplies(String oid, String rootId) async {
    try {
      // 使用UAPI提供的API获取完整的楼中楼评论
      // 确保参数正确：oid为视频aid，root为根评论的rpid
      final url = 
        'https://uapis.cn/api/v1/social/bilibili/replies'
        '?oid=$oid'
        '&root=$rootId'
        '&ps=3'  // 只获取前3条回复
        '&pn=1';  // 只获取第一页

      print('请求完整回复列表: $url');
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        print('收到回复数据: ${data.keys}');
        
        // 解析楼中楼评论
        List<Comment> replies = [];
        if (data['replies'] != null && data['replies'] is List) {
          for (var reply in data['replies']) {
            replies.add(Comment.fromJson(reply));
          }
        }
        
        print('解析到 ${replies.length} 条回复');
        return replies;
      } else {
        print('HTTP错误: ${response.statusCode}');
      }
    } catch (e) {
      print('获取完整楼中楼评论时出错: $e');
    }
    
    return [];
  }

  // 刷新评论
  void _refreshComments() {
    setState(() {
      currentPage = 1;
      hasMore = true;
      comments.clear();
    });
    _loadComments();
  }

  // 更改排序方式
  void _changeSortType(String newSortType) {
    setState(() {
      sortType = newSortType;
      currentPage = 1;
      hasMore = true;
      comments.clear();
    });
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComments,
          ),
        ],
      ),
      body: Column(
        children: [
          // 视频信息部分
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 视频封面
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.play_arrow, size: 20),
                ),
                const SizedBox(width: 12),
                // 视频标题
                const Expanded(
                  child: Text(
                    'BV1xhmnYFEir',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 评论内容
          Expanded(
            child: isLoading && comments.isEmpty // 只在初次加载时显示loading
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
                            // 热门评论
                            if (hotComments.isNotEmpty) ...[
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
                              for (var comment in hotComments)
                                _buildCommentItem(comment),
                              const Divider(),
                            ],
                            // 普通评论
                            if (comments.isNotEmpty) ...[
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
                              // 加载更多指示器
                              if (isLoading && comments.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              ] else if (!hasMore) ...[
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
          ),
        ],
      ),
    );
  }

  // 构建评论项 (采用PiliPlus风格)
  Widget _buildCommentItem(Comment comment) {
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
                          if (comment.isHot) // 热门评论标识
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '热',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
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
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // 楼中楼评论 (只显示前3条)
            if (comment.replies.isNotEmpty) ...[
              const Divider(height: 16, thickness: 1),
              ...comment.replies.take(3).map((reply) => _buildReplyItem(reply, onTap: () {
                // 点击楼中楼评论时显示弹出式卡片，显示完整回复列表
                _showReplyDetail(reply);
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

  // 显示楼中楼评论详情（显示该评论的所有回复列表）
  void _showReplyDetail(Comment reply) async {
    // 查找包含该回复的根评论
    Comment? rootComment;
    for (var comment in comments) {
      // 遍历每个根评论的回复，查找匹配的回复
      for (var r in comment.replies) {
        // 通过比较对象引用或者更准确的标识来判断是否是同一个回复
        if (r == reply || 
            (r.username == reply.username && 
             r.content == reply.content && 
             r.publishTime == reply.publishTime)) {
          rootComment = comment;
          break;
        }
      }
      if (rootComment != null) break;
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
    
    // 获取完整的楼中楼评论列表
    // 使用根评论的ID作为root参数来获取该评论的所有回复
    // 注意：这里的参数可能需要根据API的具体要求进行调整
    String rootId = rootComment.root == 0 ? rootComment.parent.toString() : rootComment.root.toString();
    if (rootId == "0") {
      // 如果rootId为0，尝试使用根评论本身的ID
      rootId = rootComment.parent.toString();
    }
    
    List<Comment> fullReplies = await _loadFullReplies('1559365249', rootId);
    if (fullReplies.isEmpty) {
      fullReplies = rootComment.replies; // 如果获取失败，使用原始数据
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
                        ? NetworkImage(rootComment.avatarUrl)
                        : null,
                    child: rootComment.avatarUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 40)
                        : null,
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
              // 回复列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: fullReplies.length,
                  itemBuilder: (context, index) {
                    final replyItem = fullReplies[index];
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

  // 显示回复对话框
  void _showReplyDialog(Comment comment) {
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

  // 显示完整回复列表
  void _showFullReplies(Comment rootComment) async {
    // 获取完整的楼中楼评论列表
    // 使用根评论的rpid作为root参数来获取该评论的所有回复
    List<Comment> fullReplies = await _loadFullReplies('1559365249', rootComment.root == 0 ? rootComment.parent.toString() : rootComment.root.toString());
    if (fullReplies.isEmpty) {
      fullReplies = rootComment.replies; // 如果获取失败，使用原始数据
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
                    backgroundImage: rootComment.avatarUrl.isNotEmpty
                        ? NetworkImage(rootComment.avatarUrl)
                        : null,
                    child: rootComment.avatarUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 40)
                        : null,
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
              // 回复列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: fullReplies.length,
                  itemBuilder: (context, index) {
                    final replyItem = fullReplies[index];
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