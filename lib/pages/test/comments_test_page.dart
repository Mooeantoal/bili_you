import 'package:flutter/material.dart';
import 'package:bili_you/pages/test/reply/reply_page.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

class CommentsTestPage extends StatelessWidget {
  const CommentsTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论测试页面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReplyPage(
                      oid: '113309709829793', // 示例视频aid (BV1xhmnYFEir的aid)
                      type: ReplyType.video,
                      videoTitle: 'BV1xhmnYFEir',
                    ),
                  ),
                );
              },
              child: const Text('打开评论页面'),
            ),
            const SizedBox(height: 16),
            const Text(
              '测试视频: BV1xhmnYFEir\n'
              '视频aid: 113309709829793',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}