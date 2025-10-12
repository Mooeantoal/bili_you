import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'bili_comments_page.dart';
import 'bili_video_info_page.dart';

class BiliPlayerAdvancedPage extends StatefulWidget {
  const BiliPlayerAdvancedPage({Key? key}) : super(key: key);

  @override
  State<BiliPlayerAdvancedPage> createState() => _BiliPlayerAdvancedPageState();
}

class _BiliPlayerAdvancedPageState extends State<BiliPlayerAdvancedPage> {
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
  String videoId = 'BV1GJ411x7h7'; // 视频ID
  String cid = '190597915'; // 视频CID
  String aid = '928861104'; // 视频AID
  bool autoPlay = false; // 自动播放
  bool danmaku = true; // 弹幕开关
  bool muted = false; // 静音
  bool usePCPlayer = false; // 是否使用PC端播放器样式

  @override
  void initState() {
    super.initState();
    // 加载B站播放器
    _loadBiliPlayer();
  }

  void _loadBiliPlayer() {
    // 构建播放器URL参数
    final StringBuffer params = StringBuffer();
    params.write('?bvid=$videoId');
    params.write('&cid=$cid');
    params.write('&page=1');
    params.write('&autoplay=${autoPlay ? 1 : 0}');
    params.write('&danmaku=${danmaku ? 1 : 0}');
    params.write('&muted=${muted ? 1 : 0}');
    
    // 根据选择使用PC端或移动端播放器
    final String playerBaseUrl = usePCPlayer 
        ? 'https://player.bilibili.com/player.html'  // PC端播放器
        : 'https://www.bilibili.com/blackboard/html5mobileplayer.html';  // 移动端播放器
    
    final String playerUrl = '$playerBaseUrl$params';
    
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('播放器设置'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 视频ID输入
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '视频ID (BV号或av号)',
                    ),
                    controller: TextEditingController(text: videoId),
                    onChanged: (value) {
                      videoId = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  // CID输入
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'CID',
                    ),
                    controller: TextEditingController(text: cid),
                    onChanged: (value) {
                      cid = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  // AID输入
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'AID',
                    ),
                    controller: TextEditingController(text: aid),
                    onChanged: (value) {
                      aid = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 自动播放开关
                  SwitchListTile(
                    title: const Text('自动播放'),
                    value: autoPlay,
                    onChanged: (value) {
                      setState(() {
                        autoPlay = value;
                      });
                    },
                  ),
                  // 弹幕开关
                  SwitchListTile(
                    title: const Text('弹幕'),
                    value: danmaku,
                    onChanged: (value) {
                      setState(() {
                        danmaku = value;
                      });
                    },
                  ),
                  // 静音开关
                  SwitchListTile(
                    title: const Text('静音'),
                    value: muted,
                    onChanged: (value) {
                      setState(() {
                        muted = value;
                      });
                    },
                  ),
                  // 播放器样式选择
                  SwitchListTile(
                    title: const Text('使用PC端播放器'),
                    value: usePCPlayer,
                    onChanged: (value) {
                      setState(() {
                        usePCPlayer = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadBiliPlayer();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B站播放器(高级版)'),
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
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
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
          // 视频信息和控制面板
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
                  '说明：在设置中可切换PC端和移动端播放器样式',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // 快捷控制按钮
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        autoPlay = !autoPlay;
                        _loadBiliPlayer();
                      },
                      icon: Icon(autoPlay ? Icons.pause : Icons.play_arrow),
                      label: Text(autoPlay ? '暂停' : '播放'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        danmaku = !danmaku;
                        _loadBiliPlayer();
                      },
                      icon: const Icon(Icons.chat_bubble),
                      label: Text(danmaku ? '关闭弹幕' : '开启弹幕'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        muted = !muted;
                        _loadBiliPlayer();
                      },
                      icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
                      label: Text(muted ? '取消静音' : '静音'),
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
    );
  }
}