import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/utils/device_ui_adapter.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/common/widget/bili_url_scheme.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:bili_you/pages/dynamic/view.dart';
import 'package:bili_you/pages/home/index.dart';
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/popular_video/controller.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:flutter/material.dart';
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
    
    // 检查是否需要应用默认的0.75倍UI大小设置
    _applyDefaultUISizeIfNecessary();
    
    controller = Get.put(MainController());
    super.initState();
  }

  /// 检查并应用默认的0.75倍UI大小设置
  void _applyDefaultUISizeIfNecessary() {
    // 检查是否是第一次启动应用
    bool isFirstLaunch = SettingsUtil.getValue('isFirstLaunch', defaultValue: true);
    if (isFirstLaunch) {
      // 应用0.75倍默认UI大小设置
      SettingsUtil.applyDefaultUISize();
      // 标记已启动过应用
      SettingsUtil.setValue('isFirstLaunch', false);
    }
  }

  void onDestinationSelected(int value) {
    if (value == controller.selectedIndex.value) {
      var currentPage = controller.pages[value];
      if (currentPage is HomePage) {
        // 确保返回首页时不自动弹出键盘
        FocusManager.instance.primaryFocus?.unfocus();
        
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
    // 在切换页面时取消焦点，避免键盘意外弹出
    FocusManager.instance.primaryFocus?.unfocus();
    controller.selectedIndex.value = value;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
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
                  icon: Icon(Icons.search_outlined),
                  label: Text("搜索"),
                  selectedIcon: Icon(Icons.search),
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
          ? Container(
              // 使用设备适配器获取底部安全区域填充
              padding: DeviceUIAdapter.getBottomSafeAreaPadding(context),
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
                      icon: Icon(Icons.search_outlined),
                      activeIcon: Icon(Icons.search),
                      label: "搜索",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: "我的",
                    ),
                  ],
                ),
              ),
            )
          : null,
    ));
  }
}