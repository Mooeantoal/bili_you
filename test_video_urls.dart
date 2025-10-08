import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // 测试视频BV1joHwzBEJK
  const bvid = 'BV1joHwzBEJK';
  const cid = '25874011694';
  
  print('测试视频 $bvid 的URL可访问性');
  
  final headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Referer': 'https://www.bilibili.com/',
  };
  
  // 获取播放信息
  final playUrl = 'https://api.bilibili.com/x/player/playurl?bvid=$bvid&cid=$cid&fnver=0&fnval=4048&fourk=1&force_host=2&try_look=1';
  
  try {
    print('正在获取播放信息...');
    final playResponse = await http.get(Uri.parse(playUrl), headers: headers);
    print('播放信息响应状态码: ${playResponse.statusCode}');
    
    if (playResponse.statusCode == 200) {
      final data = json.decode(playResponse.body);
      if (data['code'] == 0 && data['data'] != null) {
        final playData = data['data'];
        
        // 检查DASH信息
        if (playData['dash'] != null) {
          final dash = playData['dash'];
          print('DASH信息获取成功');
          print('视频流数量: ${dash['video']?.length ?? 0}');
          print('音频流数量: ${dash['audio']?.length ?? 0}');
          
          // 测试前几个视频URL
          if (dash['video'] != null && dash['video'].isNotEmpty) {
            for (int i = 0; i < dash['video'].length && i < 3; i++) {
              final video = dash['video'][i];
              final videoUrl = video['baseUrl'] ?? video['base_url'];
              if (videoUrl != null) {
                print('\n测试视频流 $i:');
                print('URL: ${videoUrl.substring(0, 60)}...');
                await testUrlAccessibility(videoUrl, headers);
              }
            }
          }
          
          // 测试前几个音频URL
          if (dash['audio'] != null && dash['audio'].isNotEmpty) {
            for (int i = 0; i < dash['audio'].length && i < 3; i++) {
              final audio = dash['audio'][i];
              final audioUrl = audio['baseUrl'] ?? audio['base_url'];
              if (audioUrl != null) {
                print('\n测试音频流 $i:');
                print('URL: ${audioUrl.substring(0, 60)}...');
                await testUrlAccessibility(audioUrl, headers);
              }
            }
          }
        } else {
          print('无DASH信息');
        }
      } else {
        print('获取播放数据失败: ${data['message']}');
      }
    } else {
      print('获取播放信息失败: ${playResponse.statusCode}');
    }
  } catch (e) {
    print('测试过程中发生错误: $e');
  }
  
  exit(0);
}

Future<void> testUrlAccessibility(String url, Map<String, String> headers) async {
  try {
    final response = await http.head(Uri.parse(url), headers: headers);
    print('  状态码: ${response.statusCode}');
    print('  Content-Type: ${response.headers['content-type'] ?? '未知'}');
    print('  Content-Length: ${response.headers['content-length'] ?? '未知'}');
    
    if (response.statusCode == 200) {
      print('  √ URL可访问');
    } else {
      print('  × URL不可访问');
    }
  } catch (e) {
    print('  × 访问URL时出错: $e');
  }
}