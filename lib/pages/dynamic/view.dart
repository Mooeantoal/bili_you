import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/pages/dynamic/widget/dynamic_author_filter.dart';
import 'package:bili_you/pages/dynamic/widget/dynamic_item_card.dart';
import 'package:easy_refresh/easy_refresh.dart';
// 添加 Fluent UI 和 Cupertino 导入
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class DynamicPage extends StatefulWidget {
  const DynamicPage({Key? key}) : super(key: key);

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  late final DynamicController controller;
  @override
  void initState() {
    controller = Get.put(DynamicController());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 检查当前使用的 UI 框架
    final bool useCupertino = SettingsUtil.getValue(SettingsStorageKeys.useCupertinoUI, defaultValue: false);
    final bool useFluent = SettingsUtil.getValue(SettingsStorageKeys.useFluentUI, defaultValue: false);
    
    Widget content = SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      indicatorPosition: IndicatorPosition.locator,
      childBuilder: (context, physics) => CustomScrollView(
        cacheExtent: MediaQuery.of(context).size.height,
        controller: controller.scrollController,
        physics: physics,
        slivers: [
          //up主面板
          DynamicAuthorFilter(
            authors: controller.dynamicAuthorList,
            onAuthorFilterApplied: controller.applyAuthorFilter,
          ),
          const HeaderLocator.sliver(),
          //動態内容卡片
          SliverList.builder(
            itemCount: controller.dynamicItems.length,
            itemBuilder: (context, index) =>
                DynamicItemCard(dynamicItem: controller.dynamicItems[index]),
          ),
          const FooterLocator.sliver(),
        ],
      ),
      onLoad: controller.onLoad,
      onRefresh: controller.onRefresh,
    );
    
    if (useCupertino) {
      // 使用 Cupertino 风格的页面
      return cupertino.CupertinoPageScaffold(
        navigationBar: const cupertino.CupertinoNavigationBar(
          middle: Text("动态"),
        ),
        child: content,
      );
    } else if (useFluent) {
      // 使用 Fluent UI 风格的页面
      return fluent.ScaffoldPage(
        header: const fluent.PageHeader(
          title: Text("动态"),
        ),
        content: content,
      );
    } else {
      // 使用 Material 风格的页面
      return Scaffold(
        appBar: AppBar(title: const Text("动态")),
        body: content,
      );
    }
  }
}