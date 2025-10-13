import 'package:dio/dio.dart';
import 'package:bili_you/common/models/network/user/user_info.dart';

class UserInfoApi {
  static const String _baseUrl = 'https://uapis.cn/api/v1/social/bilibili';

  // 获取用户信息
  static Future<UserInfoData?> getUserInfo({required String uid}) async {
    try {
      final url = '$_baseUrl/userinfo?uid=$uid';
      final dio = Dio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final userInfoResponse = UserInfoResponse.fromJson(response.data);
        
        if (userInfoResponse.code == 0 && userInfoResponse.data != null) {
          return userInfoResponse.data;
        }
      }
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
    
    return null;
  }
}