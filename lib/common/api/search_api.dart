import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/api/wbi.dart';
import 'package:bili_you/common/models/local/reply/official_verify.dart';
import 'package:bili_you/common/models/local/reply/reply_member.dart';
import 'package:bili_you/common/models/local/search/default_search_word.dart';
import 'package:bili_you/common/models/local/search/hot_word_item.dart';
import 'package:bili_you/common/models/local/search/search_bangumi_item.dart';
import 'package:bili_you/common/models/local/search/search_suggest_item.dart';
import 'package:bili_you/common/models/local/search/search_user_item.dart';
import 'package:bili_you/common/models/network/search/default_search_word.dart';
import 'package:bili_you/common/models/network/search/hot_words.dart';
import 'package:bili_you/common/models/network/search/search_bangumi.dart';
import 'package:bili_you/common/models/network/search/search_suggest.dart';
import 'package:bili_you/common/models/network/search/search_video.dart';
import 'package:bili_you/common/models/local/search/search_video_item.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';

class SearchApi {
  static Future<DefaultSearchWordResponse> _requestDefaultSearchWords() async {
    try {
      print('Requesting default search words from: ${ApiConstants.defualtSearchWord}');
      var response = await HttpUtils().get(ApiConstants.defualtSearchWord,
          queryParameters: await WbiSign.encodeParams({}));
      print('Default search words response: ${response.data}');
      return DefaultSearchWordResponse.fromJson(response.data);
    } catch (e) {
      print('Error in _requestDefaultSearchWords: $e');
      rethrow;
    }
  }

  ///获取默认搜索词
  static Future<DefaultSearchWord> getDefaultSearchWords() async {
    try {
      var response = await _requestDefaultSearchWords();
      if (response.code != 0) {
        print("getRequestDefaultSearchWords: code:${response.code}, message:${response.message}");
        return DefaultSearchWord.zero;
      }
      if (response.data == null) {
        return DefaultSearchWord.zero;
      }
      return DefaultSearchWord(
          showName: response.data!.showName ?? "",
          name: response.data!.name ?? "");
    } catch (e) {
      print('Error in getDefaultSearchWords: $e');
      return DefaultSearchWord.zero;
    }
  }

  static Future<HotWordResponse> _requestHotWords() async {
    try {
      print('Requesting hot words from: ${ApiConstants.hotWordsMob}');
      var response = await HttpUtils().get(ApiConstants.hotWordsMob);
      print('Hot words raw response: ${response.data}');
      
      // 检查响应数据格式
      if (response.data is Map<String, dynamic>) {
        var data = response.data as Map<String, dynamic>;
        if (data.containsKey('code') && data['code'] == 0) {
          print('Hot words response success');
          return HotWordResponse.fromJson(data);
        } else {
          print('Hot words response error: ${data['message'] ?? 'Unknown error'}');
          // 如果手机版接口失败，尝试Web端接口
          return await _requestHotWordsWeb();
        }
      } else {
        print('Hot words response format error: not a map');
        // 如果手机版接口失败，尝试Web端接口
        return await _requestHotWordsWeb();
      }
    } catch (e, stackTrace) {
      print('Error in _requestHotWords: $e');
      print('Stack trace: $stackTrace');
      // 如果手机版接口失败，尝试Web端接口
      return await _requestHotWordsWeb();
    }
  }

  static Future<HotWordResponse> _requestHotWordsWeb() async {
    try {
      print('Requesting hot words from Web API: ${ApiConstants.hotWordsWeb}');
      var response = await HttpUtils().get(ApiConstants.hotWordsWeb,
          queryParameters: await WbiSign.encodeParams({}));
      print('Hot words Web API raw response: ${response.data}');
      
      // 检查响应数据格式
      if (response.data is Map<String, dynamic>) {
        var data = response.data as Map<String, dynamic>;
        if (data.containsKey('code') && data['code'] == 0) {
          print('Hot words Web API response success');
          // 需要转换Web端数据格式为App端格式
          return _convertWebHotWordsResponse(data);
        } else {
          print('Hot words Web API response error: ${data['message'] ?? 'Unknown error'}');
          // 返回一个空的响应而不是抛出异常
          return HotWordResponse(
            code: data['code'] ?? -1,
            message: data['message'] ?? 'Unknown error',
            ttl: data['ttl'] ?? 0,
            data: null,
          );
        }
      } else {
        print('Hot words Web API response format error: not a map');
        return HotWordResponse(
          code: -1,
          message: 'Response format error',
          ttl: 0,
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('Error in _requestHotWordsWeb: $e');
      print('Stack trace: $stackTrace');
      // 返回一个空的响应而不是抛出异常
      return HotWordResponse(
        code: -1,
        message: 'Network error: $e',
        ttl: 0,
        data: null,
      );
    }
  }

  static HotWordResponse _convertWebHotWordsResponse(Map<String, dynamic> webData) {
    try {
      // Web端返回的数据结构与App端不同，需要转换
      // Web端数据结构: {"code":0,"message":"0","ttl":1,"data":{"trending":{"title":"大家还在搜","trackid":"web_search_trending","list":[{"keyword":"...","show_name":"...","icon":"...","goto_type":"..."}]}}}
      if (webData['data'] is Map<String, dynamic> &&
          (webData['data'] as Map<String, dynamic>).containsKey('trending')) {
        var trendingData = (webData['data'] as Map<String, dynamic>)['trending'];
        if (trendingData is Map<String, dynamic> && trendingData.containsKey('list')) {
          var list = trendingData['list'] as List;
          var convertedList = list.map((item) {
            if (item is Map<String, dynamic>) {
              return <String, dynamic>{
                'keyword': item['keyword'] ?? '',
                'show_name': item['show_name'] ?? item['keyword'] ?? '',
                'position': 0,
                'word_type': 0,
                'icon': item['icon'] ?? '',
                'hot_id': 0,
                'is_commercial': '0',
              };
            }
            return <String, dynamic>{};
          }).toList();
          
          return HotWordResponse(
            code: webData['code'],
            message: webData['message'],
            ttl: webData['ttl'],
            data: HotWordResponseData(
              trackid: trendingData['trackid'] ?? '',
              list: convertedList.map((item) => ListElement.fromJson(item)).toList(),
              expStr: '',
              topList: [],
            ),
          );
        }
      }
      
      // 如果转换失败，返回原始数据
      return HotWordResponse.fromJson(webData);
    } catch (e) {
      print('Error converting Web hot words response: $e');
      // 如果转换失败，返回原始数据
      return HotWordResponse.fromJson(webData);
    }
  }

  ///获取热词列表
  static Future<List<HotWordItem>> getHotWords() async {
    List<HotWordItem> list = [];
    try {
      var response = await _requestHotWords();
      print('Hot words response code: ${response.code}');
      print('Hot words response message: ${response.message}');
      print('Hot words response data: ${response.data}');
      
      // 检查响应状态
      if (response.code != 0) {
        print("getHotWords: code:${response.code}, message:${response.message}");
        // 即使API返回错误，也返回空列表而不是抛出异常
        return list;
      }
      
      // 检查数据是否存在
      if (response.data == null) {
        print("getHotWords: data is null");
        return list;
      }
      
      // 检查列表是否存在
      if (response.data!.list == null) {
        print("getHotWords: list is null");
        return list;
      }
      
      // 构造热词列表
      for (var i in response.data!.list!) {
        // 确保关键词不为空
        String keyword = i.keyword ?? "";
        String showWord = i.showName ?? "";
        
        // 如果keyword为空但showWord不为空，使用showWord作为keyword
        if (keyword.isEmpty && showWord.isNotEmpty) {
          keyword = showWord;
        }
        
        // 只有当keyword不为空时才添加
        if (keyword.isNotEmpty) {
          list.add(HotWordItem(keyWord: keyword, showWord: showWord));
        }
      }
      print('Hot words list size: ${list.length}');
      return list;
    } catch (e, stackTrace) {
      print('Error in getHotWords: $e');
      print('Stack trace: $stackTrace');
      // 即使出现异常，也返回空列表而不是抛出异常
      return list;
    }
  }

  static Future<SearchSuggestResponse> _requestSearchSuggests(
      String keyWord) async {
    var response = await HttpUtils().get(ApiConstants.searchSuggest,
        queryParameters: {'term': keyWord, "main_ver": 'v1'});
    return SearchSuggestResponse.fromJson(response.data);
  }

  ///根据keyWord获取搜索建议
  static Future<List<SearchSuggestItem>> getSearchSuggests(
    {required String keyWord}) async {
  List<SearchSuggestItem> list = [];
  var response = await _requestSearchSuggests(keyWord);
  if (response.code != 0) {
    throw "getSearchSuggests: code:${response.code}";
  }
  if (response.result == null || response.result!.tag == null) {
    return list;
  }
  for (var i in response.result!.tag!) {
    // ✅ 修复：使用 keyWordTitleToRawTitle 移除 HTML 标签
    final cleanName = StringFormatUtils.keyWordTitleToRawTitle(i.name ?? "");
    
    list.add(SearchSuggestItem(
  showWord: StringFormatUtils.keyWordTitleToRawTitle(i.name ?? ""), // 清理HTML标签
  realWord: i.value ?? ""
));
  }
  return list;
}

  ///搜索请求
  ///keyword 搜索的词
  ///searchType 搜索类型
  ///page 页码
  ///order搜索结果排序方式
  static Future<dynamic> _requestSearch({
    required String keyword,
    required int page,
    required SearchType searchType,
    required SearchVideoOrder order,
  }) async {
    var response = await HttpUtils().get(
      ApiConstants.searchWithType,
      queryParameters: {
        'keyword': keyword,
        'search_type': searchType.value,
        'order': order.value,
        'page': page,
      },
    );
    if (searchType == SearchType.video) {
      return SearchVideoResponse.fromJson(response.data);
    } else {
      return BangumiSearchResponse.fromJson(response.data);
    }
  }

  ///搜索视频请求
  static Future<SearchVideoResponse> _requestSearchVideo({
    required String keyword,
    required int page,
    required SearchVideoOrder order,
  }) async {
    return await _requestSearch(
        keyword: keyword,
        page: page,
        searchType: SearchType.video,
        order: order);
  }

  ///搜索视频
  static Future<List<SearchVideoItem>> getSearchVideos({
    required String keyWord,
    required int page,
    required SearchVideoOrder order,
  }) async {
    List<SearchVideoItem> list = [];
    var response =
        await _requestSearchVideo(keyword: keyWord, page: page, order: order);
    if (response.code != 0) {
      throw "getSearchVideoList: code:${response.code}, message:${response.message}";
    }
    if (response.data == null || response.data!.result == null) {
      return list;
    }
    for (var i in response.data!.result!) {
      list.add(SearchVideoItem(
          coverUrl: "http:${i.pic ?? ""}",
          title: StringFormatUtils.replaceAllHtmlEntitiesToCharacter(
              StringFormatUtils.keyWordTitleToRawTitle(i.title ?? "")),
          bvid: i.bvid ?? "",
          upName: i.author ?? "",
          timeLength: Duration(
                  minutes: int.tryParse(i.duration!.split(':').first) ?? 0,
                  seconds: int.tryParse(i.duration!.split(':').last) ?? 0)
              .inSeconds,
          playNum: i.play ?? 0,
          pubDate: i.pubdate ?? 0));
    }
    return list;
  }

  ///搜索番剧请求
  static Future<BangumiSearchResponse> _requestSearchBangumi(
      {required String keyWord, required int page}) async {
    return await _requestSearch(
        keyword: keyWord,
        page: page,
        searchType: SearchType.bangumi,
        order: SearchVideoOrder.comprehensive);
  }

  ///搜索番剧
  static Future<List<SearchBangumiItem>> getSearchBangumis(
      {required String keyWord, required int page}) async {
    List<SearchBangumiItem> list = [];
    var response = await _requestSearchBangumi(keyWord: keyWord, page: page);
    if (response.code != 0) {
      throw "getSearchBanumis: code:${response.code}, message:${response.message}";
    }
    if (response.data == null || response.data!.result == null) {
      return list;
    }
    for (var i in response.data!.result!) {
      list.add(SearchBangumiItem(
          coverUrl: i.cover ?? "",
          title: StringFormatUtils.replaceAllHtmlEntitiesToCharacter(
              StringFormatUtils.keyWordTitleToRawTitle(i.title ?? "")),
          describe: "${i.areas}\n${i.styles}",
          score: i.mediaScore?.score ?? 0,
          ssid: i.seasonId!));
    }
    return list;
  }

  static Future<List<SearchUserItem>> getSearchUsers(
      {required String keyWord, required int page}) async {
    List<SearchUserItem> list = [];
    var response =
        await HttpUtils().get(ApiConstants.searchWithType, queryParameters: {
      'keyword': keyWord,
      'search_type': SearchType.user.value,
      'page': page,
    });
    if (response.data['code'] != 0) {
      throw "getSearchUsers: code:${response.data['code']}, message:${response.data['message']}";
    }
    for (Map<String, dynamic> i in response.data['data']?['result'] ?? []) {
      list.add(SearchUserItem(
          mid: i['mid'],
          name: i['uname'],
          face: "http:${i['upic']}",
          sign: i['usign'],
          fansCount: i['fans'],
          videoCount: i['videos'],
          level: i['level'],
          gender: Gender.values[i['gender'] - 1],
          isUpper: i['is_upuser'] == 1,
          isLive: i['is_live'] == 1,
          roomId: i['room_id'],
          officialVerify: OfficialVerify(
              type:
                  OfficialVerifyTypeCode.fromCode(i['official_verify']['type']),
              description: i['official_verify']['desc'])));
    }
    return list;
  }
}

//视频搜索排序类型
enum SearchVideoOrder {
  //综合,默认
  comprehensive,
  //最多点击
  click,
  //最新发布
  pubdate,
  //最多弹幕
  danmaku,
  //最多收藏
  favorites,
  //最多评论
  comments
}

//视频搜索排序类型对应的字符串值实现
extension SearchVideoOrderExtension on SearchVideoOrder {
  String get value => ['', 'click', 'pubdate', 'dm', 'stow', 'scores'][index];
}

// 视频：video
// 番剧：media_bangumi
// 影视：media_ft
// 直播间及主播：live
// 直播间：live_room
// 主播：live_user
// 专栏：article
// 话题：topic
// 用户：bili_user
// 相簿：photo
// 搜索类型
enum SearchType {
  //视频
  video,
  //番剧
  bangumi,
  //影视
  movie,
  //直播间
  liveRoom,
  //用户
  user
}

extension SearchTypeExtension on SearchType {
  String get value =>
      ['video', 'media_bangumi', 'media_ft', 'live_room', 'bili_user'][index];
  String get name => ['视频', '番剧', '影视', '直播间', '用户'][index];
}
