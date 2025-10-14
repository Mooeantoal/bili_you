import 'package:dio/dio.dart';
import 'package:bili_you/common/models/network/user/user_info.dart';

class UserInfoApi {
  static const String _baseUrl = 'https://uapis.cn/api/v1/social/bilibili';

  // 获取用户信息
  static Future<UserInfoData?> getUserInfo({required String uid}) async {
    // 主要使用UAPI获取用户信息
    final uapiResult = await _getUserInfoFromUAPI(uid);
    if (uapiResult != null) {
      return uapiResult;
    }
    
    // 如果UAPI失败，记录日志并返回null（不尝试B站官方API，避免被限制）
    print('UAPI获取用户信息失败，使用默认数据');
    return null;
  }
  
  // 从UAPI获取用户信息
  static Future<UserInfoData?> _getUserInfoFromUAPI(String uid) async {
    try {
      final url = '$_baseUrl/userinfo?uid=$uid';
      final dio = Dio();
      
      // 添加请求头以避免被阻止
      dio.options.headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
      };
      
      print('正在请求用户信息(UAPI): $url');
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print('收到响应(UAPI): ${response.data}');
        // 检查响应数据格式
        if (response.data is Map<String, dynamic>) {
          // 直接从UAPI响应创建UserInfoData对象
          final data = response.data;
          final userInfo = UserInfoData(
            mid: data['mid'],
            name: data['name'],
            sex: data['sex'],
            face: data['face'],
            sign: data['sign'],
            level: data['level'],
            following: data['following'],
            follower: data['follower'],
            likeNum: 0, // UAPI可能不提供此信息
            vip: data['vip_type'] != null && data['vip_status'] != null
              ? Vip(
                  type: data['vip_type'],
                  status: data['vip_status'],
                  label: Label(
                    text: data['vip_type'] == 1 ? "大会员" : data['vip_type'] == 2 ? "年度大会员" : "大会员",
                    labelTheme: "vip",
                  ),
                )
              : null,
          );
          
          print('成功获取用户信息(UAPI): ${userInfo.name}');
          return userInfo;
        } else {
          print('Invalid response format(UAPI): ${response.data}');
        }
      } else {
        print('HTTP Error(UAPI): ${response.statusCode}');
        print('响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('Exception occurred while fetching user info from UAPI: $e');
      print('Stack trace: $stackTrace');
    }
    
    return null;
  }
}