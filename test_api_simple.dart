import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  print('=== BiliYou API测试 ===');
  
  final dio = Dio();
  
  try {
    // 测试BV号
    const bvid = 'BV1joHwzBEJK';
    print('测试BV号: $bvid');
    
    // 获取视频信息
    print('正在获取视频信息...');
    final infoResponse = await dio.get(
      'https://api.bilibili.com/x/web-interface/view?bvid=$bvid',
    );
    
    if (infoResponse.statusCode == 200 && infoResponse.data['code'] == 0) {
      final data = infoResponse.data['data'];
      final cid = data['cid'];
      final title = data['title'];
      print('视频标题: $title');
      print('CID: $cid');
      
      // 获取播放信息
      print('正在获取播放信息...');
      final playResponse = await dio.get(
        'https://api.bilibili.com/x/player/playurl',
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
          'fnval': 4048, // 请求所有格式
          'fnver': 0,
          'fourk': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
            'Referer': 'https://www.bilibili.com/video/$bvid',
          },
        ),
      );
      
      if (playResponse.statusCode == 200 && playResponse.data['code'] == 0) {
        final playData = playResponse.data['data'];
        print('播放信息获取成功');
        
        // 检查是否有DASH流
        if (playData['dash'] != null) {
          final dash = playData['dash'];
          print('DASH流信息:');
          
          // 视频流
          if (dash['video'] != null && dash['video'].isNotEmpty) {
            final videoStreams = dash['video'] as List;
            print('  视频流数量: ${videoStreams.length}');
            if (videoStreams.isNotEmpty) {
              final firstStream = videoStreams[0];
              print('  最佳视频质量: ${firstStream['id']}');
              print('  视频编码: ${firstStream['codecs']}');
              print('  视频URL: ${firstStream['baseUrl']}');
            }
          }
          
          // 音频流
          if (dash['audio'] != null && dash['audio'].isNotEmpty) {
            final audioStreams = dash['audio'] as List;
            print('  音频流数量: ${audioStreams.length}');
            if (audioStreams.isNotEmpty) {
              final firstStream = audioStreams[0];
              print('  最佳音频质量: ${firstStream['id']}');
              print('  音频编码: ${firstStream['codecs']}');
              print('  音频URL: ${firstStream['baseUrl']}');
            }
          }
        } else {
          print('没有DASH流信息');
        }
      } else {
        print('获取播放信息失败: ${playResponse.data}');
      }
    } else {
      print('获取视频信息失败: ${infoResponse.data}');
    }
    
    print('=== 测试完成 ===');
  } catch (e, stackTrace) {
    print('测试过程中发生错误: $e');
    print('堆栈跟踪: $stackTrace');
  }
  
  // 等待用户按键后退出
  print('按任意键退出...');
  stdin.readLineSync();
}