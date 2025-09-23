import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/home/controller.dart';
import 'package:bili_you/pages/search_input/view.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:bili_you/pages/live_tab_page/view.dart';
import 'package:bili_you/pages/recommend/view.dart';
import 'package:bili_you/pages/popular_video/view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => _buildView(context);

  Widget _buildView(context) {
    final HomeController controller = Get.find<HomeController>();
    
    final Widget liveTabPage = const LiveTabPage();
    final Widget recommendPage = const RecommendPage();
    final Widget popularVideoPage = const PopularVideoPage();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: FrostedGlassCard(
          borderRadius: 28.0,
          blurSigma: 5.0,
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          child: MaterialButton(
            onLongPress: () {
              // 移除UiTestPage相关代码
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: controller.refreshDefaultSearchWord,
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
          tabs: controller.tabsList.map((e) => Tab(text: e['text'])).toList(),
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
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: controller.tabsList.map((e) {
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
}