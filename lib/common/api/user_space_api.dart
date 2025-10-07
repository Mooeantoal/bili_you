import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/api/wbi.dart';
import 'package:bili_you/common/models/local/user_space/user_video_search.dart';
import 'package:bili_you/common/models/network/user_space/user_video_search.dart';
import 'package:bili_you/common/models/network/user_space/user_space_info.dart';
import 'package:bili_you/common/models/network/user_space/user_space_stat.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class UserSpaceApi {
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

  static Future<UserSpaceInfoResponse> _requestUserSpaceInfo({
    required int mid,
  }) async {
    bool isLogin = await _isLogin();
    
    var response = await HttpUtils().get(ApiConstants.userSpaceInfo,
        queryParameters: await WbiSign.encodeParams({
          "mid": mid,
          "platform": "web",
          "web_location": 1550101,
        }),
        // 为未登录用户添加特殊请求头
        options: !isLogin
            ? Options(
                headers: {
                  'user-agent': ApiConstants.userAgent,
                  'referer': ApiConstants.bilibiliBase,
                },
              )
            : null);
    return UserSpaceInfoResponse.fromJson(response.data);
  }

  static Future<UserSpaceInfoData> getUserSpaceInfo({
    required int mid,
  }) async {
    var response = await _requestUserSpaceInfo(mid: mid);
    if (response.code != 0) {
      throw "getUserSpaceInfo: code:${response.code}, message:${response.message}";
    }
    return response.data!;
  }

  static Future<UserSpaceStatResponse> _requestUserSpaceStat({
    required int mid,
  }) async {
    bool isLogin = await _isLogin();
    
    var response = await HttpUtils().get(ApiConstants.userSpaceStat,
        queryParameters: await WbiSign.encodeParams({
          "mid": mid,
          "platform": "web",
          "web_location": 1550101,
        }),
        // 为未登录用户添加特殊请求头
        options: !isLogin
            ? Options(
                headers: {
                  'user-agent': ApiConstants.userAgent,
                  'referer': ApiConstants.bilibiliBase,
                },
              )
            : null);
    return UserSpaceStatResponse.fromJson(response.data);
  }

  static Future<UserSpaceStatData> getUserSpaceStat({
    required int mid,
  }) async {
    var response = await _requestUserSpaceStat(mid: mid);
    if (response.code != 0) {
      throw "getUserSpaceStat: code:${response.code}, message:${response.message}";
    }
    return response.data!;
  }

  static Future<UserVideoSearchResponse> _requestUserVideoSearch({
    required int mid,
    required int pageNum,
    String? keyword,
    String order = "pubdate", // pubdate: 最新发布, click: 最多播放
  }) async {
    bool isLogin = await _isLogin();
    
    var response = await HttpUtils().get(ApiConstants.userVideoSearch,
        queryParameters: await WbiSign.encodeParams({
          "mid": mid,
          "pn": pageNum,
          "ps": 30,
          "keyword": keyword ?? "",
          "order": order,
          "tid": 0,
          "platform": "web",
        }),
        // 为未登录用户添加特殊请求头
        options: !isLogin
            ? Options(
                headers: {
                  'user-agent': ApiConstants.userAgent,
                  'referer': ApiConstants.bilibiliBase,
                },
              )
            : null);
    return UserVideoSearchResponse.fromJson(response.data);
  }

  static Future<UserVideoSearch> getUserVideoSearch({
    required int mid,
    required int pageNum,
    String? keyword,
    String order = "pubdate", // pubdate: 最新发布, click: 最多播放
  }) async {
    var response = await _requestUserVideoSearch(
        mid: mid, pageNum: pageNum, keyword: keyword, order: order);
    if (response.code != 0) {
      throw "getUserVideoSearch: code:${response.code}, message:${response.message}";
    }

    if (response.data == null ||
        response.data?.list == null ||
        response.data?.list?.vlist == null) {
      return UserVideoSearch.zero;
    }
    List<UserVideoItem> videos = [];
    for (var i in response.data!.list!.vlist!) {
      videos.add(UserVideoItem(
          author: i.author ?? "",
          title: i.title ?? "",
          mid: i.mid ?? 0,
          bvid: i.bvid ?? "",
          coverUrl: i.pic ?? "",
          danmakuCount: i.videoReview ?? 0,
          description: i.description ?? "",
          isUnionVideo: i.isUnionVideo == 1,
          playCount: i.play ?? 0,
          duration: i.length ?? "--:--",
          pubDate: i.created ?? 0,
          replyCount: i.comment ?? 0));
    }
    return UserVideoSearch(videos: videos);
  }
}