import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  // 初始化MediaKit
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '视频播放测试',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoTestPage(),
    );
  }
}

class VideoTestPage extends StatefulWidget {
  const VideoTestPage({super.key});

  @override
  State<VideoTestPage> createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  late final Player player;
  late final VideoController videoController;

  @override
  void initState() {
    super.initState();
    // 创建播放器和控制器
    player = Player();
    videoController = VideoController(player);
    
    // 播放测试视频
    _playTestVideo();
  }

  Future<void> _playTestVideo() async {
    try {
      await player.open(Media('https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'));
      await player.play();
    } catch (e) {
      print('播放视频时出错: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放测试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 200,
              child: Video(
                controller: videoController,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playTestVideo,
              child: const Text('重新播放'),
            ),
          ],
        ),
      ),
    );
  }
}