import 'dart:io';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';

void main() async {
  print('=== BiliYou 视频API测试 ===');
  
  try {
    // 测试BV号
    const bvid = 'BV1joHwzBEJK';
    print('测试BV号: $bvid');
    
    // 获取视频信息
    print('正在获取视频信息...');
    final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
    print('视频标题: ${videoInfo.title}');
    print('CID: ${videoInfo.cid}');
    
    // 获取播放信息
    print('正在获取播放信息...');
    final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: videoInfo.cid);
    print('视频流数量: ${playInfo.videos.length}');
    print('音频流数量: ${playInfo.audios.length}');
    
    if (playInfo.videos.isNotEmpty) {
      final bestVideo = playInfo.videos.first;
      print('最佳视频质量: ${bestVideo.quality}');
      print('视频编码: ${bestVideo.codecs}');
      print('视频URL数量: ${bestVideo.urls.length}');
      
      if (bestVideo.urls.isNotEmpty) {
        print('第一个视频URL: ${bestVideo.urls.first}');
      }
    }
    
    if (playInfo.audios.isNotEmpty) {
      final bestAudio = playInfo.audios.first;
      print('最佳音频质量: ${bestAudio.quality}');
      print('音频编码: ${bestAudio.codecs}');
      print('音频URL数量: ${bestAudio.urls.length}');
      
      if (bestAudio.urls.isNotEmpty) {
        print('第一个音频URL: ${bestAudio.urls.first}');
      }
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