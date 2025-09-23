import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/home/controller.dart';
import 'package:bili_you/pages/ui_test_page.dart'; // 假设UiTestPage所在路径
import 'package:bili_you/pages/search_input_page.dart'; // 假设SearchInputPage所在路径

// 主视图
Widget _buildView(context) {
  final HomeController controller = Get.find<HomeController>(); // 获取控制器
  
  // 定义tabsList，根据实际情况调整
  final List<Map<String, String>> tabsList = [
    {'text': '直播'},
    {'text': '推荐'},
    {'text': '热门'},
  ];
  
  // 假设这些页面已定义并导入
  final Widget liveTabPage = LiveTabPage();
  final Widget recommendPage = RecommendPage();
  final Widget popularVideoPage = PopularVideoPage();

  return Scaffold(
    appBar: AppBar(
      toolbarHeight: 48,
      title: FrostedGlassCard(
        borderRadius: 28.0,
        blurSigma: 5.0,
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        child: MaterialButton(
          onLongPress: () {
            Navigator.of(context).push(GetPageRoute(page: () => const UiTestPage()));
          },
          onPressed: () {
            Navigator.of(context).push(GetPageRoute(
              page: () => SearchInputPage(
                key: ValueKey('SearchInputPage:${controller.defaultSearchWord.value}'),
                defaultHintSearchWord: controller.defaultSearchWord.value,
              )
            ));
            controller.refreshDefaultSearchWord();
          },
          color: Colors.transparent,
          height: 33.33,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          disabledElevation: 0,
          highlightElevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  controller.refreshDefaultSearchWord();
                },
                child: Icon(
                  Icons.search,
                  size: 18,
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
                ))
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        isScrollable: true,
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
            default:
          }
        },
      ),
    ),
    body: TabBarView(
      controller: controller.tabController,
      children: tabsList.map((e) {
        switch (e['text']) {
          case '直播':
            return liveTabPage;
          case '推荐':
            return recommendPage;
          case '热门':
            return popularVideoPage;
          default:
            return const Center(child: Text("该功能暂无"));
        }
      }).toList(),
    ),
  );
}