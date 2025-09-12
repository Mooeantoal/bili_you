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
import 'dart:ui'; // 导入用于高斯模糊的库

import '../dynamic/controller.dart';
import 'index.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainController controller;
  @override
  void initState() {
    //清理上一次启动留下的图片缓存
    CacheUtils.deleteAllCacheImage();
    BiliUrlScheme.init(context);
    //自动检查更新
    if (SettingsUtil.getValue(SettingsStorageKeys.autoCheckUpdate,
        defaultValue: true)) {
      SettingsUtil.checkUpdate(context, showSnackBar: false);
    }
    controller = Get.put(MainController());
    super.initState();
  }

  void onDestinationSelected(int value) {
    // 点击当前 NavigationBar
    if (value == controller.selectedIndex.value) {
      var currentPage = controller.pages[value];
      // 首页
      if (currentPage is HomePage) {
        var homeController = Get.find<HomeController>();
        var controllerName = homeController
            .tabsList[homeController.tabController!.index]['controller'];
        late dynamic controller;
        if (controllerName == 'RecommendController') {
          controller = Get.find<RecommendController>();
        } else if (controllerName == "PopularVideoController") {
          controller = Get.find<PopularVideoController>();
        } else if (controllerName == "LiveTabPageController") {
          controller = Get.find<LiveTabPageController>();
        }
        if (controller.scrollController.offset == 0) {
          controller.refreshController.callRefresh();
        } else {
          controller.animateToTop();
        }
      }
      // 动态
      if (currentPage is DynamicPage) {
        var controller = Get.find<DynamicController>();
        if (controller.scrollController.offset == 0) {
          controller.refreshController.callRefresh();
        } else {
          Get.find<DynamicController>().animateToTop();
        }
      }
    }
    controller.selectedIndex.value = value;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 主视图
  Widget _buildView() {
    return Obx(() => Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          primary: true,
          body: Row(
            children: [
              if (MediaQuery.of(context).size.width >= 640)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // iOS 16液态玻璃效果
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.7), // 适度提高透明度
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: NavigationRail(
                        backgroundColor: Colors.transparent, // 透明背景
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
                        ],
                        selectedIndex: controller.selectedIndex.value,
                        onDestinationSelected: (value) =>
                            onDestinationSelected(value),
                      ),
                    ),
                  ),
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
          bottomNavigationBar: MediaQuery.of(context).size.width < 640
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // iOS 16液态玻璃效果
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.7), // 适度提高透明度
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.15), // 更轻微的边框
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        currentIndex: controller.selectedIndex.value,
                        onTap: (value) => onDestinationSelected(value),
                        // iOS 16液态玻璃风格的特性设置
                        elevation: 0, // 移除默认阴影，使用模糊效果
                        backgroundColor: Colors.transparent, // 透明背景
                        selectedItemColor: Theme.of(context).colorScheme.primary,
                        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8), // 轻微降低对比度
                        showSelectedLabels: true,
                        showUnselectedLabels: true,
                        selectedFontSize: 12.0,
                        unselectedFontSize: 10.0,
                        iconSize: 24.0,
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
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _buildView();
  }
}
