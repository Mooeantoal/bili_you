import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/models/local/video/audio_play_item.dart';
import 'package:bili_you/common/models/local/video/video_play_info.dart';
import 'package:bili_you/common/models/local/video/video_play_item.dart';
import 'package:bili_you/common/models/network/video_play/video_play.dart'
    hide SegmentBase;
import 'package:bili_you/common/utils/cookie_util.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:math';

class VideoPlayApi {
  static Map<String, String> videoPlayerHttpHeaders = {
    'User-Agent': ApiConstants.userAgent,
    'Referer': '${ApiConstants.bilibiliBase}/',
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  static Future<bool> _isLogin() async {
    try {
      // 检查 Cookie 中是否有登录相关的 Cookie
      var cookies = await HttpUtils.cookieManager.cookieJar
          .loadForRequest(Uri.parse(ApiConstants.bilibiliBase));
      // 查找 DedeUserID Cookie，这是 Bilibili 登录状态的标识
      return cookies.any((cookie) => cookie.name == 'DedeUserID');
    } catch (e) {
      // 如果出现异常，默认认为未登录
      return false;
    }
  }

  static Future<VideoPlayResponse> _requestVideoPlay(
      {required String bvid,
      required int cid,
      int fnval = FnvalValue.all}) async {
    bool isLogin = await _isLogin();
    
    // 生成随机数和时间戳
    final random = Random();
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    
    var response = await HttpUtils().get(ApiConstants.videoPlay,
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
          'fnver': 0,
          'fnval': fnval,
          'fourk': 1,
          // 添加关键参数以支持未登录用户播放
          'force_host': 2, // 强制返回HTTPS地址
          if (!isLogin) 'try_look': 1, // 免登录查看
          'voice_balance': 1,
          'gaia_source': 'pre-load',
          'isGaiaAvoided': true,
          'web_location': 1315873,
          // 添加更多符合Bilibili要求的参数
          'qn': 120, // 默认请求最高画质
          'otype': 'json',
          'platform': 'html5',
          // 新增参数
          'buvid': 'XY118B45D008F4831277844288FC1F2061F4C',
          'device_type': 1,
          'device_id': 'D3A356A5-CD69-4075-9DA0-584614347DB0',
          'build': 66666,
          'device_name': 'iPhone 14',
          'device_model': 'iPhone 14',
          'device_os': '16.5',
          'device_platform': 'iPhone',
          'device_brand': 'Apple',
          'device_version': '16.5',
          'device_screen': '390x844',
          'abtest': '819588',
          'ts': timestamp,
          'random': random.nextInt(1000000),
        },
        options: Options(headers: {
          'User-Agent': ApiConstants.userAgent,
          'Referer': '${ApiConstants.bilibiliBase}/video/$bvid',
        }));

    return VideoPlayResponse.fromJson(response.data);
  }

  static Future<VideoPlayInfo> getVideoPlay({
    required String bvid,
    required int cid,
  }) async {
    // 尝试使用不同的fnval值获取播放信息
    var response = await _requestVideoPlay(bvid: bvid, cid: cid, fnval: FnvalValue.all);
    
    // 如果第一次请求失败，尝试使用更简单的格式
    if (response.code != 0 || response.data == null) {
      response = await _requestVideoPlay(bvid: bvid, cid: cid, fnval: 16); // 只请求DASH格式
    }
    
    // 再次尝试使用更简单的参数
    if (response.code != 0 || response.data == null) {
      response = await _requestVideoPlay(bvid: bvid, cid: cid, fnval: 1); // 只请求MP4格式
    }
    
    // 再次尝试使用DURL格式
    if (response.code != 0 || response.data == null) {
      response = await _requestVideoPlay(bvid: bvid, cid: cid, fnval: 8); // 只请求DURL格式
    }
    
    // 再次尝试使用FLV格式
    if (response.code != 0 || response.data == null) {
      response = await _requestVideoPlay(bvid: bvid, cid: cid, fnval: 4); // 只请求FLV格式
    }
    
    if (response.code != 0) {
      throw "getVideoPlay: code:${response.code}, message:${response.message}";
    }
    if (response.data == null ||
        response.data!.acceptQuality == null ||
        response.data!.acceptDescription == null) {
      return VideoPlayInfo.zero;
    }
    
    // 获取支持的视频质量
    List<VideoQuality> supportVideoQualities = [];
    for (var i in response.data!.acceptQuality ?? <int>[]) {
      supportVideoQualities.add(VideoQualityCode.fromCode(i));
    }
    
    // 初始化视频和音频列表
    List<VideoPlayItem> videos = [];
    List<AudioPlayItem> audios = [];
    
    // 检查是否有DASH流
    if (response.data!.dash != null) {
      _parseDashStream(response, videos, audios);
    } 
    // 如果没有DASH流，检查是否有DURL流
    else if (response.data!.durl != null && response.data!.durl!.isNotEmpty) {
      _parseDurlStream(response, videos);
    }
    // 如果没有DURL流，检查是否有其他格式
    else {
      _parseOtherStreamFormats(response, videos);
    }
    
    List<AudioQuality> supportAudioQualities = [];
    // 获取支持的音质
    for (var i in audios) {
      supportAudioQualities.add(i.quality);
    }
    
    return VideoPlayInfo(
        supportVideoQualities: supportVideoQualities,
        supportAudioQualities: supportAudioQualities,
        timeLength: response.data!.dash?.duration ?? response.data!.timelength ?? 0,
        videos: videos,
        audios: audios,
        lastPlayCid: response.data!.lastPlayCid ?? 0,
        lastPlayTime: Duration(milliseconds: response.data!.lastPlayTime ?? 0));
  }

  // 解析DASH流
  static void _parseDashStream(VideoPlayResponse response, List<VideoPlayItem> videos, List<AudioPlayItem> audios) {
    // 获取视频
    for (var i in response.data!.dash?.video ?? <VideoOrAudioRaw>[]) {
      List<String> urls = [];
      if (i.baseUrl != null) {
        urls.add(i.baseUrl!);
      }
      if (i.backupUrl != null) {
        urls.addAll(i.backupUrl!);
      }
      videos.add(VideoPlayItem(
        urls: urls,
        quality: VideoQualityCode.fromCode(i.id ?? -1),
        bandWidth: i.bandwidth ?? 0,
        codecs: i.codecs ?? "",
        width: i.width ?? 0,
        height: i.height ?? 0,
        frameRate: double.tryParse(i.frameRate ?? "0") ?? 0,
        sar: double.parse(i.sar?.split(':').first ?? '1') /
            double.parse(i.sar?.split(':').last ?? '1'),
      ));
    }
    
    // 如果有dolby的话
    for (var i in response.data!.dash?.dolby?.audio ?? <VideoOrAudioRaw>[]) {
      response.data!.dash?.audio?.add(i);
    }
    
    // 如果有flac的话
    if (response.data!.dash?.flac?.audio != null) {
      response.data!.dash?.audio?.add(response.data!.dash!.flac!.audio!);
    }
    
    // 获取音频
    for (var i in response.data!.dash?.audio ?? <VideoOrAudioRaw>[]) {
      List<String> urls = [];
      if (i.baseUrl != null) {
        urls.add(i.baseUrl!);
      }
      if (i.backupUrl != null) {
        urls.addAll(i.backupUrl!);
      }
      audios.add(AudioPlayItem(
        urls: urls,
        quality: AudioQualityCode.fromCode(i.id ?? -1),
        bandWidth: i.bandwidth ?? 0,
        codecs: i.codecs ?? "",
      ));
    }
  }

  // 解析DURL流
  static void _parseDurlStream(VideoPlayResponse response, List<VideoPlayItem> videos) {
    // 对于DURL流，我们创建一个简单的视频项
    final firstDurl = response.data!.durl!.first;
    if (firstDurl.url != null) {
      List<String> urls = [firstDurl.url!];
      if (firstDurl.backupUrl != null) {
        urls.addAll(firstDurl.backupUrl!);
      }
      
      // 创建一个基本的视频项
      videos.add(VideoPlayItem(
        urls: urls,
        quality: VideoQuality.clear480p, // 使用默认质量
        bandWidth: firstDurl.size ?? 0,
        codecs: "avc1.64001F",
        width: 852,
        height: 480,
        frameRate: 29.97,
        sar: 1.0,
      ));
    }
  }

  // 解析其他流格式
  static void _parseOtherStreamFormats(VideoPlayResponse response, List<VideoPlayItem> videos) {
    // 如果没有任何流格式，创建一个占位符
    videos.add(VideoPlayItem(
      urls: [],
      quality: VideoQuality.unknown,
      bandWidth: 0,
      codecs: "",
      width: 0,
      height: 0,
      frameRate: 0,
      sar: 1.0,
    ));
  }

  ///获取弹幕列表
  static Future<String> getDanmakuList({required int cid}) async {
    var response = await HttpUtils().get(
      "${ApiConstants.danmakuList}/$cid.xml",
      options: Options(
        headers: {
          'user-agent': ApiConstants.userAgent,
          'referer': ApiConstants.bilibiliBase,
        },
      ),
    );
    return response.data;
  }

  ///发送弹幕
  static Future<Map<String, dynamic>> sendDanmaku({
    required String message,
    required String aid,
    required String oid,
    required int progress,
    required int color,
    required int fontsize,
    required int mode,
  }) async {
    var response = await HttpUtils().post(
      ApiConstants.sendDanmaku,
      queryParameters: {
        'msg': message,
        'type': '1',
        'aid': aid,
        'oid': oid,
        'progress': progress.toString(),
        'color': color.toString(),
        'fontsize': fontsize.toString(),
        'mode': mode.toString(),
        'rnd': DateTime.now().millisecondsSinceEpoch.toString(),
        'csrf': await CookieUtils.getCsrf(),
      },
      options: Options(
        headers: {
          'user-agent': ApiConstants.userAgent,
          'referer': ApiConstants.bilibiliBase,
        },
      ),
    );
    return response.data;
  }

  static Future<void> reportHistory(
      {required String bvid, required int cid, required int playedTime}) async {
    var response = await HttpUtils().post(ApiConstants.heartBeat,
        queryParameters: {'bvid': bvid, 'cid': cid, 'played_time': playedTime});
    if (response.data['code'] != 0) {
      throw 'reportHistory: code:${response.data['code']},message:${response.data['message']}';
    }
  }
}

///视频流格式标识
// ignore: unused_field
enum _Fnval { dash, hdr, fourK, dolby, dolbyVision, eightK, av1, durl, flv }

///视频流格式标识代码
// ignore: library_private_types_in_public_api
extension FnvalValue on _Fnval {
  static final List<int> _codeList = [16, 64, 128, 256, 512, 1024, 2048, 8, 4];
  int get code => _codeList[index];
  static const int all = 4060; //_codeList所有值之或
}