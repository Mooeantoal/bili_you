import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// 视频详细信息数据模型
class VideoInfo {
  final String title; // 视频标题
  final String desc; // 视频描述
  final String coverUrl; // 封面图片URL
  final int duration; // 视频时长(秒)
  final int viewCount; // 播放量
  final int danmakuCount; // 弹幕数
  final int commentCount; // 评论数
  final int likeCount; // 点赞数
  final int coinCount; // 投币数
  final int favoriteCount; // 收藏数
  final int shareCount; // 分享数
  final String createTime; // 创建时间
  final int copyright; // 版权类型 (1原创, 2转载)
  final Owner owner; // UP主信息
  final List<VideoPage> pages; // 分P列表

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

class BiliVideoInfoPage extends StatefulWidget {
  final String videoId; // BV号或av号
  final bool isBvid; // 是否为BV号

  const BiliVideoInfoPage({
    Key? key,
    required this.videoId,
    required this.isBvid,
  }) : super(key: key);

  @override
  State<BiliVideoInfoPage> createState() => _BiliVideoInfoPageState();
}

class _BiliVideoInfoPageState extends State<BiliVideoInfoPage> {
  VideoInfo? videoInfo;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVideoInfo();
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
      
      // 根据ID类型添加参数
      if (widget.isBvid) {
        url.write('?bvid=${widget.videoId}');
      } else {
        url.write('?aid=${widget.videoId}');
      }

      // 使用Dio发送请求
      final Dio dio = Dio();
      final response = await dio.get(url.toString());

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

  // 刷新视频信息
  void _refreshVideoInfo() {
    _loadVideoInfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频详细信息'),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshVideoInfo,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshVideoInfo,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : videoInfo != null
                  ? RefreshIndicator(
                      onRefresh: () async => _refreshVideoInfo(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 视频封面和基本信息
                            _buildVideoHeader(),
                            // 视频统计信息
                            _buildVideoStats(),
                            // UP主信息
                            _buildOwnerInfo(),
                            // 视频描述
                            _buildVideoDesc(),
                            // 分P列表
                            _buildVideoPages(),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        '未获取到视频信息',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
    );
  }

  // 构建视频头部信息
  Widget _buildVideoHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频封面
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              videoInfo!.coverUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 视频标题
          Text(
            videoInfo!.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 视频时长和创建时间
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(videoInfo!.duration),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                videoInfo!.createTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: videoInfo!.copyright == 1
                        ? Colors.green
                        : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  videoInfo!.copyright == 1 ? '原创' : '转载',
                  style: TextStyle(
                    fontSize: 12,
                    color: videoInfo!.copyright == 1
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建视频统计信息
  Widget _buildVideoStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          const SizedBox(height: 12),
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
        Icon(
          icon,
          size: 24,
          color: Colors.grey,
        ),
        const SizedBox(height: 4),
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

  // 构建UP主信息
  Widget _buildOwnerInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UP主信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // UP主卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // UP主头像
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: videoInfo!.owner.face.isNotEmpty
                        ? NetworkImage(videoInfo!.owner.face)
                        : null,
                    child: videoInfo!.owner.face.isEmpty
                        ? const Icon(Icons.account_circle, size: 48)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // UP主名称
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
                        const SizedBox(height: 4),
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
            ),
          ),
        ],
      ),
    );
  }

  // 构建视频描述
  Widget _buildVideoDesc() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

  // 构建分P列表
  Widget _buildVideoPages() {
    if (videoInfo!.pages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    // TODO: 实现跳转到指定分P播放
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('点击了分P视频'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}