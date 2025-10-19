import 'package:flutter/material.dart';
import 'package:bili_you/common/api/piliplus_reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart'; // 添加这个导入

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({Key? key}) : super(key: key);

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _result = '';
  bool _isLoading = false;

  Future<void> _testGetReply() async {
    setState(() {
      _isLoading = true;
      _result = '正在请求...';
    });

    try {
      final replyInfo = await PiliPlusReplyApi.getReply(
        oid: '1559365249', // 使用指定视频的aid
        pageNum: 1,
        type: ReplyType.video, // 现在应该能识别ReplyType了
        sort: ReplySort.like,
      );

      setState(() {
        _result = '获取评论成功!\n'
            '普通评论数量: ${replyInfo.replies.length}\n'
            '热门评论数量: ${replyInfo.topReplies.length}\n'
            '总评论数: ${replyInfo.replyCount}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '获取评论失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetReply,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('测试获取评论'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}