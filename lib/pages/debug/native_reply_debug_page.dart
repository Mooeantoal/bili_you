import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/view_v2.dart';

/// 原生评论区调试页面
class NativeReplyDebugPage extends StatefulWidget {
  const NativeReplyDebugPage({Key? key}) : super(key: key);

  @override
  State<NativeReplyDebugPage> createState() => _NativeReplyDebugPageState();
}

class _NativeReplyDebugPageState extends State<NativeReplyDebugPage> {
  String _debugInfo = '准备开始调试...';
  bool _isDebugging = false;
  final TextEditingController _bvidController = TextEditingController(text: 'BV1xx411c7mD');

  /// 显示错误弹窗
  void _showErrorDialog(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 建议切换到网页版评论区
              _showSwitchToWebViewDialog();
            },
            child: Text('切换到网页版'),
          ),
        ],
      ),
    );
  }

  /// 显示成功弹窗
  void _showSuccessDialog(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示切换到网页版的建议弹窗
  void _showSwitchToWebViewDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('建议切换评论区'),
        content: Text('检测到原生评论区可能存在问题，建议暂时切换到网页版评论区使用。\n\n切换方法：设置 → 通用设置 → 视频 → 关闭"使用原生评论区"'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 自动切换到网页版
              SettingsUtil.setValue(SettingsStorageKeys.useNativeComments, false);
              Get.snackbar(
                '设置已更新',
                '已切换到网页版评论区，请重新打开视频',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('自动切换'),
          ),
        ],
      ),
    );
  }

  /// 调试原生评论区
  Future<void> _debugNativeReply() async {
    setState(() {
      _isDebugging = true;
      _debugInfo = '开始调试原生评论区...\n';
    });

    try {
      String bvid = _bvidController.text.trim();
      if (bvid.isEmpty) {
        _showErrorDialog('输入错误', 'BVID不能为空，请输入有效的BVID');
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

      if (!useNativeComments) {
        _showErrorDialog(
          '设置问题', 
          '原生评论区功能已关闭。\n\n请在"设置 → 通用设置 → 视频"中开启"使用原生评论区"选项。'
        );
        return;
      }

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
        _showErrorDialog(
          'BVID转换失败', 
          '无法将BVID转换为AVID。\n\n错误信息: $e\n\n请检查BVID格式是否正确（例如: BV1xx411c7mD）'
        );
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
        });

        // 检查是否有评论数据
        if (result.page.acount == 0) {
          _showErrorDialog(
            '无评论数据',
            '该视频暂无评论或评论区已关闭。\n\n建议：\n1. 尝试其他有评论的视频\n2. 检查视频是否存在\n3. 使用网页版评论区'
          );
        } else {
          // 显示成功信息
          String successInfo = '原生评论区工作正常！\n\n';
          successInfo += '总评论数: ${result.page.acount}\n';
          successInfo += '当前页评论数: ${result.replies.length}\n';
          successInfo += '热评数: ${result.hots.length}';
          
          if (result.replies.isNotEmpty) {
            successInfo += '\n\n评论示例:\n';
            for (int i = 0; i < result.replies.length && i < 2; i++) {
              var comment = result.replies[i];
              String message = comment.content.message.length > 30 
                  ? comment.content.message.substring(0, 30) + '...' 
                  : comment.content.message;
              successInfo += '${i + 1}. ${comment.member.uname}: $message\n';
            }
          }
          
          _showSuccessDialog('调试成功', successInfo);
        }

      } catch (e) {
        setState(() {
          _debugInfo += '   - ❌ API调用失败: $e\n';
        });

        // 分析错误类型并显示弹窗
        String errorTitle;
        String errorContent;
        
        if (e.toString().contains('-404')) {
          errorTitle = '评论区不存在 (-404)';
          errorContent = '该视频的评论区不存在或已关闭。\n\n可能原因:\n• 视频不存在\n• 评论区被关闭\n• 视频ID错误\n\n建议:\n1. 检查视频是否正常播放\n2. 尝试其他视频\n3. 使用网页版评论区';
        } else if (e.toString().contains('-403')) {
          errorTitle = '访问被限制 (-403)';
          errorContent = '评论区访问被限制。\n\n可能原因:\n• 需要登录账号\n• 账号权限不足\n• 地区限制\n\n建议:\n1. 登录B站账号\n2. 检查账号状态\n3. 使用网页版评论区';
        } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          errorTitle = '网络超时';
          errorContent = '网络连接超时。\n\n可能原因:\n• 网络不稳定\n• 服务器响应慢\n• 防火墙阻拦\n\n建议:\n1. 检查网络连接\n2. 稍后重试\n3. 切换网络';
        } else if (e.toString().contains('SocketException')) {
          errorTitle = '网络连接错误';
          errorContent = '无法连接到服务器。\n\n可能原因:\n• 无网络连接\n• DNS解析失败\n• 防火墙阻拦\n\n建议:\n1. 检查网络连接\n2. 检查DNS设置\n3. 关闭VPN或代理';
        } else {
          errorTitle = '未知错误';
          errorContent = '发生未知错误。\n\n错误信息:\n$e\n\n建议:\n1. 重试操作\n2. 重启应用\n3. 使用网页版评论区';
        }
        
        _showErrorDialog(errorTitle, errorContent);
      }

    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ 调试过程中发生未知错误: $e\n';
      });
      
      _showErrorDialog(
        '调试失败', 
        '调试过程中发生未知错误。\n\n错误信息: $e\n\n请重试或联系开发者。'
      );
    } finally {
      setState(() {
        _isDebugging = false;
        _debugInfo += '\n调试完成。\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('原生评论区调试'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          '调试说明',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('此工具用于诊断原生评论区无法加载的问题：'),
                    SizedBox(height: 4),
                    Text('• 检查评论区设置是否正确'),
                    Text('• 测试BVID转换功能'),
                    Text('• 验证评论API连接'),
                    Text('• 提供具体的错误分析和解决建议'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            Text(
              '测试视频BVID:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _bvidController,
              decoration: InputDecoration(
                hintText: '输入BVID，如: BV1xx411c7mD',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixIcon: Icon(Icons.video_library),
              ),
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDebugging ? null : _debugNativeReply,
                    icon: _isDebugging 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.bug_report),
                    label: Text(_isDebugging ? '调试中...' : '开始调试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    String testBvid = _bvidController.text.trim();
                    if (testBvid.isEmpty) {
                      Get.snackbar('提示', '请先输入BVID');
                      return;
                    }
                    
                    Get.to(() => Scaffold(
                      appBar: AppBar(title: Text('实际评论区测试')),
                      body: ReplyPageV2(bvid: testBvid),
                    ));
                  },
                  icon: Icon(Icons.preview),
                  label: Text('测试评论区'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            Text(
              '调试日志:',
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