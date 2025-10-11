import 'package:bili_you/pages/bili_video2/video_test_page.dart';
import 'package:bili_you/pages/bili_video2/advanced_video_debug_page.dart';
import 'package:bili_you/pages/bili_video2/detailed_api_debug_page.dart';
import 'package:bili_you/pages/bili_video2/dash_stream_debug_page.dart';
// 导入改进的调试页面
import 'package:bili_you/pages/bili_video2/improved_debug_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoTestRoute {
  static void openVideoTestPage() {
    Get.to(() => const VideoTestPage());
  }
  
  static void openAdvancedVideoDebugPage() {
    Get.to(() => const AdvancedVideoDebugPage());
  }
  
  static void openDetailedApiDebugPage() {
    Get.to(() => const DetailedApiDebugPage());
  }
  
  static void openDashStreamDebugPage() {
    Get.to(() => const DashStreamDebugPage());
  }
  
  // 添加改进调试页面的路由方法
  static void openImprovedDebugPage() {
    Get.to(() => const ImprovedDebugPage());
  }
}