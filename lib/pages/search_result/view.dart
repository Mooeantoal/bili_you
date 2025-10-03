import 'package:bili_you/common/api/search_api.dart';
import 'package:bili_you/pages/search_input/view.dart';
import 'package:bili_you/pages/search_tab_view/controller.dart';

import 'package:bili_you/pages/search_tab_view/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({Key? key, required this.keyWord}) : super(key: key);
  final String keyWord;
  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  late SearchResultController controller;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // 确保关键词不为空
    if (widget.keyWord.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("错误", "搜索关键词不能为空");
        Get.back();
      });
    }
    
    try {
      controller = Get.put(SearchResultController(keyWord: widget.keyWord));
    } catch (e) {
      print("初始化SearchResultController时出错: $e");
    }
    super.initState();
  }

  @override
  void dispose() {
    try {
      controller.dispose();
    } catch (e) {
      print("释放SearchResultController时出错: $e");
    }
    super.dispose();
  }

  AppBar _appBar(BuildContext context, SearchResultController controller) {
    return AppBar(
        shape: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: widget.keyWord),
                readOnly: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onTap: () {
                  Get.to(() => SearchInputPage(
                        defaultHintSearchWord: widget.keyWord,
                        defaultInputSearchWord: widget.keyWord,
                      ));
                },
              ),
            ),
            SizedBox(
              width: 70,
              child: IconButton(
                onPressed: () {
                  // controller.refreshController.callRefresh();
                },
                icon: const Icon(Icons.search_rounded),
              ),
            )
          ],
        ),
        bottom: TabBar(
            controller: controller.tabController,
            onTap: (value) {
              try {
                if (controller.currentSelectedTabIndex == value) {
                  //移动到顶部
                  Get.find<SearchTabViewController>(
                          tag: controller.getTabTagNameByIndex(value))
                      .animateToTop();
                }
                controller.currentSelectedTabIndex = value;
                controller.tabController.animateTo(value);
              } catch (e) {
                print("Tab切换时出错: $e");
              }
            },
            tabs: [
              for (var i in SearchType.values)
                Tab(
                  text: i.name,
                ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // 检查控制器是否已初始化
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("搜索结果")),
        body: const Center(
          child: Text("页面初始化失败"),
        ),
      );
    }
    
    // 检查关键词是否为空
    if (widget.keyWord.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("搜索结果")),
        body: const Center(
          child: Text("搜索关键词不能为空"),
        ),
      );
    }
    
    return Scaffold(
      appBar: _appBar(context, controller),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          for (var i in SearchType.values)
            SearchTabViewPage(
              keyWord: widget.keyWord,
              searchType: i,
              tagName: controller.getTabTagNameByIndex(i.index),
            ),
        ],
      ),
    );
  }
}