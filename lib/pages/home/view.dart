import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/pages/live_tab_page/controller.dart';
import 'package:bili_you/pages/live_tab_page/view.dart';
import 'package:bili_you/pages/popular_video/controller.dart';
import 'package:bili_you/pages/popular_video/view.dart';
import 'package:bili_you/pages/recommend/controller.dart';
import 'package:bili_you/pages/search_input/index.dart';
import 'package:bili_you/pages/ui_test/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/recommend/view.dart';
import 'index.dart';
import 'widgets/user_menu/view.dart';
import 'dart:ui'; // 导入用于高斯模糊的库

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
    controller.tabController = TabController(
        length: tabsList.length,
        vsync: this,
        initialIndex: controller.tabInitIndex);
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(112), // 设置appBar的高度为搜索框(56) + 标签栏(56)的总高度
        child: Container(
          // 添加顶部间距，避免遮挡状态栏
          margin: const EdgeInsets.only(top: 24), // 为状态栏留出空间
          decoration: BoxDecoration(
            // 添加更明显的阴影效果
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30)), // 增大圆角
            child: Stack(
              children: [
                // 背景使用纯色而非模糊效果
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface, // 使用纯色背景
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3), // 增强边框
                      width: 1.0,
                    ),
                  ),
                ),
                // 添加轻微的高光效果
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.01),
                        ],
                      ),
                    ),
                  ),
                ),
                // 内容容器
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 搜索框部分
                    MaterialButton(
                      onLongPress: () {
                        //长按进入测试界面
                        // Get.to(() => const UiTestPage());
                        Navigator.of(context)
                            .push(GetPageRoute(page: () => const UiTestPage()));
                      },
                      onPressed: () {
                        Navigator.of(context).push(GetPageRoute(
                            page: () => SearchInputPage(
                                  key: ValueKey(
                                      'SearchInputPage:${controller.defaultSearchWord.value}'),
                                  defaultHintSearchWord: controller.defaultSearchWord.value,
                                )));

                        //更新搜索框默认词
                        controller.refreshDefaultSearchWord();
                      },
                      height: 56,
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      disabledElevation: 0,
                      highlightElevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              //更新搜索框默认词
                              controller.refreshDefaultSearchWord();
                            },
                            child: Icon(
                              (Icons.search),
                              size: 24,
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
                          const SizedBox(
                            width: 16,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const UserMenuPage(),
                              );
                            },
                            child: ClipOval(
                              child: FutureBuilder(
                                future: controller.loadOldFace(),
                                builder: (context, snapshot) {
                                  Widget placeHolder = Container(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  );
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    //头像
                                    return Obx(() => CachedNetworkImage(
                                        cacheWidth: 100,
                                        cacheHeight: 100,
                                        cacheManager: controller.cacheManager,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.fill,
                                        imageUrl: controller.faceUrl.value,
                                        placeholder: () => placeHolder));
                                  } else {
                                    return placeHolder;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 标签栏部分
                    Container(
                      decoration: BoxDecoration(
                        // 为标签栏添加更明显的阴影效果
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(bottom: Radius.circular(16)), // 增大圆角
                        child: Container(
                          decoration: BoxDecoration(
                            // 使用更清晰的背景色
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              // 增强底部边框效果
                              bottom: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: TabBar(
                            isScrollable: true,
                            tabs: tabsList.map((e) => Tab(text: e['text'])).toList(),
                            controller: controller.tabController,
                            // 添加标签栏的一些视觉增强属性
                            indicatorColor: Theme.of(context).colorScheme.primary,
                            indicatorWeight: 3.0,
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background, // 确保内容区域有清晰的背景
        child: TabBarView(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}
