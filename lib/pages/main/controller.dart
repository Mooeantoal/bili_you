import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/index.dart'; // 导入home/index.dart而非view.dart
import '../dynamic/view.dart';
import '../mine/index.dart'; // 使用index.dart导入mine页面
import '../test/bili_integrated_test_page.dart'; // 使用恢复的整合B站测试页面
import '../test/pipepipe_full_test_page.dart'; // 导入新的PipePipe完整测试页面
import '../test/pipepipe_video_detail_page.dart'; // 导入新的PipePipe视频详情页面

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;

  List<Widget> pages = [
    const HomePage(), // 确保HomePage在home/index.dart中导出
    const DynamicPage(),
    const MinePage(),
    const BiliIntegratedTestPage(), // 使用恢复的整合B站测试页面
    const PipePipeFullTestPage(), // 使用新的PipePipe完整测试页面
    const PipePipeVideoDetailPage(), // 添加新的PipePipe视频详情页面
  ];

  _initData() {
    // 初始化数据
  }

  void onTap() {}

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // 添加方法确保页面切换时更新选中索引
  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }
}