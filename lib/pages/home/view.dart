import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/home/controller.dart';
import 'package:bili_you/pages/ui_test/ui_test_page.dart';
import 'package:bili_you/pages/search/search_input_page.dart';

// 确保FrostedGlassCard已定义或导入
// import 'package:bili_you/widgets/frosted_glass_card.dart';

Widget _buildView(BuildContext context) {
  final HomeController controller = Get.find<HomeController>();
  
  // 定义tabsList数据
  final List<Map<String, dynamic>> tabsList = [
    {'text': '直播', 'index': 0},
    {'text': '推荐', 'index': 1},
    {'text': '热门', 'index': 2},
  ];

  // 假设这些页面已定义并导入
  Widget liveTabPage = const Center(child: Text("直播页面"));
  Widget recommendPage = const Center(child: Text("推荐页面"));
  Widget popularVideoPage = const Center(child: Text("热门视频页面"));

  return Scaffold(
    appBar: AppBar(
      title: FrostedGlassCard( // 如果没有此组件，可替换为Container
        child: Row(
          children: [
            Expanded(
              child: Obx(() => Text(
                controller.defaultSearchWord.value,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              )),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                controller.refreshDefaultSearchWord();
                Navigator.of(context).push(GetPageRoute(
                  page: () => SearchInputPage(
                    key: ValueKey('SearchInputPage:${controller.defaultSearchWord.value}'),
                    defaultHintSearchWord: controller.defaultSearchWord.value,
                  ),
                ));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context)
                  .push(GetPageRoute(page: () => const UiTestPage()));
              },
              child: const Icon(Icons.settings),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
    ),
    body: TabBarView(
      controller: controller.tabController,
      children: tabsList.map((e) {
        switch (e['index']) {
          case 0:
            return liveTabPage;
          case 1:
            return recommendPage;
          case 2:
            return popularVideoPage;
          default:
            return const Center(child: Text("该功能暂无"));
        }
      }).toList(),
    ),
    bottomNavigationBar: TabBar(
      tabs: tabsList.map((e) => Tab(text: e['text'])).toList(),
      controller: controller.tabController,
      onTap: (index) {
        if (controller.tabController!.indexIsChanging) return;
        switch (index) {
          case 0:
            Get.find<LiveTabPageController>().animateToTop();
            break;
          case 1:
            Get.find<RecommendController>().animateToTop();
            break;
          case 2:
            Get.find<PopularVideoController>().animateToTop();
            break;
        }
      },
    ),
  );
}