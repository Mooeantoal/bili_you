import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'bili_comments_page.dart';
import 'bili_video_info_page.dart';
import 'bili_player_test.dart';
import 'bili_player_advanced.dart';
import 'bili_web_player_test.dart';
import 'pipepipe_player_page.dart';
import 'pipepipe_bilibili_player_page.dart';
import 'pipepipe_native_player_page.dart';
import 'pipepipe_full_test_page.dart';

class NavigationTestPage extends StatefulWidget {
  const NavigationTestPage({Key? key}) : super(key: key);

  @override
  State<NavigationTestPage> createState() => _NavigationTestPageState();
}

class _NavigationTestPageState extends State<NavigationTestPage> {
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

  // B站视频ID，可以是aid或bvid
  final String videoId = 'BV1GJ411x7h7'; // 示例视频ID
  final String cid = '190597915'; // 示例cid
  final String aid = '928861104'; // 示例aid (需要根据实际视频获取)
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
        ? 'https://player.bilibili.com/player.html'  // PC端播放器
        : 'https://www.bilibili.com/blackboard/html5mobileplayer.html';  // 移动端播放器
    
    final String playerUrl = 
        '$playerBaseUrl?bvid=$videoId&cid=$cid&page=1&autoplay=0';
    
    _controller.loadRequest(Uri.parse(playerUrl));
  }

  // 查看评论
  void _viewComments() {
    Get.to(() => BiliCommentsPage(videoId: videoId, aid: aid));
  }

  // 查看视频详细信息
  void _viewVideoInfo() {
    // 判断是BV号还是av号
    bool isBvid = videoId.startsWith('BV');
    Get.to(() => BiliVideoInfoPage(videoId: isBvid ? videoId : aid, isBvid: isBvid));
  }

  // 跳转到基础播放器测试页面
  void _goToBasicPlayer() {
    Get.to(() => const BiliPlayerTestPage());
  }

  // 跳转到高级播放器测试页面
  void _goToAdvancedPlayer() {
    Get.to(() => const BiliPlayerAdvancedPage());
  }

  // 跳转到网页播放器测试页面
  void _goToWebPlayer() {
    Get.to(() => const BiliWebPlayerTestPage());
  }

  // 跳转到PipePipe播放器页面
  void _goToPipePipePlayer() {
    Get.to(() => const PipePipePlayerPage());
  }

  // 跳转到PipePipe Bilibili播放器页面
  void _goToPipePipeBilibiliPlayer() {
    Get.to(() => const PipePipeBilibiliPlayerPage());
  }

  // 跳转到PipePipe原生播放器页面
  void _goToPipePipeNativePlayer() {
    Get.to(() => const PipePipeNativePlayerPage());
  }

  // 跳转到PipePipe完整测试页面
  void _goToPipePipeFullTest() {
    Get.to(() => const PipePipeFullTestPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B站播放器'),
        actions: [
          // 查看视频详细信息按钮
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _viewVideoInfo,
          ),
          // 查看评论按钮
          IconButton(
            icon: const Icon(Icons.comment),
            onPressed: _viewComments,
          ),
          // 切换播放器样式按钮
          IconButton(
            icon: Icon(usePCPlayer ? Icons.phone_android : Icons.computer),
            onPressed: () {
              setState(() {
                usePCPlayer = !usePCPlayer;
              });
              _loadBiliPlayer();
            },
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
          // 视频信息
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'B站官方播放器',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('视频ID: $videoId'),
                Text('CID: $cid'),
                Text('AID: $aid'),
                const SizedBox(height: 8),
                Text(
                  '播放器样式: ${usePCPlayer ? "PC端" : "移动端"}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '说明：点击左上角图标可在PC端和移动端播放器样式间切换',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // 播放器选择按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _goToBasicPlayer,
                      child: const Text('基础播放器'),
                    ),
                    ElevatedButton(
                      onPressed: _goToAdvancedPlayer,
                      child: const Text('高级播放器'),
                    ),
                    ElevatedButton(
                      onPressed: _goToWebPlayer,
                      child: const Text('网页播放器'),
                    ),
                    ElevatedButton(
                      onPressed: _goToPipePipePlayer,
                      child: const Text('PipePipe播放器'),
                    ),
                    ElevatedButton(
                      onPressed: _goToPipePipeBilibiliPlayer,
                      child: const Text('PipePipe Bilibili'),
                    ),
                    ElevatedButton(
                      onPressed: _goToPipePipeNativePlayer,
                      child: const Text('PipePipe原生'),
                    ),
                    ElevatedButton(
                      onPressed: _goToPipePipeFullTest,
                      child: const Text('PipePipe完整'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 分割线
          const Divider(),
          // 使用改进代码0.2版本的响应式播放器容器
          Expanded(
            child: Container(
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        // 去除蓝色遮罩，使用透明背景
        color: Colors.transparent,
        height: 60 + MediaQuery.of(context).padding.bottom,
        child: const Center(
          child: Text(
            '底部导航栏',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      ),
    );
  }
}