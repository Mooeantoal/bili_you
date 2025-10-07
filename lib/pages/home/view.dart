import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/home/controller.dart';
// 移除了搜索页面的导入
// 添加页面类导入
import 'package:bili_you/pages/live_tab_page/view.dart';
import 'package:bili_you/pages/recommend/view.dart';
import 'package:bili_you/pages/popular_video/view.dart';
// 移除了动态页面的导入

// 移除UiTestPage导入
// 添加控制器导入
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:bili_you/pages/popular_video/controller.dart';

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
  // 移除了动态页面实例
  List<Map<String, dynamic>> tabsList = [];
  
  // 添加 PageController 用于页面滑动
  late PageController _pageController;
  
  // 定义标签列表
  final List<String> _tabs = ['直播', '推荐', '热门', '番剧'];

  @override
  void initState() {
    controller = Get.put(HomeController());
    tabsList = controller.tabsList;
    
    // 初始化 PageController
    _pageController = PageController(
      initialPage: _getIndexFromTab(controller.selectedTab.value),
    );
    
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // 根据标签名称获取索引
  int _getIndexFromTab(String tab) {
    return _tabs.indexOf(tab);
  }
  
  // 根据索引获取标签名称
  String _getTabFromIndex(int index) {
    return _tabs[index];
  }
  
  // 页面切换时更新选中的标签
  void _onPageChanged(int index) {
    controller.selectedTab.value = _getTabFromIndex(index);
    // 根据选择的标签滚动到对应页面的顶部
    switch (_getTabFromIndex(index)) {
      case '直播':
        Get.find<LiveTabPageController>().animateToTop();
        break;
      case '推荐':
        Get.find<RecommendController>().animateToTop();
        break;
      case '热门':
        Get.find<PopularVideoController>().animateToTop();
        break;
      default:
        // 番剧等页面暂时没有滚动控制器
        break;
    }
  }

  Widget _buildView(context) {
    return Scaffold(
      appBar: AppBar(
        // 移除了搜索栏组件
        centerTitle: false, // 改为false，使标题左对齐
        title: const Text("首页"), // 简单的标题，左对齐
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => SegmentedButton<String>(
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment(
                  value: '直播', 
                  label: Text(
                    '直播',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ),
                ButtonSegment(
                  value: '推荐', 
                  label: Text(
                    '推荐',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ),
                ButtonSegment(
                  value: '热门', 
                  label: Text(
                    '热门',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ),
                ButtonSegment(
                  value: '番剧', 
                  label: Text(
                    '番剧',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ),
              ],
              selected: {controller.selectedTab.value},
              onSelectionChanged: (Set<String> newSelection) {
                controller.selectedTab.value = newSelection.first;
                // 通过 PageController 跳转到对应页面
                _pageController.animateToPage(
                  _getIndexFromTab(newSelection.first),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          liveTabPage,
          recommendPage,
          popularVideoPage,
          const Center(child: Text("该功能暂无")), // 番剧页面
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