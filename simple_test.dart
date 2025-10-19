import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  try {
    print('测试API连接...');
    
    // 添加一些基本的配置
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 10);
    
    // 测试评论API
    final url = "https://uapis.cn/api/v1/social/bilibili/replies?oid=1559365249&ps=10&pn=1";
    print('请求URL: $url');
    
    final response = await dio.get(url);
    print('响应状态码: ${response.statusCode}');
    print('响应数据: ${response.data}');
    
  } on DioException catch (e) {
    print('DioException: ${e.type}');
    print('状态码: ${e.response?.statusCode}');
    print('错误信息: ${e.message}');
    if (e.response != null) {
      print('响应数据: ${e.response?.data}');
    }
  } catch (e) {
    print('其他错误: $e');
  }
}