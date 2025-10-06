import 'package:bili_you/pages/dynamic/view.dart';
import 'package:bili_you/pages/home/index.dart';
import 'package:bili_you/pages/mine/view.dart';
import 'package:bili_you/pages/search_input/index.dart';
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
      const SearchInputPage(defaultHintSearchWord: "搜索"), // 保留搜索页面
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