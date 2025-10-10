import 'package:bili_you/pages/bili_video2/debug_route.dart';
import 'package:bili_you/pages/bili_video2/video_test_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BiliYou Video Debug',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatelessWidget {
  const DebugHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiliYou 视频调试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'BiliYou 视频播放调试工具',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                DebugRoute.openDebugVideoTestPage();
              },
              child: const Text('打开视频播放测试页面'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                VideoTestRoute.openVideoTestPage();
              },
              child: const Text('打开完整视频测试页面'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                VideoTestRoute.openAdvancedVideoDebugPage();
              },
              child: const Text('打开高级视频调试页面'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                VideoTestRoute.openDetailedApiDebugPage();
              },
              child: const Text('打开详细API诊断页面'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                VideoTestRoute.openDashStreamDebugPage();
              },
              child: const Text('打开DASH流诊断页面'),
            ),
            const SizedBox(height: 20),
            const Text(
              '说明：\n'
              '1. 第一个按钮打开API测试页面\n'
              '2. 第二个按钮打开完整视频播放测试页面\n'
              '3. 第三个按钮打开高级视频调试页面\n'
              '4. 第四个按钮打开详细API诊断页面\n'
              '5. 第五个按钮打开DASH流诊断页面\n'
              '6. 在测试页面中输入BV号或使用默认BV号\n'
              '7. 点击相应按钮进行测试\n'
              '8. 查看调试信息区域以了解测试过程',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}