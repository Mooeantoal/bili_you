import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _startPlay() async {
    if (_cid == null) {
      Get.snackbar('错误', '请先加载视频信息');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '正在获取播放信息...';
      _debugInfo = '';
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
      if (bestAudio != null) {
        _updateDebugInfo('最佳音频质量: ${bestAudio.quality}');
        _updateDebugInfo('音频编码: ${bestAudio.codecs}');
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
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _cid == null ? null : _startPlay,
                    child: const Text('开始播放'),
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