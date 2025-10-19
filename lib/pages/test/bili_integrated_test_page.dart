import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'bili_comments_page.dart';
import 'bili_video_info_page.dart';
import 'comments_test_page.dart';
import 'api_test_page.dart'; // 添加API测试页面导入

class BiliIntegratedTestPage extends StatefulWidget {
  const BiliIntegratedTestPage({Key? key}) : super(key: key);

  @override
  State<BiliIntegratedTestPage> createState() => _BiliIntegratedTestPageState();
}

class _BiliIntegratedTestPageState extends State<BiliIntegratedTestPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller = WebViewController()
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
        onPageFinished: (String url) async {
          // 页面加载完成
          // 确保播放器默认暂停
          try {
            await _controller.runJavaScript('document.querySelector("video").pause();');
          } catch (e) {
            // 忽略错误，因为页面可能还没有完全加载
          }
        },
        onWebResourceError: (WebResourceError error) {
          // 资源加载错误
        },
      ),
    );

  // B站视频参数
  String videoId = 'BV1GJ411x7h7'; // 示例视频ID
  String cid = '190597915'; // 示例cid
  String aid = '928861104'; // 示例aid
  bool usePCPlayer = false; // 是否使用PC端播放器样式
  final TextEditingController _urlController = TextEditingController();

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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // 切换播放器样式
  void _togglePlayerStyle() {
    setState(() {
      usePCPlayer = !usePCPlayer;
    });
    _loadBiliPlayer();
  }

  // 跳转到指定视频
  void _jumpToVideo() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) return;

    // 解析输入的BV号或链接
    String bvId = '';
    
    // 如果是完整的B站链接
    if (input.contains('bilibili.com')) {
      // 提取BV号
      final bvRegex = RegExp(r'BV[0-9A-Za-z]+');
      final match = bvRegex.firstMatch(input);
      if (match != null) {
        bvId = match.group(0)!;
      }
    } 
    // 如果是BV号
    else if (input.startsWith('BV') && input.length > 5) {
      bvId = input;
    }
    
    if (bvId.isNotEmpty) {
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正在获取视频信息: $bvId')),
      );
      
      try {
        // 通过UAPI获取视频信息
        final videoInfoUrl = 'https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid=$bvId';
        final dio = Dio();
        final response = await dio.get(videoInfoUrl);
        
        if (response.statusCode == 200) {
          final data = response.data;
          final aid = data['aid'].toString();
          final cid = data['cid'].toString();
          
          // 更新视频ID和相关信息并重新加载
          setState(() {
            videoId = bvId;
            this.aid = aid;
            this.cid = cid;
          });
          
          // 显示成功提示信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已切换到视频: $bvId')),
          );
          
          // 重新加载播放器
          _loadBiliPlayer();
        } else {
          throw Exception('获取视频信息失败: ${response.statusMessage}');
        }
      } catch (e) {
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取视频信息时出错: $e')),
        );
        
        // 回滚状态
        setState(() {
          videoId = 'BV1GJ411x7h7'; // 恢复默认视频
          aid = '928861104';
          cid = '190597915';
        });
        _loadBiliPlayer();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的BV号或B站视频链接')),
      );
    }
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
          // 添加输入框和跳转按钮
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: '输入BV号或视频链接',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _jumpToVideo,
                      child: const Text('跳转'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 添加测试PiliPlus评论页面的按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CommentsTestPage(),
                            ),
                          );
                        },
                        child: const Text('测试PiliPlus评论页面'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 添加API测试页面的按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApiTestPage(),
                            ),
                          );
                        },
                        child: const Text('测试PiliPlus API'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // B站播放器区域，使用SafeArea避免与状态栏重叠
          SafeArea(
            bottom: false, // 只避免顶部状态栏重叠，底部不需要
            child: _buildPlayerSection(),
          ),
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
      // 移除手动设置的padding，使用SafeArea来处理状态栏重叠
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算容器的宽高比，使用更紧凑的比例
          // 原来是16:9，现在调整为16:10或更小，以节省垂直空间
          double aspectRatio = 16 / 10; // 从16:9改为16:10，减少高度
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;

          // 限制播放器的最大高度，避免占用过多垂直空间
          double maxPlayerHeight = MediaQuery.of(context).size.height * 0.25; // 最大高度为屏幕高度的25%

          // 根据容器尺寸计算合适的尺寸
          double containerWidth = maxWidth;
          double containerHeight = containerWidth / aspectRatio;

          // 如果计算出的高度超过最大高度，则以最大高度为准
          if (containerHeight > maxPlayerHeight) {
            containerHeight = maxPlayerHeight;
            containerWidth = containerHeight * aspectRatio;
          }

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
        onPageSelected: (String newCid) {
          // 切换到指定分P并刷新播放器
          setState(() {
            cid = newCid;
          });
          _loadBiliPlayer();
          
          // 显示提示信息
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已切换到选中的分P视频')),
          );
        },
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