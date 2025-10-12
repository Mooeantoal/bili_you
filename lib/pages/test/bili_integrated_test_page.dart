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

  @override
  void initState() {
    super.initState();
    // 加载B站播放器
    _loadBiliPlayer();
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
      // Android官方edge-to-edge沉浸式方案
      extendBody: true,
      extendBodyBehindAppBar: true,
      // 去除标题栏（AppBar）
      appBar: null,
      body: Column(
        children: [
          // B站播放器区域
          _buildPlayerSection(),
          // 直接显示视频信息和评论，完全去掉内部导航栏
          Expanded(
            child: _buildContentSection(),
          ),
        ],
      ),
      // 移除重复的底部导航栏，使用应用级别的导航栏
    );
  }

  // 构建播放器区域
  Widget _buildPlayerSection() {
    return Container(
      // 向下移动一点点，避免与状态栏重叠
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
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

  // 构建内容区域（添加Tab组件来并列显示视频信息和评论）
  Widget _buildContentSection() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  // 构建视频详细信息（去除大片空白和标题）
  Widget _buildVideoInfoTab() {
    // 判断是BV号还是av号
    bool isBvid = videoId.startsWith('BV');
    return Container(
      // 减少padding，去除大片空白
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BiliVideoInfoPage(
        videoId: isBvid ? videoId : aid,
        isBvid: isBvid,
      ),
    );
  }

  // 构建评论（去除大片空白和标题）
  Widget _buildCommentsTab() {
    return Container(
      // 减少padding，去除大片空白
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BiliCommentsPage(
        videoId: videoId,
        aid: aid,
      ),
    );
  }
}