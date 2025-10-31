import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/widget/bili_url_scheme.dart';
import 'package:bili_you/pages/dynamic/view.dart';
import 'package:bili_you/pages/home/index.dart';
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/popular_video/controller.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dynamic/controller.dart';
import '../mine/index.dart';
import '../test/bili_integrated_test_page.dart';
// 移除了PipePipe相关的导入

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainController controller;
  @override
  void initState() {
    CacheUtils.deleteAllCacheImage();
    BiliUrlScheme.init(context);
    if (SettingsUtil.getValue(SettingsStorageKeys.autoCheckUpdate,
        defaultValue: true)) {
      SettingsUtil.checkUpdate(context, showSnackBar: false);
    }
    controller = Get.put(MainController());
    super.initState();
  }

  void onDestinationSelected(int value) {
    print('onDestinationSelected called with value: $value');
    if (value == controller.selectedIndex.value) {
      var currentPage = controller.pages[value];
      print('Current page type: ${currentPage.runtimeType}');
      if (currentPage is HomePage) {
        var homeController = Get.find<HomeController>();
        late dynamic pageController;
        switch (homeController.tabIndex.value) {
          case 0:
            pageController = Get.find<LiveTabPageController>();
            break;
          case 1:
            pageController = Get.find<RecommendController>();
            break;
          case 2:
            pageController = Get.find<PopularVideoController>();
            break;
          default:
            pageController = null;
        }
        if (pageController != null) {
          if (pageController.scrollController.offset == 0) {
            pageController.refreshController.callRefresh();
          } else {
            pageController.animateToTop();
          }
        }
      }
      if (currentPage is DynamicPage) {
        var dynamicController = Get.find<DynamicController>();
        if (dynamicController.scrollController.offset == 0) {
          dynamicController.refreshController.callRefresh();
        } else {
          dynamicController.animateToTop();
        }
      }
    }
    // 确保选中项正确切换
    controller.updateSelectedIndex(value);
    controller.selectedIndex.value = value;
    print('Selected index updated to: $value');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Material 风格的页面，实现Android官方的edge-to-edge沉浸式方案
    return Scaffold(
      // Android官方edge-to-edge沉浸式方案
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // 主内容区域
          Expanded(
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width >= 640)
                  NavigationRail(
                    extended: false,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text("首页"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.star_border_outlined),
                        label: Text("动态"),
                        selectedIcon: Icon(Icons.star),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        label: Text("我的"),
                        selectedIcon: Icon(Icons.person),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.comment),
                        label: Text("测试"),
                        selectedIcon: Icon(Icons.comment),
                      ),
                      // 移除了PipePipe相关的导航项
                    ],
                    selectedIndex: controller.selectedIndex.value,
                    onDestinationSelected: (value) => onDestinationSelected(value),
                  ),
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: controller.selectedIndex.value,
                      children: controller.pages,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 移动端底部导航栏，使用原生BottomNavigationBar实现edge-to-edge效果
          if (MediaQuery.of(context).size.width < 640)
            Container(
              // 去除系统导航条所在部分的半透明阴影
              color: Colors.transparent,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent, // 透明背景
                elevation: 0, // 去除阴影
                currentIndex: controller.selectedIndex.value,
                onTap: onDestinationSelected,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "首页",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.star_border_outlined),
                    activeIcon: Icon(Icons.star),
                    label: "动态",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: "我的",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.comment), // 恢复整合测试页面的标签
                    label: "测试",
                  ),
                  // 移除了PipePipe相关的导航项
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final List<Widget> pages = [
    const HomePage(), // 确保HomePage在home/index.dart中导出
    const DynamicPage(),
    const MinePage(),
    const BiliIntegratedTestPage(), // 恢复整合测试页面
    // 移除了PipePipe相关的页面
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