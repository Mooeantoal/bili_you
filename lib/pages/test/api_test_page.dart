import 'package:flutter/material.dart';
import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

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
      final replyInfo = await ReplyApi.getReply(
        oid: '1559365249', // 使用指定视频的aid
        pageNum: 1,
        type: ReplyType.video,
        sort: ReplySort.like,
      );

      setState(() {
        _result = '获取评论成功!\n'
            '普通评论数量: ${replyInfo.replies.length}\n'
            '热门评论数量: ${replyInfo.topReplies.length}\n'
            '总评论数: ${replyInfo.replyCount}\n'
            'UP主mid: ${replyInfo.upperMid}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '获取评论失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetReplyReply() async {
    setState(() {
      _isLoading = true;
      _result = '正在请求楼中楼评论...';
    });

    try {
      // 首先获取一些评论，然后尝试获取第一条评论的楼中楼评论
      final replyInfo = await ReplyApi.getReply(
        oid: '1559365249',
        pageNum: 1,
        type: ReplyType.video,
        sort: ReplySort.like,
      );

      if (replyInfo.replies.isNotEmpty) {
        final firstReply = replyInfo.replies.first;
        final replyReplyInfo = await ReplyApi.getReplyReply(
          oid: '1559365249',
          rootId: firstReply.rpid,
          pageNum: 1,
          pageSize: 20,
        );

        setState(() {
          _result = '获取楼中楼评论成功!\n'
              '根评论: ${firstReply.content.message}\n'
              '楼中楼评论数量: ${replyReplyInfo.replies.length}\n'
              '总回复数: ${replyReplyInfo.replyCount}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _result = '没有找到评论，无法测试楼中楼评论';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = '获取楼中楼评论失败: $e';
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGetReply,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('测试获取评论'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGetReplyReply,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('测试楼中楼评论'),
                  ),
                ),
              ],
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