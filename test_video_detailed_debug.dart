import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_play_api.dart';
import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  // 初始化Dio
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(request: true, responseHeader: true, responseBody: false));
  
  // 测试BV号
  const bvid = 'BV1joHwzBEJK';
  
  print('=== 视频播放详细调试 ===');
  print('测试BV号: $bvid');
  
  try {
    // 1. 获取视频信息
    print('\n--- 1. 获取视频信息 ---');
    final videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
    final cid = videoInfo.cid;
    print('CID: $cid');
    print('视频标题: ${videoInfo.title}');
    
    // 2. 获取播放信息
    print('\n--- 2. 获取播放信息 ---');
    final playInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
    print('视频流数量: ${playInfo.videos.length}');
    print('音频流数量: ${playInfo.audios.length}');
    
    if (playInfo.videos.isEmpty) {
      print('错误: 没有可用的视频流');
      return;
    }
    
    // 3. 分析视频流
    print('\n--- 3. 分析视频流 ---');
    final bestVideo = playInfo.videos.first;
    print('最佳视频质量: ${bestVideo.quality}');
    print('视频编码: ${bestVideo.codecs}');
    print('视频带宽: ${bestVideo.bandWidth}');
    print('视频分辨率: ${bestVideo.width}x${bestVideo.height}');
    print('视频帧率: ${bestVideo.frameRate}');
    
    // 4. 分析音频流
    print('\n--- 4. 分析音频流 ---');
    if (playInfo.audios.isNotEmpty) {
      final bestAudio = playInfo.audios.first;
      print('最佳音频质量: ${bestAudio.quality}');
      print('音频编码: ${bestAudio.codecs}');
      print('音频带宽: ${bestAudio.bandWidth}');
    } else {
      print('没有音频流');
    }
    
    // 5. 测试视频URL
    print('\n--- 5. 测试视频URL ---');
    if (bestVideo.urls.isEmpty) {
      print('错误: 视频URL列表为空');
      return;
    }
    
    final videoUrl = bestVideo.urls.first;
    print('测试视频URL: $videoUrl');
    
    // 准备HTTP头部
    final headers = Map<String, String>.from(VideoPlayApi.videoPlayerHttpHeaders);
    headers['Referer'] = 'https://www.bilibili.com/video/$bvid/';
    headers['Range'] = 'bytes=0-1023'; // 只请求前1KB数据用于测试
    
    print('HTTP头部: $headers');
    
    try {
      final response = await dio.get(
        videoUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      
      print('视频URL测试结果:');
      print('  状态码: ${response.statusCode}');
      print('  内容长度: ${response.data.length} 字节');
      print('  内容类型: ${response.headers['content-type']?.first}');
      
      // 显示前几个字节的内容（避免显示太多二进制数据）
      if (response.data.length > 0) {
        print('  前100字节预览: ${response.data.sublist(0, response.data.length > 100 ? 100 : response.data.length)}');
      }
    } catch (e) {
      print('视频URL测试失败: $e');
    }
    
    // 6. 测试音频URL（如果存在）
    if (playInfo.audios.isNotEmpty && playInfo.audios.first.urls.isNotEmpty) {
      print('\n--- 6. 测试音频URL ---');
      final audioUrl = playInfo.audios.first.urls.first;
      print('测试音频URL: $audioUrl');
      
      try {
        final response = await dio.get(
          audioUrl,
          options: Options(
            headers: headers,
            responseType: ResponseType.bytes,
            followRedirects: true,
          ),
        );
        
        print('音频URL测试结果:');
        print('  状态码: ${response.statusCode}');
        print('  内容长度: ${response.data.length} 字节');
        print('  内容类型: ${response.headers['content-type']?.first}');
        
        if (response.data.length > 0) {
          print('  前100字节预览: ${response.data.sublist(0, response.data.length > 100 ? 100 : response.data.length)}');
        }
      } catch (e) {
        print('音频URL测试失败: $e');
      }
    }
    
    print('\n=== 调试完成 ===');
    
  } catch (e, stackTrace) {
    print('调试过程中发生错误: $e');
    print('堆栈跟踪: $stackTrace');
  }
}