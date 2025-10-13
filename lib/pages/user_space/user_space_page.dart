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

class _UserSpacePageState extends State<UserSpacePage> {
  UserInfoData? _userInfo;
  List<VideoItem> _userVideos = [];
  bool _isLoading = false;
  bool _isLoadingVideos = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserVideos();
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
      appBar: AppBar(
        title: const Text('用户空间'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUserInfo,
          ),
        ],
      ),
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
                  ? RefreshIndicator(
                      onRefresh: () async => _refreshUserInfo(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 用户基本信息
                            _buildUserInfoHeader(),
                            const SizedBox(height: 16),
                            // 用户统计数据
                            _buildUserStats(),
                            const SizedBox(height: 16),
                            // 用户认证信息
                            if (_userInfo!.official != null &&
                                _userInfo!.official!.title != null &&
                                _userInfo!.official!.title!.isNotEmpty)
                              _buildOfficialInfo(),
                            const SizedBox(height: 16),
                            // VIP信息
                            if (_userInfo!.vip != null &&
                                _userInfo!.vip!.status == 1)
                              _buildVipInfo(),
                            const SizedBox(height: 16),
                            // 用户投稿视频
                            _buildUserVideos(),
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

  // 构建用户基本信息头部
  Widget _buildUserInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 用户头像
          CircleAvatar(
            radius: 40,
            backgroundImage: _userInfo!.face != null && _userInfo!.face!.isNotEmpty
                ? NetworkImage(_userInfo!.face!)
                : null,
            child: _userInfo!.face == null || _userInfo!.face!.isEmpty
                ? const Icon(Icons.account_circle, size: 80)
                : null,
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名和等级
                Row(
                  children: [
                    Text(
                      _userInfo!.name ?? '未知用户',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 用户等级
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LV${_userInfo!.level ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 用户签名
                Text(
                  _userInfo!.sign ?? '这个人很懒，什么都没有留下',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // 性别
                if (_userInfo!.sex != null && _userInfo!.sex!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _userInfo!.sex!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        Icon(icon, size: 24, color: Colors.grey),
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
                Expanded(
                  child: Text(
                    'B站大会员',
                    style: const TextStyle(
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

  // 构建用户投稿视频
  Widget _buildUserVideos() {
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
        ],
      ),
    );
  }

  // 构建单个视频项
  Widget _buildVideoItem(VideoItem video) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频封面
          AspectRatio(
            aspectRatio: 16 / 9,
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