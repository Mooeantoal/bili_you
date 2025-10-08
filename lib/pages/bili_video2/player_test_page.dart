import 'package:bili_you/pages/bili_video2/bili_video_page.dart';
import 'package:bili_you/pages/bili_video2/bili_media.dart';
import 'package:flutter/material.dart';

class PlayerTestPage extends StatelessWidget {
  const PlayerTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Test'),
      ),
      body: BiliVideoPage2(
        media: BiliMedia(
          bvid: 'BV1GJ411x7h7', // 测试用的视频BV号
          cid: 170001, // 测试用的CID
        ),
      ),
    );
  }
}