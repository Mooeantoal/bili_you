import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';
import 'package:bili_you/common/models/local/video/video_play_item.dart';
import 'package:bili_you/common/models/local/video/audio_play_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class DebugVideoPage extends StatefulWidget {
  const DebugVideoPage({super.key});

  @override
  State<DebugVideoPage> createState() => _DebugVideoPageState();
}

class _DebugVideoPageState extends State<DebugVideoPage> {
  final TextEditingController _bvidController = TextEditingController();
  final TextEditingController _cidController = TextEditingController();
  String _videoInfoResult = '';
  String _playInfoResult = '';
  VideoPlayInfo? _videoPlayInfo;

  @override
  void initState() {
    super.initState();
    _bvidController.text = 'BV1joHwzBEJK';
    _cidController.text = '0';
  }

  Future<void> _loadVideoInfo() async {
    try {
      final bvid = _bvidController.text.trim();
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      
      setState(() {
        _videoInfoResult = '''
标题: ${videoInfo.title}
描述: ${videoInfo.describe}
BV号: ${videoInfo.bvid}
CID: ${videoInfo.cid}
UP主: ${videoInfo.ownerName}
播放数: ${videoInfo.playNum}
弹幕数: ${videoInfo.danmaukuNum}
点赞数: ${videoInfo.likeNum}
投币数: ${videoInfo.coinNum}
收藏数: ${videoInfo.favariteNum}
分P数量: ${videoInfo.parts.length}
''';
        
        // 如果CID为0，使用视频信息中的CID
        if (_cidController.text == '0') {
          _cidController.text = videoInfo.cid.toString();
        }
      });
      
      Get.snackbar('成功', '视频信息加载完成');
    } catch (e) {
      setState(() {
        _videoInfoResult = '加载视频信息失败: $e';
      });
      Get.snackbar('错误', '加载视频信息失败: $e');
    }
  }

  Future<void> _loadPlayInfo() async {
    try {
      final bvid = _bvidController.text.trim();
      final cid = int.parse(_cidController.text.trim());
      
      final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      
      setState(() {
        _videoPlayInfo = playInfo;
        _playInfoResult = '''
时长: ${playInfo.timeLength}秒
支持的视频质量数量: ${playInfo.supportVideoQualities.length}
支持的音频质量数量: ${playInfo.supportAudioQualities.length}
视频流数量: ${playInfo.videos.length}
音频流数量: ${playInfo.audios.length}
最后播放CID: ${playInfo.lastPlayCid}
最后播放时间: ${playInfo.lastPlayTime.inSeconds}秒
''';
      });
      
      Get.snackbar('成功', '播放信息加载完成');
    } catch (e) {
      setState(() {
        _playInfoResult = '加载播放信息失败: $e';
      });
      Get.snackbar('错误', '加载播放信息失败: $e');
    }
  }

  Future<void> _debugPlayUrls() async {
    if (_videoPlayInfo == null) {
      Get.snackbar('错误', '请先加载播放信息');
      return;
    }
    
    try {
      String debugInfo = '视频URL测试:\n';
      
      // 测试视频URL
      for (var i = 0; i < _videoPlayInfo!.videos.length && i < 3; i++) {
        final video = _videoPlayInfo!.videos[i];
        debugInfo += '\n视频流 ${i + 1}:\n';
        debugInfo += '质量: ${video.quality.description}\n';
        debugInfo += '编码: ${video.codecs}\n';
        debugInfo += '分辨率: ${video.width}x${video.height}\n';
        debugInfo += '帧率: ${video.frameRate}\n';
        debugInfo += 'URL数量: ${video.urls.length}\n';
        if (video.urls.isNotEmpty) {
          debugInfo += 'URL: ${video.urls.first}\n';
          
          // 测试URL是否可访问
          try {
            final response = await Dio().head(video.urls.first, options: Options(
              headers: VideoPlayApi.videoPlayerHttpHeaders,
            ));
            debugInfo += '状态码: ${response.statusCode}\n';
            debugInfo += 'Content-Type: ${response.headers['content-type']?.first ?? '未知'}\n';
          } catch (e) {
            debugInfo += '访问失败: $e\n';
          }
        } else {
          debugInfo += '错误: 没有可用的URL\n';
        }
      }
      
      // 测试音频URL
      debugInfo += '\n音频URL测试:\n';
      for (var i = 0; i < _videoPlayInfo!.audios.length && i < 3; i++) {
        final audio = _videoPlayInfo!.audios[i];
        debugInfo += '\n音频流 ${i + 1}:\n';
        debugInfo += '质量: ${audio.quality.description}\n';
        debugInfo += '编码: ${audio.codecs}\n';
        debugInfo += 'URL数量: ${audio.urls.length}\n';
        if (audio.urls.isNotEmpty) {
          debugInfo += 'URL: ${audio.urls.first}\n';
          
          // 测试URL是否可访问
          try {
            final response = await Dio().head(audio.urls.first, options: Options(
              headers: VideoPlayApi.videoPlayerHttpHeaders,
            ));
            debugInfo += '状态码: ${response.statusCode}\n';
            debugInfo += 'Content-Type: ${response.headers['content-type']?.first ?? '未知'}\n';
          } catch (e) {
            debugInfo += '访问失败: $e\n';
          }
        } else {
          debugInfo += '错误: 没有可用的URL\n';
        }
      }
      
      setState(() {
        _playInfoResult = debugInfo;
      });
      
      Get.snackbar('完成', 'URL调试信息已生成');
    } catch (e) {
      setState(() {
        _playInfoResult = '调试URL失败: $e';
      });
      Get.snackbar('错误', '调试URL失败: $e');
    }
  }

  Future<void> _testVideoPlayback() async {
    if (_videoPlayInfo == null) {
      Get.snackbar('错误', '请先加载播放信息');
      return;
    }
    
    try {
      String testResult = '播放测试:\n';
      
      String? selectedVideoUrl;
      String? selectedAudioUrl;
      
      if (_videoPlayInfo!.videos.isEmpty) {
        testResult += '错误: 没有可用的视频流\n';
      } else {
        testResult += '找到 ${_videoPlayInfo!.videos.length} 个视频流\n';
        for (var i = 0; i < _videoPlayInfo!.videos.length && i < 3; i++) {
          final video = _videoPlayInfo!.videos[i];
          testResult += '视频流 ${i + 1}: ${video.quality.description} (${video.codecs})\n';
        }
        
        // 尝试获取最佳视频流并测试URL
        final bestVideo = _videoPlayInfo!.videos.first;
        testResult += '\n最佳视频流:\n';
        testResult += '质量: ${bestVideo.quality.description}\n';
        
        if (bestVideo.urls.isNotEmpty) {
          testResult += '测试URL可访问性...\n';
          for (int i = 0; i < bestVideo.urls.length; i++) {
            final url = bestVideo.urls[i];
            testResult += 'URL ${i + 1}: ${url.substring(0, 50)}...\n';
            
            try {
              final response = await Dio().head(url, options: Options(
                headers: VideoPlayApi.videoPlayerHttpHeaders,
                receiveTimeout: const Duration(seconds: 10),
              ));
              testResult += '  状态码: ${response.statusCode}\n';
              if (response.statusCode == 200) {
                selectedVideoUrl = url;
                testResult += '  √ 选择此URL\n';
                break;
              }
            } catch (e) {
              testResult += '  × 访问失败: $e\n';
            }
          }
        } else {
          testResult += '错误: 没有可用的URL\n';
        }
      }
      
      if (_videoPlayInfo!.audios.isEmpty) {
        testResult += '警告: 没有可用的音频流\n';
      } else {
        testResult += '找到 ${_videoPlayInfo!.audios.length} 个音频流\n';
        for (var i = 0; i < _videoPlayInfo!.audios.length && i < 3; i++) {
          final audio = _videoPlayInfo!.audios[i];
          testResult += '音频流 ${i + 1}: ${audio.quality.description} (${audio.codecs})\n';
        }
        
        // 尝试获取最佳音频流并测试URL
        final bestAudio = _videoPlayInfo!.audios.first;
        testResult += '\n最佳音频流:\n';
        testResult += '质量: ${bestAudio.quality.description}\n';
        
        if (bestAudio.urls.isNotEmpty) {
          testResult += '测试URL可访问性...\n';
          for (int i = 0; i < bestAudio.urls.length; i++) {
            final url = bestAudio.urls[i];
            testResult += 'URL ${i + 1}: ${url.substring(0, 50)}...\n';
            
            try {
              final response = await Dio().head(url, options: Options(
                headers: VideoPlayApi.videoPlayerHttpHeaders,
                receiveTimeout: const Duration(seconds: 10),
              ));
              testResult += '  状态码: ${response.statusCode}\n';
              if (response.statusCode == 200) {
                selectedAudioUrl = url;
                testResult += '  √ 选择此URL\n';
                break;
              }
            } catch (e) {
              testResult += '  × 访问失败: $e\n';
            }
          }
        } else {
          testResult += '错误: 没有可用的URL\n';
        }
      }
      
      // 检查是否有支持的质量
      if (_videoPlayInfo!.supportVideoQualities.isEmpty) {
        testResult += '警告: 没有支持的视频质量\n';
      } else {
        testResult += '支持的视频质量: ${_videoPlayInfo!.supportVideoQualities.map((q) => q.description).join(', ')}\n';
      }
      
      if (_videoPlayInfo!.supportAudioQualities.isEmpty) {
        testResult += '警告: 没有支持的音频质量\n';
      } else {
        testResult += '支持的音频质量: ${_videoPlayInfo!.supportAudioQualities.map((q) => q.description).join(', ')}\n';
      }
      
      // 显示选中的URL
      if (selectedVideoUrl != null) {
        testResult += '\n选中的视频URL: ${selectedVideoUrl.substring(0, 100)}...\n';
      }
      if (selectedAudioUrl != null) {
        testResult += '\n选中的音频URL: ${selectedAudioUrl.substring(0, 100)}...\n';
      }
      
      setState(() {
        _playInfoResult = testResult;
      });
      
      Get.snackbar('完成', '播放测试完成');
    } catch (e) {
      setState(() {
        _playInfoResult = '播放测试失败: $e';
      });
      Get.snackbar('错误', '播放测试失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频调试工具'),
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
            TextField(
              controller: _cidController,
              decoration: const InputDecoration(
                labelText: 'CID',
                hintText: '例如: 123456',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loadVideoInfo,
                  child: const Text('加载视频信息'),
                ),
                ElevatedButton(
                  onPressed: _loadPlayInfo,
                  child: const Text('加载播放信息'),
                ),
                ElevatedButton(
                  onPressed: _debugPlayUrls,
                  child: const Text('调试URL'),
                ),
                ElevatedButton(
                  onPressed: _testVideoPlayback,
                  child: const Text('播放测试'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '视频信息:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_videoInfoResult),
                    const SizedBox(height: 16),
                    const Text(
                      '播放信息:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_playInfoResult),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}