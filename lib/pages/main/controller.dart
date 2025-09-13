import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/view.dart';
import '../dynamic/view.dart';
import '../mine/view.dart'; // 添加导入

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;

  List<Widget> pages = [
    const HomePage(),
    const DynamicPage(),
    const MinePage(), // 添加"我的"页面
  ];

  _initData() {
    // update(["main"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}