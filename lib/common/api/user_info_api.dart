import 'package:dio/dio.dart';
import 'package:bili_you/common/models/network/user/user_info.dart';

class UserInfoApi {
  static const String _baseUrl = 'https://uapis.cn/api/v1/social/bilibili';

  // 获取用户信息
  static Future<UserInfoData?> getUserInfo({required String uid}) async {
    try {
      final url = '$_baseUrl/userinfo?uid=$uid';
      final dio = Dio();
      
      // 添加请求头以避免被阻止
      dio.options.headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
      };
      
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        // 检查响应数据格式
        if (response.data is Map<String, dynamic>) {
          final userInfoResponse = UserInfoResponse.fromJson(response.data);
          
          if (userInfoResponse.code == 0 && userInfoResponse.data != null) {
            return userInfoResponse.data;
          } else {
            // 如果API返回错误，打印详细信息
            print('API Error: code=${userInfoResponse.code}, message=${userInfoResponse.message}');
          }
        } else {
          print('Invalid response format: ${response.data}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred while fetching user info: $e');
    }
    
    return null;
  }
}