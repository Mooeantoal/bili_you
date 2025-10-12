import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:bili_you/common/utils/http_utils.dart';

class UserInfoApi {
  /// 根据用户mid获取用户信息
  static Future<Map<String, dynamic>> getUserInfo(int mid) async {
    final url = 'https://uapis.cn/api/v1/social/bilibili/userinfo?mid=$mid';
    
    try {
      final response = await HttpUtils().get(url);
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }
}