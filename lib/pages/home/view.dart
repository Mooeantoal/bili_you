import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/home/controller.dart';
import 'package:bili_you/pages/search_input/index.dart';
// 添加页面类导入
import 'package:bili_you/pages/live_tab_page/view.dart';
import 'package:bili_you/pages/recommend/view.dart';
import 'package:bili_you/pages/popular_video/view.dart';

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

  Widget _buildView(context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: MaterialButton(
          onPressed: () {
            Navigator.of(context).push(GetPageRoute(
                page: () => SearchInputPage(
                      key: ValueKey(
                          'SearchInputPage:${controller.defaultSearchWord.value}'),
                      defaultHintSearchWord: controller.defaultSearchWord.value,
                    )));
            controller.refreshDefaultSearchWord();
          },
          color: Theme.of(context).colorScheme.surface,
          height: 50,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: controller.refreshDefaultSearchWord,
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => Text(
                  controller.defaultSearchWord.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge
                )),
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '直播', label: Text('直播')),
                ButtonSegment(value: '推荐', label: Text('推荐')),
                ButtonSegment(value: '热门', label: Text('热门')),
                ButtonSegment(value: '番剧', label: Text('番剧')),
              ],
              selected: <String>{controller.selectedTab.value},
              onSelectionChanged: (Set<String> newSelection) {
                controller.selectedTab.value = newSelection.first;
                // 根据选择的标签滚动到对应页面的顶部
                switch (newSelection.first) {
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
                }
              },
            )),
          ),
        ),
      ),
      body: Obx(() {
        switch (controller.selectedTab.value) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}