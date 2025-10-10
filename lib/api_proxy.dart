import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  // 创建HTTP服务器，使用端口8081避免冲突
  var server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8081,
  );
  
  print('API代理服务器运行在 http://localhost:8081');
  
  // 创建Dio实例用于发起请求
  final dio = Dio();
  
  // 添加拦截器用于调试
  dio.interceptors.add(LogInterceptor(
    responseBody: true,
    requestBody: true,
    responseHeader: false,
    requestHeader: false,
  ));
  
  await for (HttpRequest request in server) {
    try {
      // 处理CORS预检请求
      if (request.method == 'OPTIONS') {
        request.response
          ..headers.add('Access-Control-Allow-Origin', '*')
          ..headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ..headers.add('Access-Control-Allow-Headers', 'Content-Type, User-Agent, Referer')
          ..statusCode = 200
          ..close();
        continue;
      }
      
      // 解析请求路径
      final path = request.uri.path;
      final query = request.uri.query;
      
      print('收到请求: ${request.method} $path?$query');
      
      // 构建目标URL
      String targetUrl;
      if (path.startsWith('/bilibili/')) {
        final apiPath = path.substring(10); // 移除 '/bilibili/' 前缀
        targetUrl = 'https://api.bilibili.com/$apiPath';
        if (query.isNotEmpty) {
          targetUrl += '?$query';
        }
      } else {
        request.response
          ..statusCode = 404
          ..write('Not Found')
          ..close();
        continue;
      }
      
      print('转发请求到: $targetUrl');
      
      // 设置请求头
      final headers = <String, dynamic>{};
      
      // 添加默认的Bilibili请求头
      headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36';
      headers['Referer'] = 'https://www.bilibili.com/';
      headers['Accept'] = 'application/json, text/plain, */*';
      headers['Accept-Encoding'] = 'gzip, deflate, br';
      headers['Accept-Language'] = 'zh-CN,zh;q=0.9,en;q=0.8,en-US;q=0.7,en-GB;q=0.6';
      
      print('请求头: $headers');
      
      // 发起请求
      final response = await dio.get(
        targetUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
      );
      
      print('收到响应，状态码: ${response.statusCode}');
      
      // 设置响应头
      request.response
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..headers.add('Content-Type', 'application/json; charset=utf-8')
        ..statusCode = response.statusCode ?? 200;
      
      // 写入响应数据
      request.response.write(jsonEncode(response.data));
      
    } catch (e, stackTrace) {
      print('请求处理失败: $e');
      print('堆栈跟踪: $stackTrace');
      
      request.response
        ..statusCode = 500
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..headers.add('Content-Type', 'application/json; charset=utf-8')
        ..write(jsonEncode({
          'error': 'Proxy Error',
          'message': e.toString(),
        }));
    }
    
    await request.response.close();
  }
}