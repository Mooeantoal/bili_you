import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'bili_comments_page.dart';

class BiliPlayerTestPage extends StatefulWidget {
  const BiliPlayerTestPage({Key? key}) : super(key: key);

  @override
  State<BiliPlayerTestPage> createState() => _BiliPlayerTestPageState();
}

class _BiliPlayerTestPageState extends State<BiliPlayerTestPage> {
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
  final String videoId = 'BV1uT4y1P7CX'; // 示例视频ID
  final String cid = '287639008'; // 示例cid
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B站播放器测试'),
        actions: [
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
                  'B站官方播放器测试',
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
    );
  }
}