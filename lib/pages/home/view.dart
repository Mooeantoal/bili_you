import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/live_tab_page/view.dart';
import 'package:bili_you/pages/popular_video/controller.dart';
import 'package:bili_you/pages/popular_video/view.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:bili_you/pages/search_input/index.dart';
import 'package:bili_you/pages/mine/view.dart'; // 导入"我的"页面
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/recommend/view.dart';
import 'index.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  late HomeController controller;
  final RecommendPage recommendPage = const RecommendPage();
  final PopularVideoPage popularVideoPage = const PopularVideoPage();
  final LiveTabPage liveTabPage = const LiveTabPage();
  // 添加 PageController 来控制 PageView
  late PageController _pageController;
  // 添加 TabController 来控制标签页
  late TabController _tabController;

  @override
  void initState() {
    controller = Get.put(HomeController());
    // 初始化 PageController，默认选中"推荐"标签页
    _pageController = PageController(initialPage: 1);
    // 初始化 TabController，标签数量为5
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
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
        // 使用 TabBar 作为 bottom
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: _buildTabBar(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                // 当页面切换时，更新选中的标签
                controller.selectedIndex.value = index;
                // 同步 TabController 的位置
                _tabController.animateTo(index);
              },
              children: [
                liveTabPage,
                recommendPage,
                popularVideoPage,
                const Center(child: Text("分区页面")),
                const Center(child: Text("番剧页面")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0), // 移除水平内边距，让搜索栏完全铺满
      child: Row(
        children: [
          // 搜索栏
          Expanded(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // MD2风格的圆角
                  borderSide: BorderSide.none, // 无边框
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
          const SizedBox(height: 8),
          // 使用 Material Design 3 的 SegmentedButton 风格
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: '直播'),
                Tab(text: '推荐'),
                Tab(text: '热门'),
                Tab(text: '分区'),
                Tab(text: '番剧'),
              ],
              onTap: (index) {
                controller.selectedIndex.value = index;
                // 通过 PageController 跳转到对应页面
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                
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
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}