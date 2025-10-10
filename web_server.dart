import 'dart:io';
import 'dart:convert';

void main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8000,
  );
  
  print('服务器运行在 http://localhost:8000');
  
  await for (HttpRequest request in server) {
    // 处理CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
    
    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      await request.response.close();
      continue;
    }
    
    // 简单的路由处理
    if (request.uri.path == '/' || request.uri.path == '/index.html') {
      // 读取并返回index.html
      var file = File('web/index.html');
      if (await file.exists()) {
        request.response.headers.contentType = ContentType.html;
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = 404;
        request.response.write('404 Not Found');
      }
    } else if (request.uri.path == '/api_test.html') {
      // 读取并返回api_test.html
      var file = File('web/api_test.html');
      if (await file.exists()) {
        request.response.headers.contentType = ContentType.html;
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = 404;
        request.response.write('404 Not Found');
      }
    } else {
      // 处理静态文件
      var filePath = 'web${request.uri.path}';
      var file = File(filePath);
      if (await file.exists()) {
        // 根据文件扩展名设置内容类型
        if (filePath.endsWith('.html')) {
          request.response.headers.contentType = ContentType.html;
        } else if (filePath.endsWith('.css')) {
          request.response.headers.contentType = ContentType('text', 'css');
        } else if (filePath.endsWith('.js')) {
          request.response.headers.contentType = ContentType('application', 'javascript');
        } else if (filePath.endsWith('.png')) {
          request.response.headers.contentType = ContentType('image', 'png');
        } else if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
          request.response.headers.contentType = ContentType('image', 'jpeg');
        } else {
          request.response.headers.contentType = ContentType.binary;
        }
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = 404;
        request.response.write('404 Not Found');
      }
    }
    
    await request.response.close();
  }
}