import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:bili_you/pages/search/search_input/view.dart';
import 'package:bili_you/pages/ui_test/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  // 为保证代码可复现，将tabsList等变量移入view中
  // 在实际项目中，这些变量可能在Controller或单独的文件中管理
  static const List<Map<String, String>> tabsList = [
    {'text': '直播'},
    {'text': '推荐'},
    {'text': '热门'},
    {'text': '番剧'}
  ];
  // 假设这些页面Widget已在别处定义或导入
  static final Widget liveTabPage = const Center(child: Text("直播页面"));
  static final Widget recommendPage = const Center(child: Text("推荐页面"));
  static final Widget popularVideoPage = const Center(child: Text("热门页面"));

  @override
  Widget build(BuildContext context) {
    // 将原有的 _buildView 方法内容直接整合到 build 方法中
    // 或作为私有方法调用以保持结构清晰
    return _buildView(context);
  }

  // 主视图
  Widget _buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: FrostedGlassCard(
          borderRadius: 28.0,
          blurSigma: 5.0, // 降低模糊度
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.9), // 提高透明度
          child: MaterialButton(
            onLongPress: () {
              //长按进入测试界面
              Navigator.of(context)
                  .push(GetPageRoute(page: () => const UiTestPage()));
            },
            onPressed: () {
              Navigator.of(context).push(GetPageRoute(
                  page: () => SearchInputPage(
                        key: ValueKey(
                            'SearchInputPage:${controller.defaultSearchWord.value}'),
                        defaultHintSearchWord:
                            controller.defaultSearchWord.value,
                      )));

              //更新搜索框默认词
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
                    //更新搜索框默认词
                    controller.refreshDefaultSearchWord();
                  },
                  child: Icon(
                    (Icons.search),
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: Obx(() => Text(
                        //搜索框默认词
                        controller.defaultSearchWord.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge))),
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
}
