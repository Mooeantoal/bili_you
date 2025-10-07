import 'package:bili_you/common/api/index.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';

class BiliMedia {
  String bvid;
  int cid;
  int? ssid;
  int? epid;
  bool isBangumi;
  int? progress;
  String? cover;

  BiliMedia(
      {required this.bvid,
      required this.cid,
      this.ssid,
      this.epid,
      this.isBangumi = false,
      this.progress,
      this.cover});
}

class BiliMediaContent extends VideoPlayInfo {
  BiliMediaContent(
      {required super.supportVideoQualities,
      required super.supportAudioQualities,
      required super.timeLength,
      required super.videos,
      required super.audios,
      required super.lastPlayCid,
      required super.lastPlayTime});
}

class BiliMediaCubit {
  BiliMedia media;

  BiliMediaCubit(
      {required String bvid,
      required int cid,
      int? ssid,
      int? epid,
      bool isBangumi = false,
      int? progress,
      String? cover})
      : media = BiliMedia(
            bvid: bvid,
            cid: cid,
            ssid: ssid,
            epid: epid,
            isBangumi: isBangumi,
            progress: progress,
            cover: cover);

  Future<BiliMediaContent> getVideoPlayInfo() async {
    try {
      // 获取视频播放信息
      var videoPlayInfo = await VideoPlayApi.getVideoPlay(
        bvid: media.bvid,
        cid: media.cid,
      );
      
      return BiliMediaContent(
        supportVideoQualities: videoPlayInfo.supportVideoQualities,
        supportAudioQualities: videoPlayInfo.supportAudioQualities,
        timeLength: videoPlayInfo.timeLength,
        videos: videoPlayInfo.videos,
        audios: videoPlayInfo.audios,
        lastPlayCid: videoPlayInfo.lastPlayCid,
        lastPlayTime: videoPlayInfo.lastPlayTime,
      );
    } catch (e) {
      // 如果获取失败，返回一个空的实现
      return BiliMediaContent(
          supportVideoQualities: [],
          supportAudioQualities: [],
          timeLength: 0,
          videos: [],
          audios: [],
          lastPlayCid: 0,
          lastPlayTime: Duration.zero);
    }
  }
}