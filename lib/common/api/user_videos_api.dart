import 'package:dio/dio.dart';
import 'package:bili_you/common/api/wbi.dart';

class UserVideosApi {
  static const String _baseUrl = 'https://api.bilibili.com';

  // 获取用户投稿视频列表 (使用Wbi签名)
  static Future<Map<String, dynamic>?> getUserVideos({
    required String uid,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      const url = '$_baseUrl/x/space/wbi/arc/search';
      final dio = Dio();
      
      // 添加必要的请求头
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://space.bilibili.com/$uid',
        'Accept': 'application/json',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      };
      
      // 构造查询参数并进行Wbi签名
      final queryParams = await WbiSign.encodeParams({
        'mid': uid,
        'ps': pageSize,
        'tid': 0,
        'pn': page,
        'keyword': '',
        'order': 'pubdate', // 按发布日期排序
        'platform': 'web',
        'web_location': '1550101',
        'order_avoided': 'true',
      });
      
      print('请求用户投稿视频: $url, 参数: $queryParams');
      
      final response = await dio.get(
        url,
        queryParameters: queryParams,
      );

      print('收到响应状态码: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('收到数据: ${response.data is Map}');
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['code'] == 0) {
            return data;
          } else {
            print('API返回错误: code=${data['code']}, message=${data['message']}');
          }
        }
        return response.data;
      } else {
        print('HTTP错误: ${response.statusCode}, 响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('获取用户投稿视频失败: $e');
      print('堆栈跟踪: $stackTrace');
      throw Exception('获取用户投稿视频失败: $e');
    }
    
    return null;
  }
  
  // 尝试使用UAPI获取用户视频
  static Future<Map<String, dynamic>?> getUserVideosFromUAPI({
    required String uid,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final url = 'https://uapis.cn/api/v1/social/bilibili/user/video?uid=$uid&ps=$pageSize&pn=$page';
      final dio = Dio();
      
      // 添加必要的请求头
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
      };
      
      print('请求UAPI用户投稿视频: $url');
      
      final response = await dio.get(url);

      print('收到响应状态码: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('收到数据: ${response.data is Map}');
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['code'] == 0) {
            return data;
          } else {
            print('UAPI返回错误: code=${data['code']}, message=${data['message']}');
          }
        }
        return response.data;
      } else {
        print('HTTP错误: ${response.statusCode}, 响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('获取UAPI用户投稿视频失败: $e');
      print('堆栈跟踪: $stackTrace');
    }
    
    return null;
  }
  
  // 获取用户动态 (参考bilimiao2的实现)
  static Future<Map<String, dynamic>?> getUserDynamics({
    required String uid,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      const url = '$_baseUrl/x/polymer/web-dynamic/v1/feed/space'; // 使用新的动态API
      final dio = Dio();
      
      // 添加必要的请求头
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://space.bilibili.com/$uid/dynamic',
        'Accept': 'application/json',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      };
      
      // 构造查询参数并进行Wbi签名
      final queryParams = await WbiSign.encodeParams({
        'host_mid': uid,
        'offset': '',
        'page': page,
        'features': 'itemOpusStyle',
      });
      
      print('请求用户动态: $url, 参数: $queryParams');
      
      final response = await dio.get(
        url,
        queryParameters: queryParams,
      );

      print('收到用户动态响应状态码: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('收到动态数据: ${response.data is Map}');
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['code'] == 0) {
            return data;
          } else {
            print('动态API返回错误: code=${data['code']}, message=${data['message']}');
          }
        }
        return response.data;
      } else {
        print('HTTP错误: ${response.statusCode}, 响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('获取用户动态失败: $e');
      print('堆栈跟踪: $stackTrace');
    }
    
    return null;
  }
  
  // 尝试使用UAPI获取用户动态
  static Future<Map<String, dynamic>?> getUserDynamicsFromUAPI({
    required String uid,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final url = 'https://uapis.cn/api/v1/social/bilibili/user/dynamic?uid=$uid';
      final dio = Dio();
      
      // 添加必要的请求头
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
      };
      
      print('请求UAPI用户动态: $url');
      
      final response = await dio.get(url);

      print('收到响应状态码: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('收到动态数据: ${response.data is Map}');
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['code'] == 0) {
            return data;
          } else {
            print('UAPI动态返回错误: code=${data['code']}, message=${data['message']}');
          }
        }
        return response.data;
      } else {
        print('HTTP错误: ${response.statusCode}, 响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('获取UAPI用户动态失败: $e');
      print('堆栈跟踪: $stackTrace');
    }
    
    return null;
  }
}