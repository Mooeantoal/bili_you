import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // 测试视频BV1joHwzBEJK
  const bvid = 'BV1joHwzBEJK';
  
  print('测试视频 $bvid 的可访问性');
  
  // 首先获取视频基本信息
  final infoUrl = 'https://api.bilibili.com/x/web-interface/view?bvid=$bvid';
  final infoHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Referer': 'https://www.bilibili.com/',
  };
  
  try {
    print('正在获取视频信息...');
    final infoResponse = await http.get(Uri.parse(infoUrl), headers: infoHeaders);
    print('视频信息响应状态码: ${infoResponse.statusCode}');
    
    if (infoResponse.statusCode == 200) {
      // 解析视频信息获取CID
      final infoData = infoResponse.body;
      print('视频信息获取成功');
      
      // 简单解析CID（实际应用中应该使用JSON解析）
      final cidMatch = RegExp(r'"cid":(\d+)').firstMatch(infoData);
      if (cidMatch != null) {
        final cid = cidMatch.group(1);
        print('视频CID: $cid');
        
        // 获取播放信息
        final playUrl = 'https://api.bilibili.com/x/player/playurl?bvid=$bvid&cid=$cid&fnver=0&fnval=4048&fourk=1&force_host=2&try_look=1';
        print('正在获取播放信息...');
        final playResponse = await http.get(Uri.parse(playUrl), headers: infoHeaders);
        print('播放信息响应状态码: ${playResponse.statusCode}');
        
        if (playResponse.statusCode == 200) {
          print('播放信息获取成功');
          // 这里可以进一步解析播放信息并测试视频URL
        } else {
          print('获取播放信息失败: ${playResponse.statusCode}');
        }
      } else {
        print('无法解析视频CID');
      }
    } else {
      print('获取视频信息失败: ${infoResponse.statusCode}');
    }
  } catch (e) {
    print('测试过程中发生错误: $e');
  }
  
  exit(0);
}