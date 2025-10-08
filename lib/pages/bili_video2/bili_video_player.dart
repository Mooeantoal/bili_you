import 'dart:async';
import 'dart:io';

import 'package:bili_you/common/api/index.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';
import 'package:bili_you/pages/bili_video2/bili_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
    await state.player.stop();
    await Future.delayed(const Duration(milliseconds: 10));
    await state.player.open(
        Media(videoUrl, httpHeaders: VideoPlayApi.videoPlayerHttpHeaders),
        play: true);
    await state.player.setPlaylistMode(PlaylistMode.none);
    await Future.delayed(const Duration(milliseconds: 10));
    await state.player.setAudioTrack(AudioTrack.uri(audioUrl));
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