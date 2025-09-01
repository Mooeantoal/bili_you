import 'package:equatable/equatable.dart';
import 'package:mediakit/mediakit.dart';
import 'package:biliyou/common/models/local/video/videoplayitem.dart';

class BiliVideoPlayerState extends Equatable {
  final VideoPlayItem videoPlayItem;
  final String quality;
  final VideoFit fit;
  final double aspectRatio;
  final bool showDanmaku;
  final double danmakuFontSize;
  final double danmakuOpacity;
  final double danmakuShowArea;
  final Duration position;
  final Duration duration; // 视频总时长
  final bool isPlaying; // 播放状态
  final bool isDragging; // 拖动状态
  final Duration dragPosition; // 拖动时的临时位置

  const BiliVideoPlayerState({
    required this.videoPlayItem,
    required this.quality,
    required this.fit,
    required this.aspectRatio,
    required this.showDanmaku,
    required this.danmakuFontSize,
    required this.danmakuOpacity,
    required this.danmakuShowArea,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isDragging,
    required this.dragPosition,
  });

  factory BiliVideoPlayerState.initial() {
    return const BiliVideoPlayerState(
      videoPlayItem: VideoPlayItem.empty,
      quality: '720P',
      fit: VideoFit.contain,
      aspectRatio: 16 / 9,
      showDanmaku: true,
      danmakuFontSize: 16,
      danmakuOpacity: 1.0,
      danmakuShowArea: 1.0,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
      isDragging: false,
      dragPosition: Duration.zero,
    );
  }

  BiliVideoPlayerState copyWith({
    VideoPlayItem? videoPlayItem,
    String? quality,
    VideoFit? fit,
    double? aspectRatio,
    bool? showDanmaku,
    double? danmakuFontSize,
    double? danmakuOpacity,
    double? danmakuShowArea,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isDragging,
    Duration? dragPosition,
  }) {
    return BiliVideoPlayerState(
      videoPlayItem: videoPlayItem ?? this.videoPlayItem,
      quality: quality ?? this.quality,
      fit: fit ?? this.fit,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      showDanmaku: showDanmaku ?? this.showDanmaku,
      danmakuFontSize: danmakuFontSize ?? this.danmakuFontSize,
      danmakuOpacity: danmakuOpacity ?? this.danmakuOpacity,
      danmakuShowArea: danmakuShowArea ?? this.danmakuShowArea,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isDragging: isDragging ?? this.isDragging,
      dragPosition: dragPosition ?? this.dragPosition,
    );
  }

  @override
  List<Object> get props => [
        videoPlayItem,
        quality,
        fit,
        aspectRatio,
        showDanmaku,
        danmakuFontSize,
        danmakuOpacity,
        danmakuShowArea,
        position,
        duration,
        isPlaying,
        isDragging,
        dragPosition,
      ];
}
