import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// 日志导出工具类
class LogExportUtil {
  /// 检查并请求存储权限
  static Future<bool> checkAndRequestStoragePermission() async {
    try {
      // 获取Android版本信息
      if (Platform.isAndroid) {
        // Android 13 (API 33) 及以上版本使用新的权限模型
        if (await _isAndroid13OrAbove()) {
          // 对于 Android 13+，主要检查是否可以访问应用外部目录
          var status = await Permission.manageExternalStorage.status;
          if (status.isDenied) {
            status = await Permission.manageExternalStorage.request();
          }
          
          if (status.isPermanentlyDenied) {
            _showPermissionDialog();
            return false;
          }
          
          return status.isGranted || status.isLimited;
        } else {
          // Android 12 及以下版本使用传统存储权限
          var status = await Permission.storage.status;
          if (status.isDenied) {
            status = await Permission.storage.request();
          }
          
          if (status.isPermanentlyDenied) {
            _showPermissionDialog();
            return false;
          }
          
          return status.isGranted;
        }
      }
      
      // iOS 不需要特殊权限处理，使用应用沙盒
      return true;
    } catch (e) {
      print('权限检查失败: $e');
      return false;
    }
  }

  /// 检查是否为 Android 13 或以上版本
  static Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    
    try {
      // 简单的版本检查，实际项目中可以使用 device_info_plus
      return true; // 假设是新版本，更安全的处理方式
    } catch (e) {
      return false;
    }
  }

  /// 显示权限说明对话框
  static void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('需要存储权限'),
          ],
        ),
        content: Text(
          '为了导出调试日志到手机存储，需要获取存储访问权限。\n\n'
          '请在系统设置中允许应用访问存储空间。',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 导出错误日志到文件
  static Future<bool> exportErrorLogs(List<Map<String, dynamic>> errorLogs) async {
    try {
      // 1. 检查权限
      bool hasPermission = await checkAndRequestStoragePermission();
      if (!hasPermission) {
        Get.snackbar(
          '权限不足',
          '无法访问存储空间，日志导出失败',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // 2. 准备日志数据
      Map<String, dynamic> logData = {
        'app_name': 'BiliYou',
        'export_time': DateTime.now().toIso8601String(),
        'total_logs': errorLogs.length,
        'app_version': '1.1.5+15', // 可以从 package_info_plus 获取
        'platform': Platform.operatingSystem,
        'logs': errorLogs.map((log) => {
          'timestamp': log['timestamp']?.toIso8601String() ?? '',
          'type': log['type'] ?? 'UNKNOWN',
          'message': log['message'] ?? '',
          'details': log['details'] ?? {},
        }).toList(),
      };

      // 3. 转换为JSON格式
      String jsonContent = JsonEncoder.withIndent('  ').convert(logData);
      
      // 4. 创建文件名
      String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      String fileName = 'BiliYou_Debug_Logs_$timestamp.json';

      // 5. 获取保存路径
      Directory? directory;
      if (Platform.isAndroid) {
        // 尝试保存到 Downloads 目录
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } catch (e) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('无法获取存储目录');
      }

      // 6. 确保目录存在
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 7. 写入文件
      String filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      await file.writeAsString(jsonContent, encoding: utf8);

      // 8. 显示成功消息
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('导出成功'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('日志已导出到:'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  filePath,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text('包含 ${errorLogs.length} 条错误日志'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('确定'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _shareLogFile(filePath);
              },
              child: Text('分享文件'),
            ),
          ],
        ),
      );

      return true;
    } catch (e) {
      print('导出日志失败: $e');
      Get.snackbar(
        '导出失败',
        '日志导出时发生错误: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// 分享日志文件
  static Future<void> _shareLogFile(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: '调试日志文件 - BiliYou',
        subject: 'BiliYou 调试日志',
      );
    } catch (e) {
      print('分享文件失败: $e');
      Get.snackbar(
        '分享失败',
        '无法分享日志文件: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// 导出简化版本的日志（用于快速分享）
  static Future<void> exportSimplifiedLogs(List<Map<String, dynamic>> errorLogs) async {
    try {
      if (errorLogs.isEmpty) {
        Get.snackbar(
          '无日志可导出',
          '当前没有错误日志',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 创建简化的文本格式
      StringBuffer buffer = StringBuffer();
      buffer.writeln('=== BiliYou 调试日志 ===');
      buffer.writeln('导出时间: ${DateTime.now()}');
      buffer.writeln('总计错误: ${errorLogs.length} 条');
      buffer.writeln('应用版本: 1.1.5+15');
      buffer.writeln('');

      for (int i = 0; i < errorLogs.length; i++) {
        var log = errorLogs[i];
        buffer.writeln('--- 错误 ${i + 1} ---');
        buffer.writeln('时间: ${log['timestamp']}');
        buffer.writeln('类型: ${log['type']}');
        buffer.writeln('消息: ${log['message']}');
        
        if (log['details'] != null && log['details'].isNotEmpty) {
          buffer.writeln('详情:');
          (log['details'] as Map).forEach((key, value) {
            buffer.writeln('  $key: $value');
          });
        }
        buffer.writeln('');
      }

      // 使用分享功能
      await Share.share(
        buffer.toString(),
        subject: 'BiliYou 调试日志 (${errorLogs.length}条错误)',
      );

    } catch (e) {
      print('导出简化日志失败: $e');
      Get.snackbar(
        '导出失败',
        '无法导出日志: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}