import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:convert';

// 视频信息数据模型
class VideoInfo {
  final String title;
  final String desc;
  final String coverUrl;
  final int duration;
  final int viewCount;
  final int danmakuCount;
  final int commentCount;
  final int likeCount;
  final int coinCount;
  final int favoriteCount;
  final int shareCount;
  final String createTime;
  final int copyright;
  final Owner owner;
  final List<VideoPage> pages;

  VideoInfo({
    required this.title,
    required this.desc,
    required this.coverUrl,
    required this.duration,
    required this.viewCount,
    required this.danmakuCount,
    required this.commentCount,
    required this.likeCount,
    required this.coinCount,
    required this.favoriteCount,
    required this.shareCount,
    required this.createTime,
    required this.copyright,
    required this.owner,
    required this.pages,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    // 解析UP主信息
    Owner owner = Owner.fromJson(json['owner']);
    
    // 解析分P列表
    List<VideoPage> pages = [];
    if (json['pages'] != null) {
      for (var page in json['pages']) {
        pages.add(VideoPage.fromJson(page));
      }
    }
    
    return VideoInfo(
      title: json['title'] ?? '未知标题',
      desc: json['desc'] ?? '无简介',
      coverUrl: json['pic'] ?? '',
      duration: json['duration'] ?? 0,
      viewCount: json['stat']?['view'] ?? 0,
      danmakuCount: json['stat']?['danmaku'] ?? 0,
      commentCount: json['stat']?['reply'] ?? 0,
      likeCount: json['stat']?['like'] ?? 0,
      coinCount: json['stat']?['coin'] ?? 0,
      favoriteCount: json['stat']?['favorite'] ?? 0,
      shareCount: json['stat']?['share'] ?? 0,
      createTime: json['pubdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['pubdate'] * 1000)
              .toString()
              .substring(0, 19)
              .replaceFirst(' ', '\n')
          : '未知时间',
      copyright: json['copyright'] ?? 1,
      owner: owner,
      pages: pages,
    );
  }
}

// UP主信息数据模型
class Owner {
  final int mid; // UP主ID
  final String name; // UP主昵称
  final String face; // UP主头像URL

  Owner({
    required this.mid,
    required this.name,
    required this.face,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      mid: json['mid'] ?? 0,
      name: json['name'] ?? '未知UP主',
      face: json['face'] ?? '',
    );
  }
}

// 分P信息数据模型
class VideoPage {
  final int cid; // 分P的CID
  final int page; // 分P页码
  final String part; // 分P标题
  final int duration; // 分P时长(秒)

  VideoPage({
    required this.cid,
    required this.page,
    required this.part,
    required this.duration,
  });

  factory VideoPage.fromJson(Map<String, dynamic> json) {
    return VideoPage(
      cid: json['cid'] ?? 0,
      page: json['page'] ?? 1,
      part: json['part'] ?? 'P${json['page'] ?? 1}',
      duration: json['duration'] ?? 0,
    );
  }
}

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

class PipePipeFullTestPage extends StatefulWidget {
  const PipePipeFullTestPage({Key? key}) : super(key: key);

  @override
  State<PipePipeFullTestPage> createState() => _PipePipeFullTestPageState();
}

class _PipePipeFullTestPageState extends State<PipePipeFullTestPage>
    with SingleTickerProviderStateMixin {
  // 播放器相关
  late final Player player;
  late final VideoController videoController;
  final TextEditingController _urlController = TextEditingController();
  
  // 视频信息和评论数据
  VideoInfo? videoInfo;
  List<Comment> comments = [];
  List<Comment> hotComments = [];
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 1;
  int sortType = 0; // 0=按时间, 1=按点赞, 2=按回复
  bool hasMore = true; // 是否还有更多数据
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();
  
  // B站视频参数
  String videoId = 'BV1GJ411x7h7'; // 示例视频ID
  String cid = '190597915'; // 示例cid
  String aid = '928861104'; // 示例aid

  @override
  void initState() {
    super.initState();
    // 初始化播放器
    player = Player();
    videoController = VideoController(player);
    
    // 加载默认视频
    _loadVideo();
    _loadVideoInfo();
    _loadComments();
  }

  // 加载视频
  Future<void> _loadVideo() async {
    try {
      // 使用media_kit播放器加载视频
      await player.open(Media('https://www.bilibili.com/video/$videoId'), play: true);
    } catch (e) {
      setState(() {
        errorMessage = '加载视频失败: $e';
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    _urlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 跳转到指定视频
  void _jumpToVideo() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) return;

    // 解析输入的BV号或链接
    String bvId = '';
    
    // 如果是完整的B站链接
    if (input.contains('bilibili.com')) {
      // 提取BV号
      final bvRegex = RegExp(r'BV[0-9A-Za-z]+');
      final match = bvRegex.firstMatch(input);
      if (match != null) {
        bvId = match.group(0)!;
      }
    } 
    // 如果是BV号
    else if (input.startsWith('BV') && input.length > 5) {
      bvId = input;
    }
    
    if (bvId.isNotEmpty) {
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正在获取视频信息: $bvId')),
      );
      
      try {
        // 通过UAPI获取视频信息
        final videoInfoUrl = 'https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid=$bvId';
        final response = await _dio.get(videoInfoUrl);
        
        if (response.statusCode == 200) {
          final data = response.data;
          final aid = data['aid'].toString();
          final cid = data['cid'].toString();
          
          // 更新视频ID和相关信息并重新加载
          setState(() {
            videoId = bvId;
            this.aid = aid;
            this.cid = cid;
          });
          
          // 显示成功提示信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已切换到视频: $bvId')),
          );
          
          // 重新加载播放器
          _loadVideo();
          
          // 重新加载视频信息和评论
          _loadVideoInfo();
          _loadComments();
        } else {
          throw Exception('获取视频信息失败: ${response.statusMessage}');
        }
      } catch (e) {
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取视频信息时出错: $e')),
        );
        
        // 回滚状态
        setState(() {
          videoId = 'BV1GJ411x7h7'; // 恢复默认视频
          aid = '928861104';
          cid = '190597915';
        });
        _loadVideo();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的BV号或B站视频链接')),
      );
    }
  }

  // 加载视频详细信息
  Future<void> _loadVideoInfo() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 构建API请求URL
      final StringBuffer url = StringBuffer(
          'https://uapis.cn/api/v1/social/bilibili/videoinfo');
      
      // 添加参数
      url.write('?bvid=${videoId}');

      final response = await _dio.get(url.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data != null) {
          setState(() {
            videoInfo = VideoInfo.fromJson(data);
          });
        } else {
          setState(() {
            errorMessage = '未获取到视频信息';
          });
        }
      } else {
        setState(() {
          errorMessage = '获取视频信息失败: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '获取视频信息时出错: $e';
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
        '?oid=$aid'
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
            newComments.add(Comment.fromJson(commentJson));
          }
          
          setState(() {
            comments = newComments;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PipePipe完整测试页面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          // 添加输入框和跳转按钮
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: '输入BV号或视频链接',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _jumpToVideo,
                  child: const Text('跳转'),
                ),
              ],
            ),
          ),
          // 播放器区域
          _buildPlayerSection(),
          // 视频信息和评论区域
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab导航栏
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const TabBar(
                      tabs: [
                        Tab(text: '视频详情'),
                        Tab(text: '评论'),
                      ],
                    ),
                  ),
                  // Tab内容区域
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 视频详细信息
                        _buildVideoInfoTab(),
                        // 评论
                        _buildCommentsTab(),
                      ],
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

  // 构建播放器区域
  Widget _buildPlayerSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算容器的宽高比，使用16:9
          double aspectRatio = 16 / 9;
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;

          // 限制播放器的最大高度
          double maxPlayerHeight = MediaQuery.of(context).size.height * 0.4;

          // 根据容器尺寸计算合适的尺寸
          double containerWidth = maxWidth;
          double containerHeight = containerWidth / aspectRatio;

          // 如果计算出的高度超过最大高度，则以最大高度为准
          if (containerHeight > maxPlayerHeight) {
            containerHeight = maxPlayerHeight;
            containerWidth = containerHeight * aspectRatio;
          }

          // 如果计算出的高度超过最大高度，则以高度为准
          if (containerHeight > maxHeight) {
            containerHeight = maxHeight;
            containerWidth = containerHeight * aspectRatio;
          }

          return Center(
            child: Container(
              width: containerWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Video(
                controller: videoController,
                controls: (state) {
                  return Stack(
                    children: [
                      // 播放控制层
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            if (player.state.playing) {
                              player.pause();
                            } else {
                              player.play();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: Icon(
                                player.state.playing ? Icons.pause : Icons.play_arrow,
                                size: 60,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建视频详细信息
  Widget _buildVideoInfoTab() {
    if (videoInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频标题
            Text(
              videoInfo!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // UP主信息
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: videoInfo!.owner.face.isNotEmpty
                      ? NetworkImage(videoInfo!.owner.face)
                      : null,
                  child: videoInfo!.owner.face.isEmpty
                      ? const Icon(Icons.account_circle, size: 40)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoInfo!.owner.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'UID: ${videoInfo!.owner.mid}',
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
            const SizedBox(height: 12),
            // 视频统计信息
            _buildVideoStats(),
            const SizedBox(height: 12),
            // 视频简介
            const Text(
              '视频简介',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              videoInfo!.desc.isNotEmpty ? videoInfo!.desc : '无简介',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            // 分P列表
            if (videoInfo!.pages.isNotEmpty) ...[
              const Text(
                '分P列表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videoInfo!.pages.length,
                itemBuilder: (context, index) {
                  final page = videoInfo!.pages[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('P${page.page} ${page.part}'),
                      subtitle: Text(_formatDuration(page.duration)),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () {
                        // 切换到指定分P
                        setState(() {
                          cid = page.cid.toString();
                        });
                        _loadVideo();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('切换到分P: P${page.page} ${page.part}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 构建视频统计信息
  Widget _buildVideoStats() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '数据统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 统计数据网格
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildStatItem(Icons.play_arrow, '播放', videoInfo!.viewCount),
              _buildStatItem(
                  Icons.comment_outlined, '评论', videoInfo!.commentCount),
              _buildStatItem(Icons.thumb_up_outlined, '点赞', videoInfo!.likeCount),
              _buildStatItem(Icons.favorite_border, '收藏', videoInfo!.favoriteCount),
              _buildStatItem(Icons.attach_money, '投币', videoInfo!.coinCount),
              _buildStatItem(Icons.share, '分享', videoInfo!.shareCount),
              _buildStatItem(Icons.chat_bubble_outline, '弹幕', videoInfo!.danmakuCount),
            ],
          ),
        ],
      ),
    );
  }

  // 构建统计数据项
  Widget _buildStatItem(IconData icon, String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatNumber(count),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // 格式化时间显示
  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  // 格式化数字显示
  String _formatNumber(int number) {
    if (number >= 100000000) {
      return '${(number / 100000000).toStringAsFixed(1)}亿';
    } else if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else {
      return number.toString();
    }
  }

  // 构建评论Tab
  Widget _buildCommentsTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshComments(),
      child: ListView(
        controller: _scrollController,
        children: [
          // 排序按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
          ),
          // 热门评论
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
              _buildCommentItem(comment, isHot: true),
            const Divider(),
          ],
          // 普通评论
          if (comments.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '全部评论 (${comments.length})',
                style: const TextStyle(
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
    );
  }

  // 构建评论项
  Widget _buildCommentItem(Comment comment, {bool isHot = false}) {
    final theme = Theme.of(context);
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
              ...comment.replies.take(3).map((reply) => _buildReplyItem(reply)).toList(),
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
                    const Text(
                      ' 点赞',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
  Widget _buildReplyItem(Comment reply) {
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
    );
  }
}