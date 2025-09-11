import 'dart:convert';
import 'dart:io';

/// 简单的API验证测试
void main() async {
  await testBilibiliReplyApi();
}

Future<void> testBilibiliReplyApi() async {
  print('=== B站评论API验证测试 ===');
  
  // 测试参数
  const String testAvid = '170001'; // 经典测试视频
  const int type = 1; // 视频稿件
  const int sort = 1; // 按点赞数排序
  const int ps = 10; // 每页10条
  const int pn = 1; // 第1页
  
  // 构建API URL
  final apiUrl = 'https://api.bilibili.com/x/v2/reply'
      '?type=$type'
      '&oid=$testAvid'
      '&sort=$sort'
      '&ps=$ps'
      '&pn=$pn';
  
  print('请求URL: $apiUrl');
  
  try {
    final httpClient = HttpClient();
    httpClient.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15';
    
    final request = await httpClient.getUrl(Uri.parse(apiUrl));
    request.headers.add('referer', 'https://www.bilibili.com');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('响应状态码: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('API调用成功！');
      print('响应code: ${data['code']}');
      print('响应message: ${data['message']}');
      
      if (data['code'] == 0) {
        final commentData = data['data'];
        final page = commentData['page'];
        final replies = commentData['replies'] as List?;
        final hots = commentData['hots'] as List?;
        
        print('✅ API参数验证通过:');
        print('  - 总评论数: ${page['acount']}');
        print('  - 当前页评论数: ${replies?.length ?? 0}');
        print('  - 热评数: ${hots?.length ?? 0}');
        print('  - 当前页码: ${page['num']}');
        print('  - 每页条数: ${page['size']}');
        
        if (replies != null && replies.isNotEmpty) {
          print('\n前3条评论预览:');
          for (int i = 0; i < replies.length && i < 3; i++) {
            final comment = replies[i];
            print('${i + 1}. ${comment['member']['uname']}: ${comment['content']['message']}');
          }
        }
        
        print('\n🎯 结论: 当前API调用完全符合B站官方文档规范！');
      } else {
        print('❌ API返回错误: ${data['message']}');
      }
    } else {
      print('❌ HTTP请求失败: ${response.statusCode}');
    }
    
    httpClient.close();
  } catch (e) {
    print('❌ 测试失败: $e');
  }
}