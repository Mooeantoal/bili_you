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
  final Duration duration; // 新增：视频总时长
  final bool isPlaying; // 新增：播放状态
  final bool isDragging; // 新增：拖动状态

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
    required this.duration, // 新增
    required this.isPlaying, // 新增
    required this.isDragging, // 新增
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
      duration: Duration.zero, // 新增
      isPlaying: false, // 新增
      isDragging: false, // 新增
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
    Duration? duration, // 新增
    bool? isPlaying, // 新增
    bool? isDragging, // 新增
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
      duration: duration ?? this.duration, // 新增
      isPlaying: isPlaying ?? this.isPlaying, // 新增
      isDragging: isDragging ?? this.isDragging, // 新增
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
        duration, // 新增
        isPlaying, // 新增
        isDragging, // 新增
      ];
}
