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
import 'package:bili_you/pages/mine/view.dart'; // 添加导入
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
        // 更新逻辑以适应新的自定义标签栏
        // 根据当前选中的标签页执行相应的刷新操作
        late dynamic controller;
        switch (homeController.selectedIndex.value) {
          case 0: // 直播
            controller = Get.find<LiveTabPageController>();
            break;
          case 1: // 推荐
            controller = Get.find<RecommendController>();
            break;
          case 2: // 热门
            controller = Get.find<PopularVideoController>();
            break;
          default:
            controller = null;
        }
        
        if (controller != null) {
          if (controller.scrollController.offset == 0) {
            controller.refreshController.callRefresh();
          } else {
            controller.animateToTop();
          }
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
      // 我的
      if (currentPage is MinePage) {
        // 可以在这里添加刷新逻辑
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
                    onDestinationSelected: (value) =>
                        onDestinationSelected(value)),
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
                  blurSigma: 5.0, // 降低模糊度
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9), // 提高透明度
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(0.0),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _buildView();
  }
}