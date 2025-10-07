import 'package:bili_you/pages/bili_video2/bili_video_page.dart';
import 'package:bili_you/pages/bili_video2/bili_media.dart';
import 'package:flutter/material.dart';

class BiliVideo2TestPage extends StatelessWidget {
  const BiliVideo2TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiliVideo2 Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 测试用的视频BV号和CID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BiliVideoPage2(
                  media: BiliMedia(
                    bvid: 'BV1GJ411x7h7', // 示例BV号
                    cid: 170001, // 示例CID
                  ),
                ),
              ),
            );
          },
          child: const Text('Open Video Player'),
        ),
      ),
    );
  }
}