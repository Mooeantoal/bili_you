import 'package:flutter/material.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/view.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

/// 测试网页版评论区
void main() {
  runApp(TestWebViewCommentsApp());
}

class TestWebViewCommentsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '网页版评论区测试',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestWebViewCommentsPage(),
    );
  }
}

class TestWebViewCommentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('网页版评论区测试'),
        backgroundColor: Colors.pink[400],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '功能特性:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('✅ PC端UA - 获取完整评论功能'),
                Text('✅ 只显示 #commentapp 元素'),
                Text('✅ 移动设备显示比例优化'),
                Text('✅ 响应式设计适配'),
                Text('✅ 触摸交互优化'),
              ],
            ),
          ),
          Expanded(
            child: ReplyPage(
              replyId: 'BV1xx411c7mD', // 经典测试视频
              replyType: ReplyType.video,
            ),
          ),
        ],
      ),
    );
  }
}