import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/pages/search_input/widgets/hot_keyword.dart';
import 'package:bili_you/pages/search_input/widgets/search_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    print('Search input page initialized');
    controller = Get.put(SearchInputPageController());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _searchSuggest() {
    return Obx(
      () {
        print('Search suggest list updated: ${controller.searchSuggestList.length} items');
        print('Search text: "${controller.textEditingController.text}"');
        return controller.searchSuggestList.isNotEmpty &&
                controller.textEditingController.text != ''
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.searchSuggestList
                    .map(
                      (item) => InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        onTap: () => controller.onClickKeyword(item.realWord),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 9,
                            bottom: 9,
                          ),
                          child: Text(item.showWord),
                        ),
                      ),
                    )
                    .toList(),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget hotSearch(ThemeData theme) {
    print('Building hot search section');
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
                Text(
                  '大家都在搜',
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: TextButton.icon(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    onPressed: controller.queryHotSearchList,
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    label: Text(
                      '刷新',
                      style: TextStyle(color: theme.colorScheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () {
              print('Hot search list updated: ${controller.hotSearchList.length} items');
              if (controller.hotSearchList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '暂无热搜数据',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return HotKeyword(
                width: MediaQuery.of(context).size.width,
                hotSearchList: controller.hotSearchList,
                onClick: controller.onClickKeyword,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _history(ThemeData theme) {
    print('Building search history section');
    return Obx(
      () {
        print('Search history updated: ${controller.historyList.length} items');
        if (controller.historyList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '暂无搜索历史',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Row(
                  children: [
                    Text(
                      '搜索历史',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                        ),
                        onPressed: controller.onClearHistory,
                        icon: Icon(
                          Icons.clear_all_outlined,
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                        label: Text(
                          '清空',
                          style: TextStyle(color: theme.colorScheme.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                direction: Axis.horizontal,
                textDirection: TextDirection.ltr,
                children: controller.historyList
                    .map(
                      (item) => SearchText(
                        text: item,
                        onTap: controller.onClickKeyword,
                        onLongPress: controller.onLongSelect,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _defaultHintView() {
    List<Widget> list = [];
    bool showHotSearch = SettingsUtil.getValue(
        SettingsStorageKeys.showHotSearch,
        defaultValue: true);
    bool showSearchHistory = SettingsUtil.getValue(
        SettingsStorageKeys.showSearchHistory,
        defaultValue: true);
    print('Show hot search: $showHotSearch, Show search history: $showSearchHistory');
    if (showHotSearch) {
      list.add(hotSearch(Theme.of(context)));
    }
    if (showSearchHistory) {
      list.add(_history(Theme.of(context)));
    }
    if (list.isEmpty) {
      list.add(const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '暂无内容',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ));
    }
    return Container(
      color: Theme.of(context).colorScheme.surface, // 确保有背景色
      child: ListView(children: list),
    );
  }

  Widget _searchHintView() {
    return Obx(() => ListView(
          children: controller.searchSuggestionItems,
        ));
  }

  Widget _viewSelecter() {
    return Obx(
      () {
        print('View selector - show search suggest: ${controller.showSearchSuggest.value}');
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
    print('Building search view');
    return Container(
      color: Theme.of(context).colorScheme.surface, // 确保有背景色
      child: _viewSelecter(),
    );
  }

  AppBar _appBar(context) {
    return AppBar(
        shape: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
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
                      onSubmitted: (value) {
                        controller.search(value);
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
              width: 70,
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
    print('Search input page build called');
    return GetBuilder<SearchInputPageController>(
      init: SearchInputPageController(),
      id: "search",
      builder: (_) {
        print('Search input page GetBuilder build called');
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