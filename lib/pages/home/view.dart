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

  @override
  void initState() {
    controller = Get.put(HomeController());
    // 初始化 PageController，默认选中"推荐"标签页
    _pageController = PageController(initialPage: 1);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                // 当页面切换时，更新选中的标签
                controller.selectedIndex.value = index;
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 搜索栏
          Expanded(
            child: SearchBar(
              leading: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.search),
              ),
              hintText: controller.defaultSearchWord.value,
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
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceVariant,
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
    return Expanded(
      child: Obx(() {
        bool isSelected = controller.selectedIndex.value == index;
        return GestureDetector(
          onTap: () {
            controller.selectedIndex.value = index;
            // 通过 PageController 跳转到对应页面
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
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
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}