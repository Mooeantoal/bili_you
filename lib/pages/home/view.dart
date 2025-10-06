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

  @override
  void initState() {
    controller = Get.put(HomeController());
    tabsList = controller.tabsList;
    super.initState();
  }

  @override
  void dispose() {
    // 注意：这里不再需要 dispose tabController，因为我们不再使用它
    super.dispose();
  }

  // 添加卡片按钮构建方法
  Widget _buildCardButton(String text, bool isSelected) {
    return Expanded(
      child: Card(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () {
            controller.selectedTab.value = text;
            // 根据选择的标签滚动到对应页面的顶部
            switch (text) {
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
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildView(context) {
    return Scaffold(
      appBar: AppBar(
        // 移除了搜索栏组件
        centerTitle: true,
        title: const Text("首页"), // 添加简单的标题
      ),
      body: Column(
        children: [
          // 内容区域
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                // 删除了动态页面的case
                case '直播':
                  return liveTabPage;
                case '推荐':
                  return recommendPage;
                case '热门':
                  return popularVideoPage;
                case '番剧':
                  return const Center(child: Text("该功能暂无"));
                default:
                  return const Center(child: Text("该功能暂无"));
              }
            }),
          ),
          // 标签栏移到底部
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 删除了动态标签按钮
                _buildCardButton('直播', controller.selectedTab.value == '直播'),
                _buildCardButton('推荐', controller.selectedTab.value == '推荐'),
                _buildCardButton('热门', controller.selectedTab.value == '热门'),
                _buildCardButton('番剧', controller.selectedTab.value == '番剧'),
              ],
            )),
          ),
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