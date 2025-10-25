import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  final dio = Dio();
  
  try {
    // 测试获取评论数据
    final url = 'https://uapis.cn/api/v1/social/bilibili/replies?oid=1559365249&sort=0&ps=20&pn=1';
    print('请求URL: $url');
    
    final response = await dio.get(url);
    print('响应状态码: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = response.data;
      print('响应数据类型: ${data.runtimeType}');
      
      // 检查是否有code字段
      if (data is Map && data.containsKey('code')) {
        print('API返回code: ${data['code']}');
        if (data['code'] != 0) {
          print('错误信息: ${data['message']}');
        }
      }
      
      // 检查是否有replies字段
      if (data is Map && data.containsKey('replies')) {
        print('成功获取到评论数据');
        if (data['replies'] is List) {
          print('评论数量: ${data['replies'].length}');
        }
      } else {
        print('响应数据结构: ${data.keys}');
      }
    } else {
      print('HTTP错误: ${response.statusCode}');
      print('错误内容: ${response.data}');
    }
  } catch (e) {
    print('发生异常: $e');
    if (e is DioException) {
      print('Dio错误类型: ${e.type}');
      print('响应信息: ${e.response?.data}');
    }
  }
}