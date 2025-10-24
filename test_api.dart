import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  try {
    print('正在测试API连接...');
    
    // 测试视频信息API
    const videoUrl = "https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid=BV1GJ411x7h7";
    print('请求视频信息: $videoUrl');
    final videoResponse = await dio.get(videoUrl);
    print('视频信息响应状态码: ${videoResponse.statusCode}');
    print('视频信息响应数据: ${videoResponse.data}');
    
    // 获取视频的aid
    final aid = videoResponse.data['data']['aid'];
    print('视频aid: $aid');
    
    // 测试评论API
    final commentsUrl = "https://uapis.cn/api/v1/social/bilibili/replies?oid=$aid&ps=10&pn=1";
    print('请求评论数据: $commentsUrl');
    final commentsResponse = await dio.get(commentsUrl);
    print('评论数据响应状态码: ${commentsResponse.statusCode}');
    print('评论数据响应数据: ${commentsResponse.data}');
    
  } catch (e) {
    print('请求出错: $e');
  }
}