import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'bili_comments_page.dart';
import 'bili_video_info_page.dart';

class BiliIntegratedTestPage extends StatefulWidget {
  const BiliIntegratedTestPage({Key? key}) : super(key: key);

  @override
  State<BiliIntegratedTestPage> createState() => _BiliIntegratedTestPageState();
}

class _BiliIntegratedTestPageState extends State<BiliIntegratedTestPage>
    with SingleTickerProviderStateMixin {
  final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1')
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // 页面加载进度
        },
        onPageStarted: (String url) {
          // 页面开始加载
        },
        onPageFinished: (String url) {
          // 页面加载完成
        },
        onWebResourceError: (WebResourceError error) {
          // 资源加载错误
        },
      ),
    );

  // B站视频参数
  final String videoId = 'BV1GJ411x7h7'; // 示例视频ID
  final String cid = '190597915'; // 示例cid
  final String aid = '928861104'; // 示例aid
  bool usePCPlayer = false; // 是否使用PC端播放器样式
  late TabController _tabController;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });
    // 加载B站播放器
    _loadBiliPlayer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBiliPlayer() {
    // 根据选择使用PC端或移动端播放器
    final String playerBaseUrl = usePCPlayer
        ? 'https://player.bilibili.com/player.html' // PC端播放器
        : 'https://www.bilibili.com/blackboard/html5mobileplayer.html'; // 移动端播放器

    final String playerUrl =
        '$playerBaseUrl?bvid=$videoId&cid=$cid&page=1&autoplay=0';

    _controller.loadRequest(Uri.parse(playerUrl));
  }

  // 切换播放器样式
  void _togglePlayerStyle() {
    setState(() {
      usePCPlayer = !usePCPlayer;
    });
    _loadBiliPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B站播放器测试'),
        actions: [
          // 切换播放器样式按钮
          IconButton(
            icon: Icon(usePCPlayer ? Icons.phone_android : Icons.computer),
            onPressed: _togglePlayerStyle,
          ),
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBiliPlayer,
          ),
        ],
      ),
      body: Column(
        children: [
          // B站播放器区域
          _buildPlayerSection(),
          // Tab导航栏
          _buildTabBar(),
          // Tab内容区域
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
    );
  }

  // 构建播放器区域
  Widget _buildPlayerSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算容器的宽高比，使用16:9比例
          double aspectRatio = 16 / 9;
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;

          // 根据容器尺寸计算合适的尺寸
          double containerWidth = maxWidth;
          double containerHeight = containerWidth / aspectRatio;

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
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: WebViewWidget(controller: _controller),
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建Tab导航栏
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(Icons.info_outline),
          text: "简介",
        ),
        Tab(
          icon: Icon(Icons.comment),
          text: "评论",
        ),
        Tab(
          icon: Icon(Icons.video_library),
          text: "更多",
        ),
      ],
    );
  }

  // 构建Tab内容区域
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        // 视频详细信息页面
        _buildVideoInfoTab(),
        // 评论页面
        _buildCommentsTab(),
        // 更多内容页面
        _buildMoreTab(),
      ],
    );
  }

  // 构建视频详细信息Tab
  Widget _buildVideoInfoTab() {
    // 判断是BV号还是av号
    bool isBvid = videoId.startsWith('BV');
    return BiliVideoInfoPage(
      videoId: isBvid ? videoId : aid,
      isBvid: isBvid,
    );
  }

  // 构建评论Tab
  Widget _buildCommentsTab() {
    return BiliCommentsPage(
      videoId: videoId,
      aid: aid,
    );
  }

  // 构建更多Tab
  Widget _buildMoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '视频信息',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '视频ID:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(videoId),
                  const SizedBox(height: 16),
                  const Text(
                    'CID:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(cid),
                  const SizedBox(height: 16),
                  const Text(
                    'AID:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(aid),
                  const SizedBox(height: 16),
                  const Text(
                    '播放器样式:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(usePCPlayer ? 'PC端播放器' : '移动端播放器'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '操作说明',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• 点击顶部的电脑/手机图标可切换播放器样式'),
                  SizedBox(height: 8),
                  Text('• 点击刷新按钮可重新加载播放器'),
                  SizedBox(height: 8),
                  Text('• 在简介Tab中可查看视频详细信息'),
                  SizedBox(height: 8),
                  Text('• 在评论Tab中可查看视频评论'),
                  SizedBox(height: 8),
                  Text('• 在更多Tab中可查看视频参数信息'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}