import 'package:bili_you/pages/dynamic/view.dart';
import 'package:bili_you/pages/home/index.dart';
import 'package:bili_you/pages/mine/view.dart';
import 'package:bili_you/pages/search_test/view.dart'; // 导入新搜索页面
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  late List<Widget> pages;

  @override
  void onInit() {
    pages = [
      const HomePage(),
      const DynamicPage(), // 恢复动态页面
      const SearchTestPage(), // 使用新搜索页面替换原来的搜索页面
      const MinePage(),
    ];
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void dispose() {
    onClose();
  }
}