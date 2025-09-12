import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/log_export_util.dart';
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
  final TextEditingController _bvidController = TextEditingController(text: 'BV16hHDzSEzt');
  final FocusNode _bvidFocusNode = FocusNode(); // 添加焦点节点
  List<Map<String, dynamic>> _errorLogs = []; // 错误日志记录

  @override
  void dispose() {
    _bvidController.dispose();
    _bvidFocusNode.dispose();
    super.dispose();
  }

  /// 更新调试信息（避免频繁重建）
  void _updateDebugInfo(String info) {
    if (mounted) {
      setState(() {
        _debugInfo += info;
      });
    }
  }

  /// 设置调试状态
  void _setDebuggingState(bool isDebugging) {
    if (mounted) {
      setState(() {
        _isDebugging = isDebugging;
      });
    }
  }

  /// 记录错误日志
  void _logError(String type, String message, Map<String, dynamic> details) {
    _errorLogs.add({
      'timestamp': DateTime.now(),
      'type': type,
      'message': message,
      'details': details,
    });
  }

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
              _showDetailedErrorLogs();
            },
            child: Text('详细日志'),
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

  /// 显示详细错误日志
  void _showDetailedErrorLogs() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.list_alt, color: Colors.orange),
            SizedBox(width: 8),
            Text('详细错误日志'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _errorLogs.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 16),
                    Text('暂无错误日志'),
                    Text('调试过程正常', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _errorLogs.length,
                itemBuilder: (context, index) {
                  var log = _errorLogs[index];
                  return Card(
                    child: ExpansionTile(
                      title: Text(
                        log['type'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${log['timestamp'].toString().substring(0, 19)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      leading: Icon(
                        Icons.error_outline, 
                        color: _getErrorTypeColor(log['type']),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '错误信息:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  border: Border.all(color: Colors.red[200]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  log['message'],
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (log['details'].isNotEmpty) ...[
                                SizedBox(height: 12),
                                Text(
                                  '详细信息:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log['details'].entries
                                        .map((e) => '${e.key}: ${e.value}')
                                        .join('\n'),
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _errorLogs.clear();
              });
              Get.back();
              Get.snackbar(
                '已清空',
                '错误日志已清空',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('清空日志'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _exportLogsDialog();
            },
            child: Text('导出日志'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示导出日志选项对话框
  Future<void> _exportLogsDialog() async {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.file_download, color: Colors.blue),
            SizedBox(width: 8),
            Text('导出调试日志'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('选择导出方式:'),
            SizedBox(height: 16),
            
            // 完整导出选项
            ListTile(
              leading: Icon(Icons.save_alt, color: Colors.green),
              title: Text('保存到手机存储'),
              subtitle: Text('导出完整JSON格式日志到Downloads文件夹'),
              onTap: () async {
                Get.back();
                await _exportToStorage();
              },
            ),
            
            Divider(),
            
            // 快速分享选项
            ListTile(
              leading: Icon(Icons.share, color: Colors.orange),
              title: Text('快速分享'),
              subtitle: Text('生成文本格式用于即时分享'),
              onTap: () async {
                Get.back();
                await _quickShareLogs();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 导出到手机存储
  Future<void> _exportToStorage() async {
    if (_errorLogs.isEmpty) {
      Get.snackbar(
        '无日志可导出',
        '当前没有错误日志记录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('正在导出...'),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在保存日志文件'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await LogExportUtil.exportErrorLogs(_errorLogs);
      Get.back(); // 关闭进度对话框
      
      if (success) {
        Get.snackbar(
          '导出成功',
          '日志已保存到手机存储空间',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // 关闭进度对话框
      Get.snackbar(
        '导出失败',
        '保存日志时出现错误: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 快速分享日志
  Future<void> _quickShareLogs() async {
    if (_errorLogs.isEmpty) {
      Get.snackbar(
        '无日志可分享',
        '当前没有错误日志记录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await LogExportUtil.exportSimplifiedLogs(_errorLogs);
    } catch (e) {
      Get.snackbar(
        '分享失败',
        '生成分享内容时出现错误: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  Color _getErrorTypeColor(String type) {
    switch (type) {
      case 'API_CALL_ERROR':
        return Colors.red;
      case 'BVID_CONVERSION_ERROR':
        return Colors.orange;
      case 'NETWORK_ERROR':
        return Colors.blue;
      case 'GENERAL_DEBUG_ERROR':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
    _setDebuggingState(true);
    
    setState(() {
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
      
      _updateDebugInfo('1. 检查设置:\n');
      _updateDebugInfo('   - 使用原生评论区: $useNativeComments\n');

      if (!useNativeComments) {
        _showErrorDialog(
          '设置问题', 
          '原生评论区功能已关闭。\n\n请在"设置 → 通用设置 → 视频"中开启"使用原生评论区"选项。'
        );
        return;
      }

      // 2. 测试BVID转换
      _updateDebugInfo('\n2. 测试BVID转换（官方算法）:\n');
      _updateDebugInfo('   - 输入BVID: $bvid\n');
      _updateDebugInfo('   - 算法参数: XOR=177451812, ADD=8728348608\n');
      
      // 首先验证BVID格式
      bool isValidFormat = BvidAvidUtil.isBvid(bvid);
      _updateDebugInfo('   - BVID格式验证: ${isValidFormat ? "✅ 有效" : "❌ 无效"}\n');
      
      if (!isValidFormat) {
        _updateDebugInfo('   - 错误详情: BVID格式不正确，应为12位以BV开头的字符串\n');
        _logError('BVID_FORMAT_ERROR', 'Invalid BVID format', {
          'input_bvid': bvid,
          'expected_length': 12,
          'actual_length': bvid.length,
          'expected_format': 'BV + 10位字符（数字和字母）',
          'algorithm': 'official_bilibili_algorithm',
        });
        _showErrorDialog(
          'BVID格式错误', 
          'BVID格式不正确。\n\n输入: $bvid\n\n正确格式应为: BV + 10位字符\n示例: BV1xx411c7mD, BV16hHDzSEzt\n\n请检查输入的BVID是否完整且正确。\n\n注：已升级为官方算法实现。'
        );
        return;
      }

      int avid;
      try {
        avid = BvidAvidUtil.bvid2Av(bvid);
        _updateDebugInfo('   - ✅ 转换成功: av$avid\n');
        
        // 额外验证转换结果
        if (avid <= 0) {
          throw Exception('转换结果无效: AVID不能为负数或零');
        }
        if (avid > 999999999) {
          throw Exception('转换结果异常: AVID过大，可能计算错误');
        }
        
        _updateDebugInfo('   - 转换结果验证: ✅ 有效\n');
      } catch (e) {
        _updateDebugInfo('   - ❌ BVID转换失败: $e\n');
        _logError('BVID_CONVERSION_ERROR', e.toString(), {
          'input_bvid': bvid,
          'step': 'bvid_to_avid_conversion',
          'error_type': e.runtimeType.toString(),
          'algorithm': 'official_bilibili_algorithm',
          'constants': {
            'XOR': 177451812,
            'ADD': 8728348608,
            'table': 'fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF',
            'seq_array': [11, 10, 3, 8, 4, 6],
          },
        });
        _showErrorDialog(
          'BVID转换失败', 
          '无法将BVID转换为AVID。\n\n输入: $bvid\n错误: $e\n\n可能原因:\n1. BVID格式不正确\n2. BVID包含无效字符\n3. BVID已损坏或不存在\n\n算法信息:\n- 使用官方算法实现\n- XOR: 177451812, ADD: 8728348608\n- 位置数组: [11,10,3,8,4,6]\n\n请检查输入的BVID是否正确。'
        );
        return;
      }

      // 3. 测试API调用
      _updateDebugInfo('\n3. 测试API调用:\n');
      _updateDebugInfo('   - API端点: https://api.bilibili.com/x/v2/reply\n');
      _updateDebugInfo('   - 参数: type=1, oid=$avid, sort=1, ps=20, pn=1\n');

      try {
        var result = await ReplyApiV2.getComments(
          type: 1,
          oid: avid.toString(),
          sort: 1,
          ps: 20,
          pn: 1,
        );

        _updateDebugInfo('   - ✅ API调用成功\n');
        _updateDebugInfo('   - 总评论数: ${result.page.acount}\n');
        _updateDebugInfo('   - 当前页评论数: ${result.replies.length}\n');
        _updateDebugInfo('   - 热评数: ${result.hots.length}\n');

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
        _updateDebugInfo('   - ❌ API调用失败: $e\n');

        _logError('API_CALL_ERROR', e.toString(), {
          'bvid': bvid,
          'avid': avid,
          'api_endpoint': 'https://api.bilibili.com/x/v2/reply',
          'parameters': {
            'type': 1,
            'oid': avid.toString(),
            'sort': 1,
            'ps': 20,
            'pn': 1,
          },
          'timestamp': DateTime.now().toIso8601String(),
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
      _updateDebugInfo('\n❌ 调试过程中发生未知错误: $e\n');
      
      _logError('GENERAL_DEBUG_ERROR', e.toString(), {
        'context': 'main_debug_process',
        'bvid': _bvidController.text.trim(),
      });
      
      _showErrorDialog(
        '调试失败', 
        '调试过程中发生未知错误。\n\n错误信息: $e\n\n请重试或联系开发者。'
      );
    } finally {
      _setDebuggingState(false);
      _updateDebugInfo('\n调试完成。\n');
    }
  }

  /// 添加测试日志（用于演示导出功能）
  void _addTestLog() {
    String testBvid = _bvidController.text.trim();
    if (testBvid.isEmpty) {
      testBvid = 'BV16hHDzSEzt'; // 使用真实的新格式BVID
    }
    
    // 测试新的BVID验证逻辑
    bool isValid = BvidAvidUtil.isBvid(testBvid);
    
    if (isValid) {
      // BVID格式正确，尝试转换
      try {
        int avid = BvidAvidUtil.bvid2Av(testBvid);
        _logError('TEST_SUCCESS', '测试转换成功', {
          'test_bvid': testBvid,
          'converted_avid': avid,
          'test_type': 'format_validation_success',
          'timestamp': DateTime.now().toIso8601String(),
          'validation_result': 'passed',
        });
        
        Get.snackbar(
          '✅ 测试成功',
          '$testBvid 格式验证通过，转换为 av$avid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        _logError('TEST_CONVERSION_ERROR', '转换失败但格式正确', {
          'test_bvid': testBvid,
          'error': e.toString(),
          'validation_result': 'format_ok_but_conversion_failed',
        });
      }
    } else {
      // BVID格式不正确
      _logError('TEST_FORMAT_ERROR', '测试BVID格式验证失败', {
        'test_bvid': testBvid,
        'test_type': 'format_validation_test',
        'timestamp': DateTime.now().toIso8601String(),
        'validation_result': 'failed',
        'length': testBvid.length,
        'starts_with_bv': testBvid.toUpperCase().startsWith('BV'),
      });
      
      Get.snackbar(
        '❌ 格式错误',
        '$testBvid 格式验证失败',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    
    setState(() {}); // 刷新UI显示新日志
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
              focusNode: _bvidFocusNode,
              decoration: InputDecoration(
                hintText: '输入BVID，如: BV1xx411c7mD, BV16hHDzSEzt',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixIcon: Icon(Icons.video_library),
              ),
              onTap: () {
                // 确保点击时焦点不会丢失
                if (!_bvidFocusNode.hasFocus) {
                  _bvidFocusNode.requestFocus();
                }
              },
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
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showDetailedErrorLogs(),
                  icon: Icon(Icons.list_alt),
                  label: Text('错误日志'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _errorLogs.isEmpty ? Colors.grey : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _errorLogs.isEmpty ? null : () => _exportLogsDialog(),
                  icon: Icon(Icons.file_download),
                  label: Text('导出日志'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _errorLogs.isEmpty ? Colors.grey : Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _addTestLog(),
                  icon: Icon(Icons.add),
                  label: Text('测试日志'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            Text(
              '调试日志: (共${_errorLogs.length}条错误)',
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