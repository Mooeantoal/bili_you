import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/bili_video2/bili_video_page_new.dart';

class TestVideoPageNew extends StatefulWidget {
  const TestVideoPageNew({Key? key}) : super(key: key);

  @override
  State<TestVideoPageNew> createState() => _TestVideoPageNewState();
}

class _TestVideoPageNewState extends State<TestVideoPageNew> {
  final TextEditingController _bvidController = TextEditingController();
  final TextEditingController _cidController = TextEditingController();

  @override
  void dispose() {
    _bvidController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  void _navigateToVideo() {
    final bvid = _bvidController.text.trim();
    final cidText = _cidController.text.trim();
    
    if (bvid.isEmpty) {
      Get.snackbar('错误', '请输入BV号');
      return;
    }
    
    if (cidText.isEmpty) {
      Get.snackbar('错误', '请输入CID');
      return;
    }
    
    final cid = int.tryParse(cidText);
    if (cid == null) {
      Get.snackbar('错误', 'CID必须是数字');
      return;
    }
    
    // 跳转到新的视频播放页面
    Get.to(() => BiliVideoPageNew(
      bvid: bvid,
      cid: cid,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新视频播放测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '请输入视频BV号和CID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bvidController,
              decoration: const InputDecoration(
                labelText: 'BV号',
                hintText: '例如：BV1GJ411x7h7',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cidController,
              decoration: const InputDecoration(
                labelText: 'CID',
                hintText: '例如：123456',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToVideo,
              child: const Text('跳转到视频'),
            ),
            const SizedBox(height: 16),
            const Text(
              '示例输入：\n'
              '• BV号：BV1GJ411x7h7\n'
              '• CID：可以输入任意数字，如123456',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}