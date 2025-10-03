import 'package:bili_you/common/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'index.dart';

class SearchInputPage extends StatefulWidget {
  const SearchInputPage(
      {Key? key,
      required this.defaultHintSearchWord,
      this.defaultInputSearchWord})
      : super(key: key);
  final String defaultHintSearchWord;
  final String? defaultInputSearchWord;

  @override
  State<SearchInputPage> createState() => _SearchInputPageState();
}

class _SearchInputPageState extends State<SearchInputPage> {
  late SearchInputPageController controller;
  @override
  void initState() {
    controller = Get.put(SearchInputPageController());
    super.initState();
  }

  @override
  void dispose() {
    // controller.onClose();
    // controller.onDelete();
    controller.dispose();
    super.dispose();
  }

  Widget _defaultHintView() {
    List<Widget> list = [];
    bool showHotSearch = SettingsUtil.getValue(
        SettingsStorageKeys.showHotSearch,
        defaultValue: true);
    bool showSearchHistory = SettingsUtil.getValue(
        SettingsStorageKeys.showSearchHistory,
        defaultValue: true);
    if (showHotSearch) {
      list.addAll([
        _buildHotSearchSection(),
      ]);
    }
    if (showSearchHistory) {
      list.addAll([
        _buildHistorySection(),
      ]);
    }
    return ListView(children: list);
  }

  // 构建热搜部分，模仿PiliPlus布局
  Widget _buildHotSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 25, 4, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '大家都在搜',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: TextButton.icon(
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    onPressed: () {
                      // 刷新热搜数据
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.refresh_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      '刷新',
                      style: TextStyle(
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: controller.requestHotWordButtons(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildHotKeywordList(snapshot.data!);
                } else {
                  // 修复：当没有数据时显示提示信息
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("暂无热搜数据"),
                  );
                }
              } else {
                // 修复：加载时显示进度指示器
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 构建热搜关键词列表，模仿PiliPlus的HotKeyword组件
  Widget _buildHotKeywordList(List<Widget> hotWordButtons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / 2 - 4;
        return Wrap(
          runSpacing: 0.4,
          spacing: 5.0,
          children: hotWordButtons.map((widget) {
            // 重新包装热搜按钮以匹配PiliPlus的样式
            return SizedBox(
              width: width,
              child: widget,
            );
          }).toList(),
        );
      },
    );
  }

  // 构建历史搜索部分
  Widget _buildHistorySection() {
    return Obx(() {
      if (controller.historySearchedWords.value.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 6, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: Row(
                children: [
                  const Text(
                    '搜索历史',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 34,
                    child: TextButton.icon(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      ),
                      onPressed: controller.clearAllSearchedWords,
                      icon: const Icon(
                        Icons.clear_all_outlined,
                        size: 18,
                      ),
                      label: const Text('清空'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.historySearchedWords.value,
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _searchHintView() {
    return Obx(() => ListView(
          children: controller.searchSuggestionItems,
        ));
  }

  Widget _viewSelecter() {
    return Obx(
      () {
        if (controller.showSearchSuggest.value) {
          return _searchHintView();
        } else {
          return _defaultHintView();
        }
      },
    );
  }

  _init() {
    controller.defaultSearchWord = widget.defaultHintSearchWord;
    if (widget.defaultInputSearchWord != null) {
      controller.textEditingController.text = widget.defaultInputSearchWord!;
    }
  }

  // 主视图
  Widget _buildView() {
    _init();
    return Container(
      child: _viewSelecter(),
    );
  }

  AppBar _appBar(context) {
    return AppBar(
        shape: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        // titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: controller.textFeildFocusNode,
                      controller: controller.textEditingController,
                      onChanged: controller.onSearchWordChanged,
                      autofocus: true,
                      onEditingComplete: () {
                        controller
                            .search(controller.textEditingController.text);
                      },
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          //删除键
                          suffixIcon: Obx(() => Offstage(
                                offstage: controller.showEditDelete.isFalse,
                                child: IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    controller.textEditingController.clear();
                                    controller.showEditDelete.value = false;
                                    controller.showSearchSuggest.value = false;
                                  },
                                ),
                              )),
                          border: InputBorder.none,
                          hintText: widget.defaultHintSearchWord),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 50, // 从 70 减少到 50，给 TextField 更多空间
              child: IconButton(
                onPressed: () {
                  controller.search(controller.textEditingController.text);
                },
                icon: const Icon(Icons.search_rounded),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchInputPageController>(
      init: SearchInputPageController(),
      id: "search",
      builder: (_) {
        return Scaffold(
          appBar: _appBar(context),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}