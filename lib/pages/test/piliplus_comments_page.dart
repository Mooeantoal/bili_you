import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bili_you/common/api/piliplus_reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

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
  List<ReplyItem> comments = [];
  List<ReplyItem> hotComments = [];
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  String sortType = '0'; // 0=按时间, 1=按点赞, 2=按回复
  bool hasMore = true; // 是否还有更多数据
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 配置Dio
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
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
      
      // 使用新的API获取更多评论
      final replyInfo = await PiliPlusReplyApi.getReply(
        oid: '1559365249', // 使用指定视频的aid
        pageNum: currentPage,
        type: ReplyType.video,
        sort: _getReplySort(),
      );

      setState(() {
        comments.addAll(replyInfo.replies);
        hasMore = replyInfo.replies.isNotEmpty;
        isLoading = false;
      });
    } on Exception catch (e) {
      print('加载更多评论时出错: $e');
      
      setState(() {
        hasMore = false;
        isLoading = false;
        // 只有在还没有错误信息时才设置错误信息
        if (errorMessage.isEmpty) {
          errorMessage = e.toString().contains('服务器') ? e.toString() : '加载更多评论时出错，请稍后再试';
        }
      });
      // 回退页码
      setState(() {
        currentPage--;
      });
    } catch (e) {
      print('加载更多评论时出现未知错误: $e');
      
      setState(() {
        hasMore = false;
        isLoading = false;
        if (errorMessage.isEmpty) {
          errorMessage = '加载更多评论时出现未知错误，请稍后再试';
        }
      });
      // 回退页码
      setState(() {
        currentPage--;
      });
    }
  }

  // 获取排序类型
  ReplySort _getReplySort() {
    switch (sortType) {
      case '0':
        return ReplySort.time;
      case '1':
        return ReplySort.like;
      case '2':
        return ReplySort.reply;
      default:
        return ReplySort.like;
    }
  }

  // 加载评论数据
  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 使用新的API获取评论
      final replyInfo = await PiliPlusReplyApi.getReply(
        oid: '1559365249', // 使用指定视频的aid
        pageNum: currentPage,
        type: ReplyType.video,
        sort: _getReplySort(),
      );

      setState(() {
        comments = replyInfo.replies;
        hotComments = replyInfo.topReplies;
        isLoading = false;
      });
    } on Exception catch (e) {
      print('获取评论时出错: $e');
      setState(() {
        errorMessage = e.toString().contains('服务器') ? e.toString() : '获取评论时出错，请稍后再试';
        isLoading = false;
      });
    } catch (e) {
      print('获取评论时出现未知错误: $e');
      setState(() {
        errorMessage = '获取评论时出现未知错误，请稍后再试';
        isLoading = false;
      });
    }
  }

  // 加载完整的楼中楼评论列表
  Future<List<ReplyItem>> _loadFullReplies(String oid, int rootId) async {
    try {
      // 使用新的API获取完整的楼中楼评论
      final replyReplyInfo = await PiliPlusReplyApi.getReplyReply(
        oid: oid,
        rootId: rootId,
        pageNum: 1,
        pageSize: 20,
      );

      return replyReplyInfo.replies;
    } on Exception catch (e) {
      print('获取完整楼中楼评论时出错: $e');
      // 显示错误信息给用户
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取回复列表失败: ${e.toString()}')),
        );
      }
    } catch (e) {
      print('获取完整楼中楼评论时出现未知错误: $e');
      // 显示错误信息给用户
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取回复列表时出现未知错误，请稍后再试')),
        );
      }
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
  void _changeSortType(String newSortType) {
    setState(() {
      sortType = newSortType;
      currentPage = 1;
      hasMore = true;
      comments.clear();
      hotComments.clear();
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
                          // 热门评论标识
                          if (comment.tags.contains('热评'))
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
              ...comment.preReplies.take(3).map((reply) => _buildReplyItem(reply, onTap: () {
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

  // 构建楼中楼回复项
  Widget _buildReplyItem(ReplyItem reply, {VoidCallback? onTap}) {
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
      ),
    );
  }

  // 显示楼中楼评论详情（显示该评论的所有回复列表）
  void _showReplyDetail(ReplyItem reply) async {
    // 查找包含该回复的根评论
    ReplyItem? rootComment;
    for (var comment in comments) {
      // 遍历每个根评论的回复，查找匹配的回复
      for (var r in comment.preReplies) {
        // 通过比较rpid来判断是否是同一个回复
        if (r.rpid == reply.rpid) {
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
                      backgroundImage: reply.member.avatarUrl.isNotEmpty
                          ? NetworkImage(reply.member.avatarUrl)
                          : null,
                      child: reply.member.avatarUrl.isEmpty
                          ? const Icon(Icons.account_circle, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatTime(reply.replyTime),
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
                  reply.content.message,
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
    List<ReplyItem> fullReplies = await _loadFullReplies('1559365249', rootComment.rpid);
    if (fullReplies.isEmpty) {
      fullReplies = rootComment.preReplies; // 如果获取失败，使用原始数据
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
                    backgroundImage: rootComment!.member.avatarUrl.isNotEmpty
                        ? NetworkImage(rootComment.member.avatarUrl)
                        : null,
                    child: rootComment.member.avatarUrl.isEmpty
                        ? const Icon(Icons.account_circle, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rootComment.member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatTime(rootComment.replyTime),
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
                rootComment.content.message,
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
                        color: replyItem.rpid == reply.rpid ? Colors.blue[50] : Colors.grey[100],
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
                                backgroundImage: replyItem.member.avatarUrl.isNotEmpty
                                    ? NetworkImage(replyItem.member.avatarUrl)
                                    : null,
                                child: replyItem.member.avatarUrl.isEmpty
                                    ? const Icon(Icons.account_circle, size: 32)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                replyItem.member.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(replyItem.replyTime),
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
                            replyItem.content.message,
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}