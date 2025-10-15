import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BiliWebPlayerTestPage extends StatefulWidget {
  const BiliWebPlayerTestPage({Key? key}) : super(key: key);

  @override
  State<BiliWebPlayerTestPage> createState() => _BiliWebPlayerTestPageState();
}

class _BiliWebPlayerTestPageState extends State<BiliWebPlayerTestPage> {
  final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
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

  // B站视频ID
  final String videoId = 'BV1uT4y1P7CX'; // 示例视频ID

  @override
  void initState() {
    super.initState();
    // 加载B站视频页面
    _loadBiliVideoPage();
  }

  void _loadBiliVideoPage() {
    // 直接加载B站视频页面，支持完整的功能包括画质调整
    final String videoUrl = 'https://www.bilibili.com/video/$videoId';
    _controller.loadRequest(Uri.parse(videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B站网页播放器测试'),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBiliVideoPage,
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
                  'B站网页播放器测试',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('视频ID: $videoId'),
                const SizedBox(height: 8),
                const Text(
                  '说明：此播放器为完整的B站网页版，支持所有功能包括画质调整',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          // 分割线
          const Divider(),
          // WebView容器
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}