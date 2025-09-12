import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/debug/native_reply_debug_page.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';

/// 调试工具类
class DebugUtils {
  /// 显示原生评论区调试对话框
  static void showNativeReplyDebugDialog({String? bvid}) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('评论区加载失败'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('原生评论区无法加载，可能的解决方案：'),
            SizedBox(height: 12),
            Text('• 使用调试工具诊断问题'),
            Text('• 切换到网页版评论区'),
            Text('• 检查网络连接'),
            Text('• 重试加载'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 切换到网页版评论区
              SettingsUtil.setValue(SettingsStorageKeys.useNativeComments, false);
              Get.snackbar(
                '已切换',
                '已切换到网页版评论区，请重新打开视频',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('切换到网页版'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 打开调试页面
              Get.to(() => NativeReplyDebugPage());
            },
            child: Text('调试诊断'),
          ),
        ],
      ),
    );
  }

  /// 快速切换评论区类型
  static void quickSwitchCommentType() {
    bool currentlyUsingNative = SettingsUtil.getValue(
      SettingsStorageKeys.useNativeComments,
      defaultValue: true,
    );
    
    String newType = currentlyUsingNative ? '网页版' : '原生';
    String currentType = currentlyUsingNative ? '原生' : '网页版';
    
    Get.dialog(
      AlertDialog(
        title: Text('切换评论区类型'),
        content: Text('当前使用：$currentType 评论区\n\n是否切换到：$newType 评论区？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              SettingsUtil.setValue(SettingsStorageKeys.useNativeComments, !currentlyUsingNative);
              Get.snackbar(
                '切换成功',
                '已切换到$newType 评论区，请重新打开视频查看效果',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: Text('确认切换'),
          ),
        ],
      ),
    );
  }

  /// 显示评论区状态信息
  static void showCommentStatusInfo() {
    bool useNativeComments = SettingsUtil.getValue(
      SettingsStorageKeys.useNativeComments,
      defaultValue: true,
    );
    
    Get.dialog(
      AlertDialog(
        title: Text('评论区状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  useNativeComments ? Icons.api : Icons.web,
                  color: useNativeComments ? Colors.blue : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  useNativeComments ? '原生评论区' : '网页版评论区',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (useNativeComments) ...[
              Text('• 使用B站原生API'),
              Text('• 加载速度快'),
              Text('• 响应流畅'),
              Text('• 如遇问题可调试诊断'),
            ] else ...[
              Text('• 使用网页版界面'),
              Text('• 兼容性好'),
              Text('• 功能完整'),
              Text('• 加载可能较慢'),
            ],
            SizedBox(height: 12),
            Text(
              '可在设置中切换评论区类型',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('关闭'),
          ),
          if (useNativeComments)
            TextButton(
              onPressed: () {
                Get.back();
                Get.to(() => NativeReplyDebugPage());
              },
              child: Text('调试工具'),
            ),
          TextButton(
            onPressed: () {
              Get.back();
              quickSwitchCommentType();
            },
            child: Text('切换类型'),
          ),
        ],
      ),
    );
  }
}