import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/live_tab_page/view.dart';
import 'package:bili_you/pages/popular_video/controller.dart';
import 'package:bili_you/pages/popular_video/view.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:bili_you/pages/search_input/index.dart';
import 'package:bili_you/pages/ui_test/index.dart';
import 'package:bili_you/pages/mine/view.dart'; // 导入"我的"页面
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/recommend/view.dart';
import 'index.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> widget() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  late HomeController controller;
  final RecommendPage recommendPage = const RecommendPage();
  final PopularVideoPage popularVideoPage = const PopularVideoPage();
  final LiveTabPage liveTabPage = const LiveTabPage();
  // 移除 tabsList，因为我们现在使用自定义标签栏

  @override
  void initState() {
    controller = Get.put(HomeController());
    // 移除 tabController 初始化，因为我们现在使用自定义标签栏
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 主视图
  Widget _buildView(context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: _buildAppBar(context),
        centerTitle: true,
        // 移除原来的 bottom 属性，因为我们现在使用自定义标签栏
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() => IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                liveTabPage,
                recommendPage,
                popularVideoPage,
                const Center(child: Text("分区页面")),
                const Center(child: Text("番剧页面")),
                // 可以根据需要添加更多页面
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 搜索栏
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                readOnly: true, // 设置为只读，点击时跳转到搜索页面
                onTap: () {
                  // 跳转到搜索页面
                  Navigator.of(context).push(
                    GetPageRoute(
                      page: () => SearchInputPage(
                        key: ValueKey(
                            'SearchInputPage:${controller.defaultSearchWord.value}'),
                        defaultHintSearchWord: controller.defaultSearchWord.value,
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: controller.defaultSearchWord.value,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTabItem('直播', 0),
              _buildTabItem('推荐', 1),
              _buildTabItem('热门', 2),
              _buildTabItem('分区', 3),
              _buildTabItem('番剧', 4),
              // 可以根据需要添加更多标签
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = controller.selectedIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedIndex.value = index;
          // 添加滚动到顶部的逻辑
          switch (index) {
            case 0:
              //点击"直播"回到顶
              Get.find<LiveTabPageController>().animateToTop();
              break;
            case 1:
              //点击"推荐"回到顶
              Get.find<RecommendController>().animateToTop();
              break;
            case 2:
              Get.find<PopularVideoController>().animateToTop();
              break;
            default:
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(Get.context!).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Theme.of(Get.context!).colorScheme.primary
                  : Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}