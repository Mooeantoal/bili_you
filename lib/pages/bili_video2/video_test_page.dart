import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

class VideoTestPage extends StatefulWidget {
  const VideoTestPage({super.key});

  @override
  State<VideoTestPage> createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  final TextEditingController _bvidController = TextEditingController();
  bool _isLoading = false;
  String _status = '';
  String _debugInfo = '';
  late final BiliVideoPlayerCubit _cubit;
  int? _cid;
  bool _showPlayer = false;

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

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  Future<void> _loadVideoInfo() async {
    setState(() {
      _isLoading = true;
      _status = '正在加载视频信息...';
      _debugInfo = '';
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始加载视频信息，BV号: $bvid');
      
      // 获取视频信息
      _updateDebugInfo('正在获取视频信息...');
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
      _cid = videoInfo.cid;
      _updateDebugInfo('获取视频信息成功');
      _updateDebugInfo('视频标题: ${videoInfo.title}');
      _updateDebugInfo('CID: $videoInfo.cid');
      _updateDebugInfo('UP主: ${videoInfo.ownerName}');
      _updateDebugInfo('播放数: ${videoInfo.playNum}');
      _updateDebugInfo('弹幕数: ${videoInfo.danmaukuNum}');
      
      setState(() {
        _status = '视频信息加载成功';
        _isLoading = false;
      });
      
      Get.snackbar('成功', '视频信息加载成功');
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('加载视频信息失败: $e\n堆栈信息: $stackTrace');
      print('加载视频信息失败: $e\n堆栈信息: $stackTrace');
      Get.snackbar('错误', '加载视频信息失败: $e');
    }
  }

  Future<void> _testPlayUrlDirectly() async {
    if (_cid == null) {
      Get.snackbar('错误', '请先加载视频信息');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '正在直接测试播放URL...';
      _debugInfo = '';
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始直接测试播放URL，BV号: $bvid, CID: $_cid');
      
      // 直接使用Dio测试API
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: true));
      
      final headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Referer': 'https://www.bilibili.com/video/$bvid/',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'en-US,en;q=0.9',
      };
      
      _updateDebugInfo('请求头部: $headers');
      
      final response = await dio.get(
        'https://api.bilibili.com/x/player/playurl',
        queryParameters: {
          'bvid': bvid,
          'cid': _cid,
          'fnver': 0,
          'fnval': 4048,
          'fourk': 1,
          'force_host': 2,
          'try_look': 1,
          'voice_balance': 1,
          'gaia_source': 'pre-load',
          'isGaiaAvoided': true,
          'web_location': 1315873,
          'qn': 120,
          'otype': 'json',
          'platform': 'html5',
        },
        options: Options(headers: headers),
      );
      
      _updateDebugInfo('响应状态码: ${response.statusCode}');
      _updateDebugInfo('响应数据: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 0 && data['data'] != null) {
          final playData = data['data'];
          _updateDebugInfo('播放数据获取成功');
          
          // 检查DASH流
          if (playData['dash'] != null) {
            final dash = playData['dash'];
            _updateDebugInfo('DASH流信息:');
            
            // 视频流
            if (dash['video'] != null && dash['video'].isNotEmpty) {
              final videoStreams = dash['video'] as List;
              _updateDebugInfo('  视频流数量: ${videoStreams.length}');
              for (int i = 0; i < videoStreams.length && i < 3; i++) {
                final stream = videoStreams[i];
                _updateDebugInfo('  视频流 $i: ID=${stream['id']}, 编码=${stream['codecs']}, 带宽=${stream['bandwidth']}');
                _updateDebugInfo('    URL: ${stream['baseUrl']}');
              }
            } else {
              _updateDebugInfo('  没有视频流');
            }
            
            // 音频流
            if (dash['audio'] != null && dash['audio'].isNotEmpty) {
              final audioStreams = dash['audio'] as List;
              _updateDebugInfo('  音频流数量: ${audioStreams.length}');
              for (int i = 0; i < audioStreams.length && i < 3; i++) {
                final stream = audioStreams[i];
                _updateDebugInfo('  音频流 $i: ID=${stream['id']}, 编码=${stream['codecs']}, 带宽=${stream['bandwidth']}');
                _updateDebugInfo('    URL: ${stream['baseUrl']}');
              }
            } else {
              _updateDebugInfo('  没有音频流');
            }
          } else {
            _updateDebugInfo('没有DASH流信息');
          }
          
          setState(() {
            _status = '直接测试播放URL成功';
            _isLoading = false;
          });
          
          Get.snackbar('成功', '直接测试播放URL成功');
        } else {
          _updateDebugInfo('API返回错误: ${data['message']}');
          setState(() {
            _status = 'API错误: ${data['message']}';
            _isLoading = false;
          });
        }
      } else {
        _updateDebugInfo('HTTP错误: ${response.statusCode}');
        setState(() {
          _status = 'HTTP错误: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('直接测试播放URL失败: $e\n堆栈信息: $stackTrace');
      print('直接测试播放URL失败: $e\n堆栈信息: $stackTrace');
      Get.snackbar('错误', '直接测试播放URL失败: $e');
    }
  }

  Future<void> _startPlay() async {
    if (_cid == null) {
      Get.snackbar('错误', '请先加载视频信息');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '正在获取播放信息...';
      _debugInfo = '';
      _showPlayer = true;
    });

    try {
      final bvid = _bvidController.text.trim();
      _updateDebugInfo('开始播放视频，BV号: $bvid, CID: $_cid');
      
      // 获取播放信息
      _updateDebugInfo('正在获取播放信息...');
      final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: _cid!);
      _updateDebugInfo('获取播放信息成功');
      _updateDebugInfo('视频流数量: ${playInfo.videos.length}');
      _updateDebugInfo('音频流数量: ${playInfo.audios.length}');
      
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
      
      _updateDebugInfo('最佳视频质量: ${bestVideo.quality}');
      _updateDebugInfo('视频编码: ${bestVideo.codecs}');
      _updateDebugInfo('视频URL数量: ${bestVideo.urls.length}');
      if (bestVideo.urls.isNotEmpty) {
        _updateDebugInfo('第一个视频URL: ${bestVideo.urls.first}');
      }
      
      if (bestAudio != null) {
        _updateDebugInfo('最佳音频质量: ${bestAudio.quality}');
        _updateDebugInfo('音频编码: ${bestAudio.codecs}');
        _updateDebugInfo('音频URL数量: ${bestAudio.urls.length}');
        if (bestAudio.urls.isNotEmpty) {
          _updateDebugInfo('第一个音频URL: ${bestAudio.urls.first}');
        }
      }
      
      setState(() {
        _status = '正在开始播放...';
      });
      
      // 开始播放
      _updateDebugInfo('开始播放...');
      await _cubit.playMedia(
        bestVideo.urls, 
        bestAudio?.urls ?? [],
        refererBvid: bvid,
      );
      
      setState(() {
        _status = '播放已开始';
        _isLoading = false;
      });
      
      _updateDebugInfo('播放已开始');
      Get.snackbar('成功', '视频开始播放');
    } catch (e, stackTrace) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      _updateDebugInfo('播放失败: $e\n堆栈信息: $stackTrace');
      print('播放失败: $e\n堆栈信息: $stackTrace');
      Get.snackbar('错误', '播放失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放测试'),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loadVideoInfo,
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
                      : const Text('加载视频信息'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _cid == null ? null : _testPlayUrlDirectly,
                    child: const Text('直接测试URL'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _cid == null ? null : _startPlay,
                    child: const Text('开始播放'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPlayer = !_showPlayer;
                      });
                    },
                    child: Text(_showPlayer ? '隐藏播放器' : '显示播放器'),
                  ),
                ),
              ],
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
            if (_showPlayer)
              Expanded(
                flex: 3,
                child: BlocProvider.value(
                  value: _cubit,
                  child: BiliVideoPlayer(
                    bvid: _bvidController.text.trim(),
                    cid: _cid ?? 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}