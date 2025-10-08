import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/pages/bili_video2/widgets/reply/reply_page.dart';
import 'package:flutter/material.dart';

class ReplyTestPage extends StatelessWidget {
  const ReplyTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply Test'),
      ),
      body: ReplyPage(
        replyId: '170001', // 测试用的视频ID
        replyType: ReplyType.video,
      ),
    );
  }
}