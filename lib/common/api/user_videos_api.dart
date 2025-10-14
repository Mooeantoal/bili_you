import 'package:dio/dio.dart';

class UserVideosApi {
  static const String _baseUrl = 'https://api.bilibili.com';

  // 获取用户投稿视频列表
  // 注意：这个API可能需要登录cookie才能正常工作
  static Future<Map<String, dynamic>?> getUserVideos({
    required String uid,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      const url = '$_baseUrl/x/space/arc/search';
      final dio = Dio();
      
      // 添加必要的请求头
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
      };
      
      final response = await dio.get(
        url,
        queryParameters: {
          'mid': uid,
          'ps': pageSize,
          'tid': 0,
          'pn': page,
          'keyword': '',
          'order': 'pubdate', // 按发布日期排序
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      throw Exception('获取用户投稿视频失败: $e');
    }
    
    return null;
  }
}