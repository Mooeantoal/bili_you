import 'package:bili_you/common/models/local/video/audioplayitem.dart';
import 'package:bili_you/common/models/local/video/videoplayinfo.dart';
import 'package:bili_you/common/models/local/video/videoplayitem.dart';
import 'package:bili_you/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediakit/mediakit.dart';

class BiliVideoPlayerCubit extends Cubit<BiliVideoPlayerState> {
  final VideoPlayInfo videoPlayInfo;
  VideoPlayItem videoPlayItem;
  final AudioPlayItem? audioPlayItem;
  VideoController? _videoController;

  BiliVideoPlayerCubit({
    required this.videoPlayInfo,
    required this.videoPlayItem,
    this.audioPlayItem,
  }) : super(BiliVideoPlayerState.initial());

  // 初始化视频控制器
  Future<void> initializeController() async {
    final videoController = VideoController(
      VideoPlayerController.networkUrl(
        Uri.parse(videoPlayItem.urls[VideoQuality.auto]!),
      ),
    );
    
    await videoController.initialize();
    _videoController = videoController;
    
    // 监听播放位置
    videoController.position.listen((position) {
      if (!state.isDragging) {
        emit(state.copyWith(position: position));
      }
    });
    
    // 监听缓冲位置
    videoController.buffered.listen((buffered) {
      emit(state.copyWith(bufferedPosition: buffered));
    });
    
    // 监听播放完成
    videoController.completed.listen((_) {
      emit(state.copyWith(isPlaying: false));
    });
    
    emit(state.copyWith(
      isInitialized: true,
      duration: videoController.value.duration,
    ));
  }

  // 播放/暂停切换
  void togglePlayPause() {
    if (_videoController == null) return;
    
    if (state.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  // 开始拖动进度条
  void startDragging() {
    emit(state.copyWith(isDragging: true));
  }

  // 更新拖动位置
  void updateDragPosition(Duration position) {
    emit(state.copyWith(dragPosition: position));
  }

  // 结束拖动
  void endDragging() {
    if (_videoController == null) return;
    
    _videoController!.seekTo(state.dragPosition);
    emit(state.copyWith(
      isDragging: false,
      position: state.dragPosition,
    ));
  }

  // 切换弹幕显示
  void toggleDanmaku() {
    emit(state.copyWith(showDanmaku: !state.showDanmaku));
  }

  // 更新弹幕设置
  void updateDanmakuSettings({
    double? fontSize,
    double? opacity,
    double? showArea,
  }) {
    emit(state.copyWith(
      danmakuFontSize: fontSize ?? state.danmakuFontSize,
      danmakuOpacity: opacity ?? state.danmakuOpacity,
      danmakuShowArea: showArea ?? state.danmakuShowArea,
    ));
  }

  // 切换画质
  void changeQuality(VideoPlayItem newItem) {
    videoPlayItem = newItem;
    emit(state.copyWith(
      videoPlayItem: newItem,
      quality: newItem.quality,
    ));
    
    // 重新初始化控制器
    _videoController?.dispose();
    initializeController();
  }

  // 更新视频适配模式
  void updateFit(VideoFit fit) {
    emit(state.copyWith(fit: fit));
  }

  // 更新宽高比
  void updateAspectRatio(double aspectRatio) {
    emit(state.copyWith(aspectRatio: aspectRatio));
  }

  // 更新播放位置
  void updatePosition(Duration position) {
    emit(state.copyWith(position: position));
  }

  // 更新视频总时长
  void updateDuration(Duration duration) {
    emit(state.copyWith(duration: duration));
  }

  // 更新播放状态
  void updatePlayingState(bool isPlaying) {
    emit(state.copyWith(isPlaying: isPlaying));
  }
}
