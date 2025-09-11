import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/view_v2.dart';

/// 原生评论区调试工具
void main() {
  runApp(NativeReplyDebugApp());
}

class NativeReplyDebugApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '原生评论区调试',
      home: NativeReplyDebugPage(),
    );
  }
}

class NativeReplyDebugPage extends StatefulWidget {
  @override
  _NativeReplyDebugPageState createState() => _NativeReplyDebugPageState();
}

class _NativeReplyDebugPageState extends State<NativeReplyDebugPage> {
  String _debugInfo = '准备开始调试...';
  bool _isDebugging = false;
  final TextEditingController _bvidController = TextEditingController(text: 'BV1xx411c7mD');

  Future<void> _debugNativeReply() async {
    setState(() {
      _isDebugging = true;
      _debugInfo = '开始调试原生评论区...\n';
    });

    try {
      String bvid = _bvidController.text.trim();
      if (bvid.isEmpty) {
        setState(() {
          _debugInfo += '❌ BVID不能为空\n';
        });
        return;
      }

      // 1. 检查设置
      bool useNativeComments = SettingsUtil.getValue(
        SettingsStorageKeys.useNativeComments,
        defaultValue: true,
      );
      
      setState(() {
        _debugInfo += '1. 检查设置:\n';
        _debugInfo += '   - 使用原生评论区: $useNativeComments\n';
      });

      // 2. 测试BVID转换
      setState(() {
        _debugInfo += '\n2. 测试BVID转换:\n';
        _debugInfo += '   - 输入BVID: $bvid\n';
      });

      int avid;
      try {
        avid = BvidAvidUtil.bvid2Av(bvid);
        setState(() {
          _debugInfo += '   - ✅ 转换成功: av$avid\n';
        });
      } catch (e) {
        setState(() {
          _debugInfo += '   - ❌ BVID转换失败: $e\n';
        });
        return;
      }

      // 3. 测试API调用
      setState(() {
        _debugInfo += '\n3. 测试API调用:\n';
        _debugInfo += '   - API端点: https://api.bilibili.com/x/v2/reply\n';
        _debugInfo += '   - 参数: type=1, oid=$avid, sort=1, ps=20, pn=1\n';
      });

      try {
        var result = await ReplyApiV2.getComments(
          type: 1,
          oid: avid.toString(),
          sort: 1,
          ps: 20,
          pn: 1,
        );

        setState(() {
          _debugInfo += '   - ✅ API调用成功\n';
          _debugInfo += '   - 总评论数: ${result.page.acount}\n';
          _debugInfo += '   - 当前页评论数: ${result.replies.length}\n';
          _debugInfo += '   - 热评数: ${result.hots.length}\n';
          
          if (result.replies.isNotEmpty) {
            _debugInfo += '\n4. 评论示例:\n';
            for (int i = 0; i < result.replies.length && i < 3; i++) {
              var comment = result.replies[i];
              _debugInfo += '   ${i + 1}. ${comment.member.uname}: ${comment.content.message.length > 50 ? comment.content.message.substring(0, 50) + '...' : comment.content.message}\n';
            }
          }
        });

      } catch (e) {
        setState(() {
          _debugInfo += '   - ❌ API调用失败: $e\n';
          
          // 分析错误类型
          String errorAnalysis = _analyzeError(e.toString());
          _debugInfo += '\n错误分析:\n$errorAnalysis\n';
        });
      }

    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ 调试过程中发生未知错误: $e\n';
      });
    } finally {
      setState(() {
        _isDebugging = false;
        _debugInfo += '\n调试完成。\n';
      });
    }
  }

  String _analyzeError(String error) {
    if (error.contains('-404')) {
      return '''
🔍 -404错误分析:
- 可能原因: 评论区不存在或已关闭
- 解决方案: 
  1. 检查视频是否存在
  2. 检查评论区是否开放
  3. 尝试使用网页版评论区
  4. 检查网络连接''';
    } else if (error.contains('-403')) {
      return '''
🔍 -403错误分析:
- 可能原因: 访问被限制
- 解决方案:
  1. 检查是否需要登录
  2. 检查账号状态
  3. 稍后重试''';
    } else if (error.contains('timeout') || error.contains('TimeoutException')) {
      return '''
🔍 超时错误分析:
- 可能原因: 网络连接不稳定
- 解决方案:
  1. 检查网络连接
  2. 重试请求
  3. 检查代理设置''';
    } else if (error.contains('SocketException')) {
      return '''
🔍 网络错误分析:
- 可能原因: 网络连接问题
- 解决方案:
  1. 检查网络连接
  2. 检查防火墙设置
  3. 尝试切换网络''';
    } else {
      return '''
🔍 未知错误分析:
- 错误信息: $error
- 建议: 检查日志获取更多信息''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('原生评论区调试工具'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '调试步骤:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('1. 检查原生评论区设置'),
            Text('2. 测试BVID转换'),
            Text('3. 测试API调用'),
            Text('4. 分析错误原因'),
            
            SizedBox(height: 20),
            
            Row(
              children: [
                Text('测试视频BVID: '),
                Expanded(
                  child: TextField(
                    controller: _bvidController,
                    decoration: InputDecoration(
                      hintText: '输入BVID，如: BV1xx411c7mD',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isDebugging ? null : _debugNativeReply,
                  child: _isDebugging 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('调试中...'),
                        ],
                      )
                    : Text('开始调试'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text('实际评论区测试')),
                          body: ReplyPageV2(bvid: _bvidController.text.trim()),
                        ),
                      ),
                    );
                  },
                  child: Text('测试评论区'),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            Text(
              '调试结果:',
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
                    _debugInfo,
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