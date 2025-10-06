import 'dart:convert';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:bili_you/common/api/api_constants.dart';

class SearchTestApi {
  /// 获取搜索建议
  static Future<Map<String, dynamic>> getSearchSuggest({required String term}) async {
    var url = '${ApiConstants.searchSuggest}?term=$term';
    var response = await HttpUtils().get(url);
    return jsonDecode(response.data);
  }

  /// 获取热搜榜
  static Future<Map<String, dynamic>> getHotSearchList({int limit = 10}) async {
    var url = '${ApiConstants.hotWordsMob}?limit=$limit&build=0&mobi_app=web';
    var response = await HttpUtils().get(url);
    return jsonDecode(response.data);
  }

  /// 获取搜索推荐
  static Future<Map<String, dynamic>> getSearchRecommend() async {
    var url = '${ApiConstants.searchSuggest}?build=0&mobi_app=web';
    var response = await HttpUtils().get(url);
    return jsonDecode(response.data);
  }
}