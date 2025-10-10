import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

// 添加日志工具
import 'dart:developer' as developer;

class DebugVideoTestPage extends StatefulWidget {
  const DebugVideoTestPage({super.key});

  @override
  State<DebugVideoTestPage> createState() => _DebugVideoTestPageState();
}

class _DebugVideoTestPageState extends State<DebugVideoTestPage> {
  final TextEditingController _bvidController = TextEditingController();
  bool _isLoading = false;
  String _status = '';
  String _debugInfo = '';
  late final BiliVideoPlayerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _bvidController.text = 'BV1joHwzBEJK';
    _cubit = BiliVideoPlayerCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    _bvidController.dispose();
    super.dispose();
  }

  // 测试URL是否有效（使用GET请求而不是HEAD）
  Future<bool> _testUrl(String url, Map<String, String> headers) async {
    try {
      developer.log('测试URL: $url', name: 'DebugVideoTestPage._testUrl');
      _updateDebugInfo('测试URL: $url');
      
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: true));
      
      // 先尝试连接测试
      final headResponse = await dio.head(
        url,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 10),
          followRedirects: true,
        ),
      );
      
      final headValid = headResponse.statusCode == 200;
      developer.log('HEAD请求结果: ${headResponse.statusCode}', name: 'DebugVideoTestPage._testUrl');
      _updateDebugInfo('HEAD请求结果: ${headResponse.statusCode}, 有效: $headValid');
      
      if (headValid) {
        // HEAD请求成功，再测试小范围GET请求
        final getResponse = await dio.get(
          url,
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(seconds: 15),
            responseType: ResponseType.bytes,
            followRedirects: true,
          ),
        );
        
        final getValid = getResponse.statusCode == 200 || getResponse.statusCode == 206;
        developer.log('GET请求结果: ${getResponse.statusCode}, 内容长度: ${getResponse.data.length}', name: 'DebugVideoTestPage._testUrl');
        _updateDebugInfo('GET请求结果: ${getResponse.statusCode}, 内容长度: ${getResponse.data.length}, 有效: $getValid');
        
        return getValid;
      }
      
      return false;
    } catch (e, stackTrace) {
      developer.log('测试URL失败: $e', name: 'DebugVideoTestPage._testUrl', error: e, stackTrace: stackTrace);
      _updateDebugInfo('测试URL失败: $e');
      return false;
    }
  }

  // 选择有效的URL
  Future<String?> _selectValidUrl(List<String> urls, Map<String, String> headers) async {
    if (urls.isEmpty) {
      _updateDebugInfo('URL列表为空');
      return null;
    }
    
    _updateDebugInfo('开始测试 ${urls.length} 个URL');
    
    // 按顺序测试所有URL，直到找到有效的
    for (int i = 0; i < urls.length; i++) {
      _updateDebugInfo('尝试URL $i: ${urls[i]}');
      if (await _testUrl(urls[i], headers)) {
        _updateDebugInfo('选择URL $i: ${urls[i]}');
        return urls[i];
      }
    }
    
    // 如果所有URL都失败，返回null
    _updateDebugInfo('所有URL测试失败');
    return null;
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  Future<void> _testPlay() async {
    setState(() {
      _isLoading = true;
      _status = '正在加载视频信息...';
      _debugInfo = '';
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始测试播放，BV号: $bvid');
      
      // 验证BV号
      if (bvid.isEmpty) {
        setState(() {
          _status = '错误: BV号不能为空';
          _isLoading = false;
        });
        _updateDebugInfo('错误: BV号不能为空');
        return;
      }
      
      // 获取视频信息
      _updateDebugInfo('正在获取视频信息...');
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      final cid = videoInfo.cid;
      _updateDebugInfo('获取视频信息成功，CID: $cid');
      
      setState(() {
        _status = '正在获取播放信息...';
      });
      
      // 获取播放信息
      _updateDebugInfo('正在获取播放信息...');
      final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      _updateDebugInfo('获取播放信息成功，视频流数量: ${playInfo.videos.length}, 音频流数量: ${playInfo.audios.length}');
      
      if (playInfo.videos.isEmpty) {
        setState(() {
          _status = '错误: 没有可用的视频流';
          _isLoading = false;
        });
        _updateDebugInfo('错误: 没有可用的视频流');
        return;
      }
      
      // 显示视频和音频信息
      final bestVideo = playInfo.videos.first;
      final bestAudio = playInfo.audios.isNotEmpty ? playInfo.audios.first : null;
      
      _updateDebugInfo('最佳视频质量: ${bestVideo.quality}, 编码: ${bestVideo.codecs}');
      if (bestAudio != null) {
        _updateDebugInfo('最佳音频质量: ${bestAudio.quality}, 编码: ${bestAudio.codecs}');
      }
      
      setState(() {
        _status = '正在测试URL有效性...';
      });
      
      // 准备HTTP头部信息
      final headers = Map<String, String>.from(VideoPlayApi.videoPlayerHttpHeaders);
      headers['Referer'] = 'https://www.bilibili.com/video/$bvid/';
      headers['Range'] = 'bytes=0-';
      
      _updateDebugInfo('HTTP头部信息: $headers');
      
      // 选择有效的视频URL
      _updateDebugInfo('正在测试视频URL...');
      String? selectedVideoUrl = await _selectValidUrl(bestVideo.urls, headers);
      if (selectedVideoUrl == null) {
        setState(() {
          _status = '错误: 无法找到可用的视频URL';
          _isLoading = false;
        });
        _updateDebugInfo('错误: 无法找到可用的视频URL');
        return;
      }
      
      _updateDebugInfo('选中的视频URL: $selectedVideoUrl');
      
      setState(() {
        _status = '正在测试音频URL...';
      });
      
      // 选择有效的音频URL
      String? selectedAudioUrl;
      if (bestAudio != null && bestAudio.urls.isNotEmpty) {
        _updateDebugInfo('正在测试音频URL...');
        selectedAudioUrl = await _selectValidUrl(bestAudio.urls, headers);
        if (selectedAudioUrl != null) {
          _updateDebugInfo('选中的音频URL: $selectedAudioUrl');
        } else {
          _updateDebugInfo('警告: 无法找到有效的音频URL，将仅播放视频');
        }
      }
      
      setState(() {
        _status = '正在开始播放...';
      });
      
      // 开始播放
      _updateDebugInfo('开始播放...');
      await _cubit.playMedia(
        [selectedVideoUrl], 
        selectedAudioUrl != null ? [selectedAudioUrl] : [],
        refererBvid: bvid,
      );
      
      setState(() {
        _status = '播放已开始\n视频URL: ${selectedVideoUrl.substring(0, 50)}...\n音频URL: ${selectedAudioUrl?.substring(0, 50) ?? "无"}...';
        _isLoading = false;
      });
      
      _updateDebugInfo('播放已开始');
      Get.snackbar('成功', '视频开始播放');
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('播放测试失败: $e\n堆栈信息: $stackTrace');
      print('播放测试失败: $e\n堆栈信息: $stackTrace');
      Get.snackbar('错误', '播放失败: $e');
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
            ElevatedButton(
              onPressed: _isLoading ? null : _testPlay,
              child: _isLoading 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('加载中...'),
                    ],
                  )
                : const Text('开始测试播放'),
            ),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
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
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: BlocProvider.value(
                value: _cubit,
                child: const BiliVideoPlayer(
                  bvid: 'BV1joHwzBEJK', // 默认BV号
                  cid: 0, // 默认CID
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}