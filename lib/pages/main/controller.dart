import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/index.dart'; // 导入home/index.dart而非view.dart
import '../dynamic/view.dart';
import '../mine/view.dart';
import '../test/bili_integrated_test_page.dart'; // 使用整合的B站播放器测试页面

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;

  List<Widget> pages = [
    const HomePage(), // 确保HomePage在home/index.dart中导出
    const DynamicPage(),
    const MinePage(),
    const BiliIntegratedTestPage(), // 使用整合的B站播放器测试页面
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