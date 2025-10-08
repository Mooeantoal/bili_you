import 'dart:async';

import 'package:bili_you/common/api/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:dio/dio.dart';

class PlayerSingleton {
  static final PlayerSingleton _instance = PlayerSingleton._internal();
  factory PlayerSingleton() => _instance;
  PlayerSingleton._internal() {
    player = Player();
    videoController = VideoController(player);
  }

  late final Player player;
  late final VideoController videoController;
}

//播放器状态
class BiliVideoPlayerState {
  BiliVideoPlayerState() {
    player = PlayerSingleton().player;
    videoController = PlayerSingleton().videoController;
  }
  late final Player player;
  late final VideoController videoController;
  StreamSubscription<bool>? _completedSubsciption;
  bool isLoop = false;
}

//播放器逻辑
class BiliVideoPlayerCubit extends Cubit<BiliVideoPlayerState> {
  BiliVideoPlayerCubit() : super(BiliVideoPlayerState());

  void playMedia(String videoUrl, String audioUrl) async {
    try {
      await state.player.stop();
      await Future.delayed(const Duration(milliseconds: 10));
      
      // 使用单个媒体源，同时包含视频和音频轨道
      await state.player.open(
        Media(
          videoUrl,
          httpHeaders: VideoPlayApi.videoPlayerHttpHeaders,
        ),
        play: true,
      );
      
      await state.player.setPlaylistMode(PlaylistMode.none);
      
      // 延迟设置音频轨道，确保视频已加载
      await Future.delayed(const Duration(milliseconds: 200));
      if (audioUrl.isNotEmpty) {
        try {
          await state.player.setAudioTrack(AudioTrack.uri(audioUrl));
        } catch (audioError) {
          print('设置音频轨道失败: $audioError');
        }
      }
      
      //防止上一个subsciption还没有释放掉
      if (state._completedSubsciption != null) {
        state._completedSubsciption!.cancel();
        state._completedSubsciption = null;
      }
      state._completedSubsciption =
          state.player.stream.completed.listen((event) async {
        if (event) {
          await state.player.seek(Duration.zero); //结束后回到起点
          await Future.delayed(const Duration(milliseconds: 20));
          if (state.isLoop) {
            await state.player.play();
          } else {
            await state.player.pause();
          }
        }
      });
    } catch (e) {
      print('播放媒体时出错: $e');
    }
  }

  // 添加一个方法来测试和选择可用的URL
  Future<String?> selectValidUrl(List<String> urls) async {
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

  Future<void> playMediaWithUrlTesting(String videoUrl, String audioUrl) async {
    try {
      await state.player.stop();
      await Future.delayed(const Duration(milliseconds: 10));
      
      // 使用单个媒体源，同时包含视频和音频轨道
      await state.player.open(
        Media(
          videoUrl,
          httpHeaders: VideoPlayApi.videoPlayerHttpHeaders,
        ),
        play: true,
      );
      
      await state.player.setPlaylistMode(PlaylistMode.none);
      
      // 延迟设置音频轨道，确保视频已加载
      await Future.delayed(const Duration(milliseconds: 200));
      if (audioUrl.isNotEmpty) {
        try {
          await state.player.setAudioTrack(AudioTrack.uri(audioUrl));
        } catch (audioError) {
          print('设置音频轨道失败: $audioError');
        }
      }
      
      //防止上一个subsciption还没有释放掉
      if (state._completedSubsciption != null) {
        state._completedSubsciption!.cancel();
        state._completedSubsciption = null;
      }
      state._completedSubsciption =
          state.player.stream.completed.listen((event) async {
        if (event) {
          await state.player.seek(Duration.zero); //结束后回到起点
          await Future.delayed(const Duration(milliseconds: 20));
          if (state.isLoop) {
            await state.player.play();
          } else {
            await state.player.pause();
          }
        }
      });
    } catch (e) {
      print('播放媒体时出错: $e');
    }
  }

  Future<void> dispose() async {
    await state.player.stop();
    await state._completedSubsciption?.cancel();
    state._completedSubsciption = null;
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }
}

//播放器界面
class BiliVideoPlayer extends StatefulWidget {
  const BiliVideoPlayer({super.key});

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BiliVideoPlayerCubit, BiliVideoPlayerState>(
      listener: (context, state) {
        // 监听状态变化
      },
      builder: (context, state) {
        return Video(
          controller: state.videoController,
          controls: (videoState) {
            return Stack(
              children: [
                // 确保视频画面显示
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black,
                  ),
                ),
                // 播放控制按钮
                Center(
                  child: IconButton(
                    icon: Icon(
                      state.player.state.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () {
                      if (state.player.state.playing) {
                        state.player.pause();
                      } else {
                        state.player.play();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}