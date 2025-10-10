import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '视频播放调试测试',
      home: const TestVideoDebugPage(),
    );
  }
}

class TestVideoDebugPage extends StatefulWidget {
  const TestVideoDebugPage({super.key});

  @override
  State<TestVideoDebugPage> createState() => _TestVideoDebugPageState();
}

class _TestVideoDebugPageState extends State<TestVideoDebugPage> {
  final TextEditingController _bvidController = TextEditingController(text: 'BV1joHwzBEJK');
  bool _isLoading = false;
  String _status = '';
  String _debugInfo = '';
  late final BiliVideoPlayerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BiliVideoPlayerCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    _bvidController.dispose();
    super.dispose();
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  Future<void> _testVideoInfo() async {
    setState(() {
      _isLoading = true;
      _status = '正在获取视频信息...';
      _debugInfo = '';
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始获取视频信息，BV号: $bvid');
      
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      _updateDebugInfo('获取视频信息成功');
      _updateDebugInfo('标题: ${videoInfo.title}');
      _updateDebugInfo('CID: ${videoInfo.cid}');
      _updateDebugInfo('分P数量: ${videoInfo.pages.length}');
      
      setState(() {
        _status = '视频信息获取成功';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('获取视频信息失败: $e\n堆栈信息: $stackTrace');
    }
  }

  Future<void> _testPlayUrl() async {
    setState(() {
      _isLoading = true;
      _status = '正在获取播放信息...';
      _debugInfo = '';
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始获取播放信息，BV号: $bvid');
      
      // 先获取视频信息以获得CID
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      final cid = videoInfo.cid;
      _updateDebugInfo('获取CID: $cid');
      
      // 获取播放信息
      final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      _updateDebugInfo('获取播放信息成功');
      _updateDebugInfo('视频流数量: ${playInfo.videos.length}');
      _updateDebugInfo('音频流数量: ${playInfo.audios.length}');
      
      if (playInfo.videos.isNotEmpty) {
        final video = playInfo.videos.first;
        _updateDebugInfo('最佳视频质量: ${video.quality}');
        _updateDebugInfo('视频编码: ${video.codecs}');
        _updateDebugInfo('视频URL数量: ${video.urls.length}');
        
        // 显示前几个URL
        for (int i = 0; i < video.urls.length && i < 3; i++) {
          _updateDebugInfo('视频URL $i: ${video.urls[i]}');
        }
      }
      
      if (playInfo.audios.isNotEmpty) {
        final audio = playInfo.audios.first;
        _updateDebugInfo('最佳音频质量: ${audio.quality}');
        _updateDebugInfo('音频编码: ${audio.codecs}');
        _updateDebugInfo('音频URL数量: ${audio.urls.length}');
        
        // 显示前几个URL
        for (int i = 0; i < audio.urls.length && i < 3; i++) {
          _updateDebugInfo('音频URL $i: ${audio.urls[i]}');
        }
      }
      
      setState(() {
        _status = '播放信息获取成功';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('获取播放信息失败: $e\n堆栈信息: $stackTrace');
    }
  }

  Future<void> _testUrlAccess() async {
    setState(() {
      _isLoading = true;
      _status = '正在测试URL访问...';
      _debugInfo = '';
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始测试URL访问，BV号: $bvid');
      
      // 先获取视频信息以获得CID
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      final cid = videoInfo.cid;
      _updateDebugInfo('获取CID: $cid');
      
      // 获取播放信息
      final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      
      if (playInfo.videos.isNotEmpty) {
        final video = playInfo.videos.first;
        _updateDebugInfo('测试视频URL访问');
        
        // 准备HTTP头部
        final headers = Map<String, String>.from(VideoPlayApi.videoPlayerHttpHeaders);
        headers['Referer'] = 'https://www.bilibili.com/video/$bvid/';
        headers['Range'] = 'bytes=0-';
        
        _updateDebugInfo('HTTP头部: $headers');
        
        // 测试前几个视频URL
        for (int i = 0; i < video.urls.length && i < 3; i++) {
          final url = video.urls[i];
          _updateDebugInfo('测试视频URL $i: $url');
          
          try {
            final dio = Dio();
            dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: true));
            
            final response = await dio.get(
              url,
              options: Options(
                headers: headers,
                receiveTimeout: const Duration(seconds: 15),
                responseType: ResponseType.bytes,
                followRedirects: false,
              ),
            );
            
            _updateDebugInfo('视频URL $i 响应状态: ${response.statusCode}');
            _updateDebugInfo('视频URL $i 响应头: ${response.headers.map}');
          } catch (e) {
            _updateDebugInfo('视频URL $i 测试失败: $e');
          }
        }
      }
      
      setState(() {
        _status = 'URL访问测试完成';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('URL访问测试失败: $e\n堆栈信息: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放调试测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _bvidController,
              decoration: const InputDecoration(
                labelText: 'BV号',
                hintText: '例如: BV1joHwzBEJK',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testVideoInfo,
                  child: const Text('测试视频信息'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testPlayUrl,
                  child: const Text('测试播放信息'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUrlAccess,
                  child: const Text('测试URL访问'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}