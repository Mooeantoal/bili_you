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
    if (value == controller.selectedIndex.value) {
      var currentPage = controller.pages[value];
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
    
    if (useCupertino) {
      // 使用 Cupertino 风格的页面
      return cupertino.CupertinoPageScaffold(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 640)
              cupertino.CupertinoSlidingSegmentedControl<int>(
                children: const {
                  0: Text("首页"),
                  1: Text("动态"),
                  2: Text("我的"),
                },
                groupValue: controller.selectedIndex.value,
                onValueChanged: (value) => onDestinationSelected(value!),
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
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的页面
      return fluent.NavigationView(
        pane: fluent.Pane(
          displayMode: fluent.PaneDisplayMode.auto,
          items: [
            fluent.PaneItem(
              icon: const Icon(Icons.home_outlined),
              title: const Text("首页"),
              body: controller.pages[0],
            ),
            fluent.PaneItem(
              icon: const Icon(Icons.star_border_outlined),
              title: const Text("动态"),
              body: controller.pages[1],
            ),
            fluent.PaneItem(
              icon: const Icon(Icons.person_outline),
              title: const Text("我的"),
              body: controller.pages[2],
            ),
          ],
          selected: controller.selectedIndex.value,
          onChanged: (value) => onDestinationSelected(value),
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
            ? FrostedGlassCard(
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
                  ],
                ),
              )
            : null,
      );
    }
  }
}