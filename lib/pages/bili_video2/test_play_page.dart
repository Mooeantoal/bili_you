import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class TestPlayPage extends StatefulWidget {
  const TestPlayPage({super.key});

  @override
  State<TestPlayPage> createState() => _TestPlayPageState();
}

class _TestPlayPageState extends State<TestPlayPage> {
  final TextEditingController _bvidController = TextEditingController();
  bool _isLoading = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _bvidController.text = 'BV1joHwzBEJK';
  }

  Future<String?> _selectValidUrl(List<String> urls) async {
    if (urls.isEmpty) return null;
    
    // 首先尝试第一个URL
    try {
      final response = await Dio().head(urls.first, options: Options(
        headers: VideoPlayApi.videoPlayerHttpHeaders,
        receiveTimeout: const Duration(seconds: 10),
      ));
      if (response.statusCode == 200) {
        return urls.first;
      }
    } catch (e) {
      print('测试URL失败: $e');
    }
    
    // 如果第一个URL失败，尝试备用URL
    for (int i = 1; i < urls.length; i++) {
      try {
        final response = await Dio().head(urls[i], options: Options(
          headers: VideoPlayApi.videoPlayerHttpHeaders,
          receiveTimeout: const Duration(seconds: 10),
        ));
        if (response.statusCode == 200) {
          return urls[i];
        }
      } catch (e) {
        print('测试备用URL失败: $e');
      }
    }
    
    // 如果所有URL都失败，返回第一个URL（让播放器尝试处理）
    return urls.first;
  }

  Future<void> _testPlay() async {
    setState(() {
      _isLoading = true;
      _status = '正在加载视频信息...';
    });

    try {
      final bvid = _bvidController.text.trim();
      
      // 获取视频信息
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      final cid = videoInfo.cid;
      
      setState(() {
        _status = '正在获取播放信息...';
      });
      
      // 获取播放信息
      final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      
      if (playInfo.videos.isEmpty || playInfo.audios.isEmpty) {
        setState(() {
          _status = '错误: 没有可用的视频或音频流';
          _isLoading = false;
        });
        return;
      }
      
      // 选择最佳视频和音频URL
      final bestVideo = playInfo.videos.first;
      final bestAudio = playInfo.audios.first;
      
      String? selectedVideoUrl;
      String? selectedAudioUrl;
      
      setState(() {
        _status = '正在测试视频URL...';
      });
      
      // 测试视频URL
      selectedVideoUrl = await _selectValidUrl(bestVideo.urls);
      if (selectedVideoUrl == null) {
        setState(() {
          _status = '错误: 无法找到可用的视频URL';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _status = '正在测试音频URL...';
      });
      
      // 测试音频URL
      selectedAudioUrl = await _selectValidUrl(bestAudio.urls);
      
      setState(() {
        _status = '正在开始播放...';
      });
      
      // 开始播放
      context.read<BiliVideoPlayerCubit>().playMedia(selectedVideoUrl, selectedAudioUrl ?? '');
      
      setState(() {
        _status = '播放已开始\n视频URL: ${selectedVideoUrl!.substring(0, 50)}...\n音频URL: ${selectedAudioUrl?.substring(0, 50) ?? "无"}...';
        _isLoading = false;
      });
      
      Get.snackbar('成功', '视频开始播放');
    } catch (e) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      Get.snackbar('错误', '播放失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放测试'),
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
            const Expanded(
              child: BiliVideoPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}