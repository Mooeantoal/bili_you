import 'package:bili_you/common/api/video_play_api.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/pages/bili_video2/bili_video_player.dart';
import 'package:bili_you/common/models/local/video/video_play_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '视频播放测试',
      home: TestVideoPlayPage(),
    );
  }
}

class TestVideoPlayPage extends StatefulWidget {
  @override
  _TestVideoPlayPageState createState() => _TestVideoPlayPageState();
}

class _TestVideoPlayPageState extends State<TestVideoPlayPage> {
  late BiliVideoPlayerCubit _cubit;
  final TextEditingController _bvidController = TextEditingController(text: 'BV1joHwzBEJK');
  bool _isLoading = false;
  String _status = '';

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

  Future<void> _testVideoPlay() async {
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
      
      if (playInfo.videos.isEmpty) {
        setState(() {
          _status = '错误: 没有可用的视频流';
          _isLoading = false;
        });
        return;
      }
      
      // 选择最佳视频和音频URL
      final bestVideo = playInfo.videos.first;
      final bestAudio = playInfo.audios.isNotEmpty ? playInfo.audios.first : null;
      
      setState(() {
        _status = '正在开始播放...';
      });
      
      // 开始播放
      await _cubit.playMedia(
        bestVideo.urls, 
        bestAudio?.urls ?? [],
        refererBvid: bvid,
      );
      
      setState(() {
        _status = '播放已开始\n视频质量: ${bestVideo.quality}\n视频编码: ${bestVideo.codecs}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '错误: $e';
        _isLoading = false;
      });
      print('播放测试失败: $e');
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
            ElevatedButton(
              onPressed: _isLoading ? null : _testVideoPlay,
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
              child: BlocProvider.value(
                value: _cubit,
                child: BlocConsumer<BiliVideoPlayerCubit, BiliVideoPlayerState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return Stack(
                      children: [
                        // 视频播放器
                        Video(
                          controller: state.videoController,
                          controls: (videoState) {
                            return Container(); // 不使用默认控件
                          },
                        ),
                        
                        // 自定义播放控制层
                        Positioned.fill(
                          child: BlocBuilder<BiliVideoPlayerCubit, BiliVideoPlayerState>(
                            builder: (context, state) {
                              return Stack(
                                children: [
                                  // 黑色背景确保视频显示
                                  const ColoredBox(color: Colors.black),
                                  
                                  // 缓冲指示器
                                  if (state.isBuffering)
                                    const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  
                                  // 播放控制按钮
                                  Center(
                                    child: IconButton(
                                      icon: Icon(
                                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                      onPressed: () {
                                        if (state.isPlaying) {
                                          context.read<BiliVideoPlayerCubit>().pause();
                                        } else {
                                          context.read<BiliVideoPlayerCubit>().play();
                                        }
                                      },
                                    ),
                                  ),
                                  
                                  // 状态显示
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Text(
                                      '播放状态: ${state.isPlaying ? "播放中" : "已暂停"}\n'
                                      '缓冲状态: ${state.isBuffering ? "缓冲中" : "就绪"}\n'
                                      '位置: ${state.position.inSeconds}秒\n'
                                      '时长: ${state.duration.inSeconds}秒',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  
                                  // 错误提示
                                  if (state.duration == Duration.zero && !state.isBuffering)
                                    const Center(
                                      child: Text(
                                        '无法加载视频',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}