import 'package:equatable/equatable.dart';
import 'package:mediakit/mediakit.dart';
import 'package:biliyou/common/models/local/video/audioplayitem.dart';
import 'package:biliyou/common/models/local/video/videoplayitem.dart';

class BiliVideoPlayerState extends Equatable {
  final VideoPlayItem videoPlayItem;
  final AudioPlayItem? audioPlayItem;
  final VideoController? videoController;
  final bool isInitialized;
  final bool isPlaying;
  final bool isDragging;
  final Duration position;
  final Duration duration;
  final Duration dragPosition;
  final Duration bufferedPosition;
  final VideoQuality quality;
  final BoxFit fit;
  final double aspectRatio;
  final bool showDanmaku;
  final double danmakuFontSize;
  final double danmakuOpacity;
  final double danmakuShowArea;

  const BiliVideoPlayerState({
    required this.videoPlayItem,
    this.audioPlayItem,
    this.videoController,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isDragging = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.dragPosition = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.quality = VideoQuality.auto,
    this.fit = BoxFit.contain,
    this.aspectRatio = 16 / 9,
    this.showDanmaku = true,
    this.danmakuFontSize = 16,
    this.danmakuOpacity = 1,
    this.danmakuShowArea = 1,
  });

  BiliVideoPlayerState copyWith({
    VideoPlayItem? videoPlayItem,
    AudioPlayItem? audioPlayItem,
    VideoController? videoController,
    bool? isInitialized,
    bool? isPlaying,
    bool? isDragging,
    Duration? position,
    Duration? duration,
    Duration? dragPosition,
    Duration? bufferedPosition,
    VideoQuality? quality,
    BoxFit? fit,
    double? aspectRatio,
    bool? showDanmaku,
    double? danmakuFontSize,
    double? danmakuOpacity,
    double? danmakuShowArea,
  }) {
    return BiliVideoPlayerState(
      videoPlayItem: videoPlayItem ?? this.videoPlayItem,
      audioPlayItem: audioPlayItem ?? this.audioPlayItem,
      videoController: videoController ?? this.videoController,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isDragging: isDragging ?? this.isDragging,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      dragPosition: dragPosition ?? this.dragPosition,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      quality: quality ?? this.quality,
      fit: fit ?? this.fit,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      showDanmaku: showDanmaku ?? this.showDanmaku,
      danmakuFontSize: danmakuFontSize ?? this.danmakuFontSize,
      danmakuOpacity: danmakuOpacity ?? this.danmakuOpacity,
      danmakuShowArea: danmakuShowArea ?? this.danmakuShowArea,
    );
  }

  @override
  List<Object?> get props => [
        videoPlayItem,
        audioPlayItem,
        videoController,
        isInitialized,
        isPlaying,
        isDragging,
        position,
        duration,
        dragPosition,
        bufferedPosition,
        quality,
        fit,
        aspectRatio,
        showDanmaku,
        danmakuFontSize,
        danmakuOpacity,
        danmakuShowArea,
      ];
}
