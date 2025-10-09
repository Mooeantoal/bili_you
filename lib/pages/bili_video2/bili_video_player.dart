import 'dart:async';
import 'dart:io';

import 'package:bili_you/common/api/index.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:dio/dio.dart';

// 播放器状态
class BiliVideoPlayerState {
  BiliVideoPlayerState() {
    player = Player();
    videoController = VideoController(player);
  }
  
  late final Player player;
  late final VideoController videoController;
  StreamSubscription<bool>? _completedSubscription;
  bool isLoop = false;
  bool isPlaying = false;
  bool isBuffering = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
}

// 播放器逻辑
class BiliVideoPlayerCubit extends Cubit<BiliVideoPlayerState> {
  BiliVideoPlayerCubit() : super(BiliVideoPlayerState()) {
    // 初始化播放器事件监听
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    // 监听播放状态变化
    state.player.stream.playing.listen((playing) {
      state.isPlaying = playing;
      emit(state);
    });
    
    // 监听缓冲状态
    state.player.stream.buffering.listen((buffering) {
      state.isBuffering = buffering;
      emit(state);
    });
    
    // 监听位置变化
    state.player.stream.position.listen((position) {
      state.position = position;
      emit(state);
    });
    
    // 监听时长变化
    state.player.stream.duration.listen((duration) {
      state.duration = duration;
      emit(state);
    });
    
    // 监听播放完成
    state._completedSubscription = state.player.stream.completed.listen((completed) {
      if (completed) {
        // 播放完成后的处理
        if (state.isLoop) {
          state.player.seek(Duration.zero);
          state.player.play();
        }
      }
    });
  }

  // 测试URL是否有效
  Future<bool> _testUrl(String url) async {
    try {
      print('测试URL: $url');
      final response = await Dio().get(
        url,
        options: Options(
          headers: VideoPlayApi.videoPlayerHttpHeaders,
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.bytes, // 只获取头部信息
          followRedirects: false, // 不跟随重定向
        ),
      );
      print('URL测试结果: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 206; // 206是部分内容，也表示成功
    } catch (e) {
      print('测试URL失败: $e');
      return false;
    }
  }

  // 选择有效的URL
  Future<String?> selectValidUrl(List<String> urls) async {
    if (urls.isEmpty) return null;
    
    // 首先尝试第一个URL
    if (await _testUrl(urls.first)) {
      return urls.first;
    }
    
    // 如果第一个URL失败，尝试备用URL
    for (int i = 1; i < urls.length; i++) {
      if (await _testUrl(urls[i])) {
        return urls[i];
      }
    }
    
    // 如果所有URL都失败，返回第一个URL作为备选
    return urls.first;
  }

  // 播放媒体
  Future<void> playMedia(List<String> videoUrls, List<String> audioUrls, {String? refererBvid}) async {
    try {
      print('视频URL列表: $videoUrls');
      print('音频URL列表: $audioUrls');
      
      // 停止当前播放
      await state.player.stop();
      
      // 选择有效的视频URL
      String? videoUrl = await selectValidUrl(videoUrls);
      if (videoUrl == null) {
        print('没有找到有效的视频URL');
        return;
      }
      
      // 选择有效的音频URL
      String? audioUrl;
      if (audioUrls.isNotEmpty) {
        audioUrl = await selectValidUrl(audioUrls);
      }
      
      print('使用视频URL: $videoUrl');
      if (audioUrl != null) {
        print('使用音频URL: $audioUrl');
      }
      
      // 创建媒体对象，添加更多HTTP头部信息以符合Bilibili的要求
      final headers = Map<String, String>.from(VideoPlayApi.videoPlayerHttpHeaders);
      // 确保Referer正确设置
      if (refererBvid != null) {
        headers['Referer'] = 'https://www.bilibili.com/video/$refererBvid/';
      }
      headers['Range'] = 'bytes=0-'; // 添加Range头部
      
      print('HTTP头部信息: $headers');
      
      final media = Media(
        videoUrl,
        httpHeaders: headers,
      );
      
      // 打开媒体
      print('正在打开媒体...');
      await state.player.open(
        media,
        play: true,
      );
      print('媒体打开成功');
      
      // 设置播放列表模式
      await state.player.setPlaylistMode(PlaylistMode.none);
      
      // 如果有音频URL，设置音频轨道
      if (audioUrl != null && audioUrl.isNotEmpty) {
        try {
          print('正在设置音频轨道...');
          // 延迟设置音频轨道，确保视频已加载
          await Future.delayed(const Duration(milliseconds: 500));
          await state.player.setAudioTrack(AudioTrack.uri(audioUrl));
          print('音频轨道设置成功');
        } catch (audioError) {
          print('设置音频轨道失败: $audioError');
        }
      }
      
    } catch (e) {
      print('播放媒体时出错: $e');
    }
  }

  // 暂停播放
  Future<void> pause() async {
    await state.player.pause();
  }

  // 继续播放
  Future<void> play() async {
    await state.player.play();
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    await state.player.seek(position);
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    await state.player.setVolume(volume);
  }

  // 设置静音
  Future<void> setMute(bool mute) async {
    await state.player.setVolume(mute ? 0.0 : 1.0);
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    await state.player.setRate(speed);
  }

  // 释放资源
  Future<void> dispose() async {
    await state.player.stop();
    await state._completedSubscription?.cancel();
    state._completedSubscription = null;
    await state.player.dispose();
  }

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }
}

// 播放器界面
class BiliVideoPlayer extends StatefulWidget {
  final String bvid;
  final int cid;

  const BiliVideoPlayer({
    super.key,
    required this.bvid,
    required this.cid,
  });

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  late final BiliVideoPlayerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BiliVideoPlayerCubit();
    // 加载并播放视频
    _loadAndPlayVideo();
  }

  Future<void> _loadAndPlayVideo() async {
    try {
      // 获取视频播放URL
      final videoPlayInfo = await VideoPlayApi.getVideoPlay(
        bvid: widget.bvid,
        cid: widget.cid,
      );
      
      if (videoPlayInfo.videos.isNotEmpty) {
        // 获取所有视频URL
        final videoUrls = videoPlayInfo.videos.first.urls;
        // 获取所有音频URL
        final audioUrls = videoPlayInfo.audios.isNotEmpty 
            ? videoPlayInfo.audios.first.urls 
            : <String>[];
        
        // 播放媒体
        await _cubit.playMedia(videoUrls, audioUrls, refererBvid: widget.bvid);
      } else {
        print('没有找到可用的视频流');
      }
    } catch (e) {
      print('加载视频失败: $e');
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<BiliVideoPlayerCubit, BiliVideoPlayerState>(
        listener: (context, state) {
          // 监听状态变化
        },
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
    );
  }
}