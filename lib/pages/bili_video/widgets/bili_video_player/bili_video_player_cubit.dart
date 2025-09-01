import 'package:biliyou/common/models/local/video/audioplayitem.dart';
import 'package:biliyou/common/models/local/video/videoplayinfo.dart';
import 'package:biliyou/common/models/local/video/videoplayitem.dart';
import 'package:biliyou/pages/bilivideo/widgets/bilivideoplayer/bilivideoplayer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediakit/mediakit.dart';

class BiliVideoPlayerCubit extends Cubit<BiliVideoPlayerState> {
  final VideoPlayInfo videoPlayInfo;
  VideoPlayItem videoPlayItem;
  final AudioPlayItem? audioPlayItem;

  BiliVideoPlayerCubit({
    required this.videoPlayInfo,
    required this.videoPlayItem,
    this.audioPlayItem,
  }) : super(BiliVideoPlayerState.initial());

  void changeQuality(VideoPlayItem newItem) {
    videoPlayItem = newItem;
    emit(state.copyWith(
      videoPlayItem: newItem,
      quality: newItem.quality,
    ));
  }

  void updateFit(VideoFit fit) {
    emit(state.copyWith(fit: fit));
  }

  void updateAspectRatio(double aspectRatio) {
    emit(state.copyWith(aspectRatio: aspectRatio));
  }

  void toggleDanmaku() {
    emit(state.copyWith(showDanmaku: !state.showDanmaku));
  }

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

  void updatePosition(Duration position) {
    emit(state.copyWith(position: position));
  }

  // 新增方法：更新视频总时长
  void updateDuration(Duration duration) {
    emit(state.copyWith(duration: duration));
  }

  // 新增方法：更新播放状态
  void updatePlayingState(bool isPlaying) {
    emit(state.copyWith(isPlaying: isPlaying));
  }

  // 新增方法：开始拖动
  void startDragging() {
    emit(state.copyWith(isDragging: true));
  }

  // 新增方法：更新拖动位置
  void updateDragPosition(Duration position) {
    emit(state.copyWith(dragPosition: position));
  }

  // 新增方法：结束拖动
  void endDragging(Duration position) {
    emit(state.copyWith(
      isDragging: false,
      position: position,
    ));
  }
}
