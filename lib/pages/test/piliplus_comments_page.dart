import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// 评论数据模型
class Comment {
  final int rpid; // 评论ID
  final int oid; // 视频ID
  final int mid; // 用户ID
  final String username;
  final String content;
  final int likeCount;
  final String avatarUrl;
  final String publishTime;
  final int replyCount;
  final bool isHot;
  final int root; // 根评论ID
  final int parent; // 父评论ID
  final List<Comment> replies; // 楼中楼评论列表
  final bool isUp; // 是否为UP主评论
  final int level; // 用户等级
  final bool isVip; // 是否为VIP用户
  final bool isLiked; // 是否已点赞
  final bool isDisliked; // 是否已点踩
  final String location; // 地理位置

  Comment({
    required this.rpid,
    required this.oid,
    required this.mid,
    required this.username,
    required this.content,
    required this.likeCount,
    required this.avatarUrl,
    required this.publishTime,
    required this.replyCount,
    this.isHot = false,
    required this.root,
    required this.parent,
    this.replies = const [],
    this.isUp = false,
    this.level = 0,
    this.isVip = false,
    this.isLiked = false,
    this.isDisliked = false,
    this.location = '',
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // 解析楼中楼评论
    List<Comment> replies = [];
    if (json['replies'] != null && json['replies'] is List) {
      for (var reply in json['replies']) {
        replies.add(Comment.fromJson(reply));
      }
    }
    
    // 获取用户等级信息
    int level = 0;
    if (json['member'] != null && json['member']['level_info'] != null) {
      level = json['member']['level_info']['current_level'] ?? 0;
    }
    
    // 获取VIP信息
    bool isVip = false;
    if (json['member'] != null && json['member']['vip'] != null) {
      isVip = json['member']['vip']['vipStatus'] == 1;
    }
    
    // 获取UP主信息
    bool isUp = false;
    // 这里需要从外部传入UP主ID进行比较
    
    return Comment(
      rpid: json['rpid'] ?? 0,
      oid: json['oid'] ?? 0,
      mid: json['mid'] ?? 0,
      username: json['member'] != null ? (json['member']['uname'] ?? '未知用户') : '未知用户',
      content: json['content'] != null ? (json['content']['message'] ?? '') : '',
      likeCount: json['like'] ?? 0,
      avatarUrl: json['member'] != null ? (json['member']['avatar'] ?? '') : '',
      publishTime: json['ctime'] != null 
          ? _formatTime(json['ctime']) 
          : '',
      replyCount: json['rcount'] ?? 0,
      isHot: json['isHot'] ?? false,
      root: json['root'] ?? 0,
      parent: json['parent'] ?? 0,
      replies: replies,
      isUp: isUp,
      level: level,
      isVip: isVip,
      location: json['reply_control'] != null ? (json['reply_control']['location'] ?? '') : '',
    );
  }

  // 格式化时间
  static String _formatTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    
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
}

class PiliPlusCommentsPage extends StatefulWidget {
  final String videoId; // BV号或av号
  final String aid; // 视频的aid
  final int upMid; // UP主ID

  const PiliPlusCommentsPage({
    Key? key,
    required this.videoId,
    required this.aid,
    this.upMid = 0,
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
  int sortType = 0; // 0=按时间, 1=按点赞, 2=按回复
  bool hasMore = true; // 是否还有更多数据
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _likeStates = {}; // 点赞状态
  final Map<int, bool> _dislikeStates = {}; // 点踩状态

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
        '?oid=${widget.aid}'
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
            // 设置UP主标识
            if (commentJson['mid'] == widget.upMid) {
              commentJson['isUp'] = true;
            }
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
            // 设置UP主标识
            if (hotComment['mid'] == widget.upMid) {
              hotComment['isUp'] = true;
            }
            newHotComments.add(Comment.fromJson(hotComment));
          }
          setState(() {
            hotComments = newHotComments;
          });
        }

        // 解析普通评论
        if (data['replies'] != null) {
          List<Comment> newComments = [];
          for (var commentJson in data['replies']) {
            // 设置UP主标识
            if (commentJson['mid'] == widget.upMid) {
              commentJson['isUp'] = true;
            }
            newComments.add(Comment.fromJson(commentJson));
          }
          
          setState(() {
            comments = newComments;
            totalPages = data['page'] != null && data['page']['count'] != null 
                ? (data['page']['count'] / 20).ceil() 
                : 1;
            hasMore = currentPage < totalPages;
          });
        }
      } else {
        setState(() {
          errorMessage = '获取评论失败: ${response.statusCode}';
        });
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
      final url = 
        'https://uapis.cn/api/v1/social/bilibili/replies'
        '?oid=$oid'
        '&root=$rootId'
        '&ps=20'
        '&pn=1';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 解析楼中楼评论
        List<Comment> replies = [];
        if (data['replies'] != null && data['replies'] is List) {
          for (var reply in data['replies']) {
            // 设置UP主标识
            if (reply['mid'] == widget.upMid) {
              reply['isUp'] = true;
            }
            replies.add(Comment.fromJson(reply));
          }
        }
        
        return replies;
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
      hotComments.clear();
    });
    _loadComments();
  }

  // 更改排序方式
  void _changeSortType(int newSortType) {
    setState(() {
      sortType = newSortType;
      currentPage = 1;
      hasMore = true;
      comments.clear();
      hotComments.clear();
    });
    _loadComments();
  }

  // 点赞评论
  void _likeComment(Comment comment) {
    setState(() {
      // 更新UI状态
      if (_likeStates[comment.rpid] == true) {
        // 取消点赞
        _likeStates[comment.rpid] = false;
        comment.likeCount - 1;
      } else {
        // 点赞
        _likeStates[comment.rpid] = true;
        if (_dislikeStates[comment.rpid] == true) {
          _dislikeStates[comment.rpid] = false;
        }
        comment.likeCount + 1;
      }
    });
    
    // 这里应该调用API进行实际的点赞操作
    // 由于是演示，我们只更新UI状态
  }

  // 点踩评论
  void _dislikeComment(Comment comment) {
    setState(() {
      // 更新UI状态
      if (_dislikeStates[comment.rpid] == true) {
        // 取消点踩
        _dislikeStates[comment.rpid] = false;
      } else {
        // 点踩
        _dislikeStates[comment.rpid] = true;
        if (_likeStates[comment.rpid] == true) {
          _likeStates[comment.rpid] = false;
        }
      }
    });
    
    // 这里应该调用API进行实际的点踩操作
    // 由于是演示，我们只更新UI状态
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComments,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSortType,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('按时间排序'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('按点赞排序'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('按回复排序'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading && comments.isEmpty
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
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: false,
                        floating: true,
                        backgroundColor: theme.colorScheme.surface,
                        title: Container(
                          height: 40,
                          padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sortType == 0 ? '按时间排序' : 
                                sortType == 1 ? '按热度排序' : '按回复排序',
                                style: const TextStyle(fontSize: 13),
                              ),
                              SizedBox(
                                height: 35,
                                child: TextButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '排序方式',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ListTile(
                                              title: const Text('按时间排序'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _changeSortType(0);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('按点赞排序'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _changeSortType(1);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('按回复排序'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _changeSortType(2);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.sort,
                                    size: 16,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  label: Text(
                                    sortType == 0 ? '时间' : 
                                    sortType == 1 ? '热度' : '回复',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 热门评论
                      if (hotComments.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '热门评论',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildCommentItem(hotComments[index], isHot: true);
                            },
                            childCount: hotComments.length,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Divider(),
                        ),
                      ],
                      // 普通评论
                      if (comments.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '全部评论 (${comments.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildCommentItem(comments[index]);
                            },
                            childCount: comments.length,
                          ),
                        ),
                        // 加载更多指示器
                        if (isLoading && comments.isNotEmpty) ...[
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ] else if (!hasMore) ...[
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  '没有更多评论了',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ] else if (!isLoading)
                        const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                '暂无评论',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 发表评论
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  // 构建评论项
  Widget _buildCommentItem(Comment comment, {bool isHot = false}) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          // 点击评论
        },
        onLongPress: () {
          // 长按评论
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '评论操作',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('复制'),
                    onTap: () {
                      Navigator.pop(context);
                      // 复制评论内容
                    },
                  ),
                  ListTile(
                    title: const Text('举报'),
                    onTap: () {
                      Navigator.pop(context);
                      // 举报评论
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: _buildCommentContent(comment, theme, isHot: isHot),
      ),
    );
  }

  Widget _buildCommentContent(Comment comment, ThemeData theme, {bool isHot = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息行
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 用户头像
                  CircleAvatar(
                    radius: 17,
                    backgroundImage: comment.avatarUrl.isNotEmpty
                        ? NetworkImage(comment.avatarUrl)
                        : null,
                    child: comment.avatarUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 34)
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              comment.username,
                              style: TextStyle(
                                color: comment.isVip 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.outline,
                                fontSize: 13,
                              ),
                            ),
                            // 用户等级
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                'LV${comment.level}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            // UP主标识
                            if (comment.isUp) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4, 
                                  vertical: 1
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  'UP',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            // 热评标识
                            if (isHot) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4, 
                                  vertical: 1
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.secondary,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  '热评',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              comment.publishTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            if (comment.location.isNotEmpty) ...[
                              Text(
                                ' • ${comment.location}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 评论内容
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 6),
                child: Text(
                  comment.content,
                  style: TextStyle(
                    height: 1.75,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 楼中楼评论
              if (comment.replies.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildReplyRow(comment, theme),
              ] else if (comment.replyCount > 0) ...[
                // 如果没有显示的回复但有回复数，显示"共X条回复"文字
                const SizedBox(height: 4),
                _buildReplyRow(comment, theme),
              ],
              // 点赞和回复操作
              const SizedBox(height: 4),
              _buildActionRow(comment, theme),
            ],
          ),
        ),
        Divider(
          indent: 55,
          endIndent: 15,
          height: 0.3,
          color: theme.colorScheme.outline.withOpacity(0.08),
        ),
      ],
    );
  }

  // 构建回复行
  Widget _buildReplyRow(Comment comment, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 42, right: 4),
      child: Material(
        color: theme.colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (comment.replies.isNotEmpty) ...[
              for (int i = 0; i < comment.replies.length && i < 3; i++) ...[
                _buildSubReplyItem(comment.replies[i], comment, theme, i),
                if (i < comment.replies.length - 1 && i < 2)
                  Divider(
                    height: 0.3,
                    thickness: 0.3,
                    color: theme.colorScheme.outline.withOpacity(0.08),
                  ),
              ],
            ],
            // 显示更多回复
            if (comment.replyCount > 3 || 
                (comment.replies.isEmpty && comment.replyCount > 0)) ...[
              InkWell(
                onTap: () {
                  // 显示完整回复列表
                  _showFullReplies(comment);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: '共${comment.replyCount}条回复',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 构建子回复项
  Widget _buildSubReplyItem(Comment reply, Comment parent, ThemeData theme, int index) {
    return InkWell(
      onTap: () {
        // 点击子回复
      },
      onLongPress: () {
        // 长按子回复
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '回复操作',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('复制'),
                  onTap: () {
                    Navigator.pop(context);
                    // 复制回复内容
                  },
                ),
                ListTile(
                  title: const Text('举报'),
                  onTap: () {
                    Navigator.pop(context);
                    // 举报回复
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: index == 0 
            ? const EdgeInsets.fromLTRB(8, 8, 8, 4)
            : const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Text.rich(
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
            height: 1.6,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          TextSpan(
            children: [
              TextSpan(
                text: reply.username,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (reply.isUp) ...[
                const TextSpan(text: ' '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4, 
                      vertical: 1
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'UP',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' '),
              ],
              const TextSpan(text: ': '),
              TextSpan(
                text: reply.content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建操作行
  Widget _buildActionRow(Comment comment, ThemeData theme) {
    final ButtonStyle style = TextButton.styleFrom(
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
    
    return Row(
      children: [
        const SizedBox(width: 36),
        SizedBox(
          height: 32,
          child: TextButton(
            style: style,
            onPressed: () {
              // 回复评论
              _showReplyDialog(comment);
            },
            child: Row(
              children: [
                Icon(
                  Icons.reply,
                  size: 18,
                  color: theme.colorScheme.outline.withOpacity(0.8),
                ),
                const SizedBox(width: 3),
                Text(
                  '回复',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // 点踩按钮
        SizedBox(
          height: 32,
          child: TextButton(
            style: style,
            onPressed: () {
              _dislikeComment(comment);
            },
            child: Icon(
              _dislikeStates[comment.rpid] == true
                  ? Icons.thumb_down_alt
                  : Icons.thumb_down_outlined,
              size: 16,
              color: _dislikeStates[comment.rpid] == true
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
        ),
        // 点赞按钮
        SizedBox(
          height: 32,
          child: TextButton(
            style: style,
            onPressed: () {
              _likeComment(comment);
            },
            child: Row(
              children: [
                Icon(
                  _likeStates[comment.rpid] == true
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_outlined,
                  size: 16,
                  color: _likeStates[comment.rpid] == true
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  comment.likeCount.toString(),
                  style: TextStyle(
                    color: _likeStates[comment.rpid] == true
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  // 显示回复对话框
  void _showReplyDialog(Comment comment) {
    final TextEditingController replyController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: replyController,
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
                  ElevatedButton(
                    onPressed: () {
                      // 发送回复
                      Navigator.pop(context);
                    },
                    child: const Text('发送'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示完整回复列表
  void _showFullReplies(Comment rootComment) async {
    // 获取完整的楼中楼评论列表
    List<Comment> fullReplies = await _loadFullReplies(widget.aid, rootComment.rpid.toString());
    if (fullReplies.isEmpty) {
      fullReplies = rootComment.replies; // 如果获取失败，使用原始数据
    }
    
    // 显示该根评论的所有回复列表
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
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
              Expanded(
                child: ListView.builder(
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}