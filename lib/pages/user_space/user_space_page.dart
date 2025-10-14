import 'package:flutter/material.dart';
import 'package:bili_you/common/models/network/user/user_info.dart';
import 'package:bili_you/common/api/user_info_api.dart';
import 'package:bili_you/common/api/user_videos_api.dart';

// 视频数据模型
class VideoItem {
  final String bvid;
  final String title;
  final String coverUrl;
  final int playCount;
  final int duration;
  final String publishTime;

  VideoItem({
    required this.bvid,
    required this.title,
    required this.coverUrl,
    required this.playCount,
    required this.duration,
    required this.publishTime,
  });
}

class UserSpacePage extends StatefulWidget {
  final String uid; // 用户UID

  const UserSpacePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserSpacePage> createState() => _UserSpacePageState();
}

class _UserSpacePageState extends State<UserSpacePage> with TickerProviderStateMixin {
  UserInfoData? _userInfo;
  List<VideoItem> _userVideos = [];
  bool _isLoading = false;
  bool _isLoadingVideos = false;
  String _errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 增加到4个标签页
    _loadUserInfo();
    _loadUserVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 加载用户信息
  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 使用API工具类获取用户信息
      final userInfo = await UserInfoApi.getUserInfo(uid: widget.uid);
      
      if (userInfo != null) {
        setState(() {
          _userInfo = userInfo;
        });
      } else {
        setState(() {
          _errorMessage = '获取用户信息失败';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '获取用户信息时出错: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 加载用户投稿视频
  Future<void> _loadUserVideos() async {
    setState(() {
      _isLoadingVideos = true;
    });

    try {
      // 使用API工具类获取用户投稿视频
      final videoData = await UserVideosApi.getUserVideos(uid: widget.uid);
      
      if (videoData != null && videoData['code'] == 0) {
        final List<VideoItem> videos = [];
        final vlist = videoData['data']['list']['vlist'];
        
        if (vlist != null && vlist is List) {
          for (var video in vlist) {
            if (video is Map<String, dynamic>) {
              videos.add(VideoItem(
                bvid: video['bvid']?.toString() ?? '',
                title: video['title']?.toString() ?? '无标题',
                coverUrl: video['pic']?.toString() ?? '',
                playCount: video['play'] is int ? video['play'] : 0,
                duration: video['duration'] is int ? video['duration'] : 0,
                publishTime: video['created'] is int 
                    ? DateTime.fromMillisecondsSinceEpoch(video['created'] * 1000)
                        .toString().split(' ')[0]
                    : '',
              ));
            }
          }
        }
        
        setState(() {
          _userVideos = videos;
        });
      }
    } catch (e) {
      // 视频加载失败不显示错误信息，因为这是可选功能
      print('获取用户投稿视频时出错: $e');
    } finally {
      setState(() {
        _isLoadingVideos = false;
      });
    }
  }

  // 刷新用户信息
  void _refreshUserInfo() {
    _loadUserInfo();
    _loadUserVideos();
  }

  // 格式化数字显示
  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else {
      return number.toString();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshUserInfo,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : _userInfo != null
                  ? DefaultTabController(
                      length: 4,
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            // 用户信息头部（固定在顶部）
                            _buildUserInfoHeader(),
                            // Tab栏
                            SliverPersistentHeader(
                              delegate: _SliverAppBarDelegate(
                                TabBar(
                                  controller: _tabController,
                                  tabs: const [
                                    Tab(text: '主页'),
                                    Tab(text: '投稿'),
                                    Tab(text: '收藏'),
                                    Tab(text: '动态'),
                                  ],
                                  indicatorColor: Colors.white,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white70,
                                ),
                              ),
                              pinned: true,
                            ),
                          ];
                        },
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            // 主页
                            _buildHomePageTab(),
                            // 投稿视频
                            _buildUserVideosTab(),
                            // 收藏内容
                            const Center(child: Text('收藏内容')),
                            // 动态内容
                            const Center(child: Text('动态内容')),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        '未获取到用户信息',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
    );
  }

  // 构建用户信息头部（使用SliverAppBar实现吸顶效果）
  Widget _buildUserInfoHeader() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 用户头像
              CircleAvatar(
                radius: 50,
                backgroundImage: _userInfo!.face != null && _userInfo!.face!.isNotEmpty
                    ? NetworkImage(_userInfo!.face!)
                    : null,
                child: _userInfo!.face == null || _userInfo!.face!.isEmpty
                    ? const Icon(Icons.account_circle, size: 100, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 16),
              // 用户名和等级
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userInfo!.name ?? '未知用户',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 用户等级
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LV${_userInfo!.level ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 关注和粉丝信息
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '关注 ${_formatNumber(_userInfo!.following ?? 0)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '粉丝 ${_formatNumber(_userInfo!.follower ?? 0)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 用户签名
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _userInfo!.sign ?? '这个人很懒，什么都没有留下',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 关注/取消关注逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('关注'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      // 发私信逻辑
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('发私信'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshUserInfo,
        ),
      ],
    );
  }

  // 构建主页标签页
  Widget _buildHomePageTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 认证信息
          if (_userInfo!.official != null &&
              _userInfo!.official!.title != null &&
              _userInfo!.official!.title!.isNotEmpty)
            _buildOfficialInfo(),
          // VIP信息
          if (_userInfo!.vip != null &&
              _userInfo!.vip!.status == 1)
            _buildVipInfo(),
          // 统计数据
          _buildUserStats(),
          // 最新投稿
          _buildRecentVideos(),
        ],
      ),
    );
  }

  // 构建认证信息
  Widget _buildOfficialInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '认证信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _userInfo!.official!.title!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建VIP信息
  Widget _buildVipInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VIP信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'B站大会员',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _userInfo!.vip!.dueDate != null
                      ? '到期时间: ${DateTime.fromMillisecondsSinceEpoch(_userInfo!.vip!.dueDate!).toString().split(' ')[0]}'
                      : '',
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
    );
  }

  // 构建用户统计数据
  Widget _buildUserStats() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '数据统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // 统计数据网格
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatItem(Icons.favorite, '获赞', _userInfo!.likeNum?.toString() ?? '0'),
              _buildStatItem(Icons.monetization_on, '硬币', _userInfo!.coins?.toString() ?? '0'),
              _buildStatItem(Icons.bar_chart, '等级', _userInfo!.level?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  // 构建统计数据项
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
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

  // 构建最新投稿
  Widget _buildRecentVideos() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '最新投稿',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 切换到投稿标签页
                  _tabController.animateTo(1);
                },
                child: const Text('查看更多'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 视频列表
          if (_userVideos.isEmpty && !_isLoadingVideos)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '暂无投稿视频',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _userVideos.length > 5 ? 5 : _userVideos.length, // 只显示前5个
                itemBuilder: (context, index) {
                  final video = _userVideos[index];
                  return _buildHorizontalVideoItem(video);
                },
              ),
            ),
        ],
      ),
    );
  }

  // 构建水平滚动的视频项
  Widget _buildHorizontalVideoItem(VideoItem video) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频封面
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  image: video.coverUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(video.coverUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: video.coverUrl.isEmpty
                    ? const Icon(Icons.video_library, size: 30, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 视频标题
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          // 播放量和时间
          Text(
            _formatNumber(video.playCount),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          Text(
            video.publishTime,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 构建用户投稿视频标签页
  Widget _buildUserVideosTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '投稿视频',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoadingVideos)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 视频列表
          if (_userVideos.isEmpty && !_isLoadingVideos)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '暂无投稿视频',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: _userVideos.length,
                itemBuilder: (context, index) {
                  final video = _userVideos[index];
                  return _buildVideoItem(video);
                },
              ),
            ),
        ],
      ),
    );
  }

  // 构建单个视频项
  Widget _buildVideoItem(VideoItem video) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频封面
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                decoration: BoxDecoration(
                  image: video.coverUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(video.coverUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: video.coverUrl.isEmpty
                    ? const Icon(Icons.video_library, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          // 视频信息
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 视频标题
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 播放量和时长
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatNumber(video.playCount),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _formatDuration(video.duration),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // 发布时间
                Text(
                  video.publishTime,
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
    );
  }
}

// 自定义SliverPersistentHeaderDelegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}