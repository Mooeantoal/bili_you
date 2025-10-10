import 'package:bili_you/pages/bili_video2/video_test_page.dart';
import 'package:bili_you/pages/bili_video2/advanced_video_debug_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoTestRoute {
  static void openVideoTestPage() {
    Get.to(() => const VideoTestPage());
  }
  
  static void openAdvancedVideoDebugPage() {
    Get.to(() => const AdvancedVideoDebugPage());
  }
}