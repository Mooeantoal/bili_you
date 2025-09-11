import 'package:flutter/material.dart';
import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';

/// 测试修复后的评论API
void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '评论API测试',
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _result = '点击按钮开始测试...';
  bool _isLoading = false;

  Future<void> _testCommentApi() async {
    setState(() {
      _isLoading = true;
      _result = '正在测试...';
    });

    try {
      // 测试正常视频
      await _testVideo('BV1xx411c7mD', '正常视频');
      
      // 测试可能有问题的视频ID（模拟-404错误）
      await _testVideo('BV1234567890', '不存在的视频');
      
    } catch (e) {
      setState(() {
        _result += '\n❌ 测试过程中发生错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testVideo(String bvid, String description) async {
    try {
      int avid = BvidAvidUtil.bvid2Av(bvid);
      
      setState(() {
        _result += '\n\n🔍 测试 $description ($bvid -> av$avid)';
      });
      
      var result = await ReplyApiV2.getComments(
        type: 1,
        oid: avid.toString(),
        sort: 1,
        ps: 10,
        pn: 1,
      );
      
      setState(() {
        _result += '\n✅ 成功获取评论:';
        _result += '\n  - 总评论数: ${result.page.acount}';
        _result += '\n  - 当前页评论数: ${result.replies.length}';
        _result += '\n  - 热评数: ${result.hots.length}';
      });
      
    } catch (e) {
      setState(() {
        _result += '\n❌ $description 测试失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评论API错误处理测试'),
        backgroundColor: Colors.pink[400],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '测试内容:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('1. 正常视频评论获取'),
            Text('2. 异常情况处理（-404错误等）'),
            Text('3. 错误信息友好提示'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCommentApi,
              child: _isLoading 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('测试中...'),
                    ],
                  )
                : Text('开始测试'),
            ),
            SizedBox(height: 20),
            Text(
              '测试结果:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}