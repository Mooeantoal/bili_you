import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/widget/bili_url_scheme.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:bili_you/pages/dynamic/view.dart';
import 'package:bili_you/pages/home/index.dart';
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/popular_video/controller.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:bili_you/pages/mine/view.dart';
import 'package:flutter/material.dart';
// 添加 Fluent UI 和 Cupertino 导入
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:get/get.dart';

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
    // 检查当前使用的 UI 框架
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    final bool useFluent = SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);
    
    // 获取系统底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    if (useCupertino) {
      // 使用 Cupertino 风格的页面
      // 优化：使用适合移动端的 Cupertino 结构
      return cupertino.CupertinoPageScaffold(
        navigationBar: const cupertino.CupertinoNavigationBar(
          middle: Text("BiliYou"),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: controller.pages,
                ),
              ),
            ),
            // 移动端底部导航栏，避免与系统导航条冲突
            if (MediaQuery.of(context).size.width < 640)
              Container(
                // 抬高导航栏，避免与系统导航条冲突
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: cupertino.CupertinoTabBar(
                  currentIndex: controller.selectedIndex.value,
                  onTap: onDestinationSelected,
                  items: const [
                    cupertino.BottomNavigationBarItem(
                      icon: cupertino.Icon(cupertino.CupertinoIcons.house),
                      label: "首页",
                    ),
                    cupertino.BottomNavigationBarItem(
                      icon: cupertino.Icon(cupertino.CupertinoIcons.star),
                      label: "动态",
                    ),
                    cupertino.BottomNavigationBarItem(
                      icon: cupertino.Icon(cupertino.CupertinoIcons.person),
                      label: "我的",
                    ),
                    cupertino.BottomNavigationBarItem(
                      icon: cupertino.Icon(cupertino.CupertinoIcons.lab_flask),
                      label: "热搜测试",
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的页面
      // 修复：使用适合移动端的导航结构，避免页面嵌套冲突
      return fluent.ScaffoldPage(
        header: MediaQuery.of(context).size.width >= 640
            ? fluent.PageHeader(title: const Text("BiliYou"))
            : null,
        content: Column(
          children: [
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: controller.pages,
                ),
              ),
            ),
            // 移动端底部导航栏，避免与系统导航条冲突
            if (MediaQuery.of(context).size.width < 640)
              Container(
                // 抬高导航栏，避免与系统导航条冲突
                padding: EdgeInsets.only(bottom: bottomPadding),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.5, color: Colors.grey),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: const Icon(fluent.FluentIcons.home),
                        onPressed: () => onDestinationSelected(0),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(fluent.FluentIcons.activity_feed),
                        onPressed: () => onDestinationSelected(1),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(fluent.FluentIcons.account_browser),
                        onPressed: () => onDestinationSelected(2),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(fluent.FluentIcons.developer_tools),
                        onPressed: () => onDestinationSelected(3),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    } else {
      // 使用 Material 风格的页面
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        primary: true,
        body: Row(
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
                    icon: Icon(Icons.bug_report),
                    label: Text("测试"),
                    selectedIcon: Icon(Icons.bug_report),
                  ),
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
        bottomNavigationBar: MediaQuery.of(context).size.width < 640
            ? Container(
                // 抬高导航栏，避免与系统导航条冲突
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: FrostedGlassCard(
                  borderRadius: 0.0,
                  blurSigma: 10.0,
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(0.0),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: controller.selectedIndex.value,
                    onTap: (value) => onDestinationSelected(value),
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
                        icon: Icon(Icons.bug_report),
                        activeIcon: Icon(Icons.bug_report),
                        label: "测试",
                      ),
                    ],
                  ),
                ),
              )
            : null,
      );
    }
  }
}