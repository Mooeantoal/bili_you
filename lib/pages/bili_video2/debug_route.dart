import 'package:bili_you/pages/bili_video2/debug_video_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugRoute {
  static void openDebugVideoPage() {
    Get.to(() => const DebugVideoPage());
  }
}