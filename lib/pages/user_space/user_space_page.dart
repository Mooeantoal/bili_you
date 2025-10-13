import 'package:flutter/material.dart';
import 'package:bili_you/common/models/network/user/user_info.dart';
import 'package:bili_you/common/api/user_info_api.dart';

class UserSpacePage extends StatefulWidget {
  final String uid; // 用户UID

  const UserSpacePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserSpacePage> createState() => _UserSpacePageState();
}

class _UserSpacePageState extends State<UserSpacePage> {
  UserInfoData? _userInfo;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  // 刷新用户信息
  void _refreshUserInfo() {
    _loadUserInfo();
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
}