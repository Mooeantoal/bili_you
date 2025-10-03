import 'dart:async';
import 'dart:developer';

import 'package:bili_you/common/api/search_api.dart';
import 'package:bili_you/common/models/local/search/hot_word_item.dart';
import 'package:bili_you/common/models/local/search/search_suggest_item.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/search_result/index.dart';
import 'package:bili_you/pages/search_result/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stream_transform/stream_transform.dart';

class SearchInputPageController extends GetxController {
  SearchInputPageController();
  
  // 搜索建议相关
  RxBool showSearchSuggest = false.obs;
  RxList<Widget> searchSuggestionItems = <Widget>[].obs;
  
  // 文本输入控制
  TextEditingController textEditingController = TextEditingController();
  final FocusNode textFeildFocusNode = FocusNode();
  late String defaultSearchWord;
  RxBool showEditDelete = false.obs;

  // 历史记录
  Rx<List<Widget>> historySearchedWords = Rx<List<Widget>>([]);
  
  // 防抖动搜索建议
  StreamController<String>? _searchSuggestionController;
  StreamSubscription<String>? _searchSuggestionSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // 初始化防抖动搜索建议流
    _searchSuggestionController = StreamController<String>();
    _searchSuggestionSubscription = _searchSuggestionController!.stream
        .debounce(const Duration(milliseconds: 300))
        .listen(_requestSearchSuggestionsDebounced);
        
    _initData();
  }

  // 初始化数据
  _initData() async {
    _refreshHistoryWord();
    textFeildFocusNode.addListener(() {
      if (textFeildFocusNode.hasFocus &&
          textEditingController.text.isNotEmpty) {
        showEditDelete.value = true;
      }
    });
  }

  // 防抖动搜索建议请求
  void _requestSearchSuggestionsDebounced(String keyWord) {
    if (keyWord.trim().isNotEmpty) {
      requestSearchSuggestions(keyWord);
    }
  }

  //构造热搜按钮列表，模仿PiliPlus样式
  Future<List<Widget>> requestHotWordButtons() async {
    List<Widget> widgetList = [];
    List<HotWordItem> wordList = [];
    try {
      wordList = await SearchApi.getHotWords();
      log('Hot words count: ${wordList.length}');
    } catch (e) {
      log("requestHotWordButtons:$e");
      wordList = [];
    }
    
    // 如果没有热搜数据，添加提示信息
    if (wordList.isEmpty) {
      widgetList.add(
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "暂无热搜数据",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
      return widgetList;
    }
    
    // 构造热搜按钮，模仿PiliPlus样式
    for (var i in wordList) {
      // 确保关键词不为空
      if ((i.keyWord.isNotEmpty || i.showWord.isNotEmpty)) {
        widgetList.add(
          _buildHotKeywordItem(i),
        );
      }
    }
    
    // 如果构造后仍然为空，添加提示信息
    if (widgetList.isEmpty) {
      widgetList.add(
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "暂无热搜数据",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return widgetList;
  }

  // 构建单个热搜关键词项，模仿PiliPlus的HotKeyword组件
  Widget _buildHotKeywordItem(HotWordItem item) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: const BorderRadius.all(Radius.circular(3)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        onTap: () {
          setTextFieldText(item.keyWord);
          // 使用小延迟确保文本设置完成后再搜索
          Future.microtask(() => search(item.keyWord));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 10),
          child: Tooltip(
            message: item.keyWord,
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 5, 0, 5),
                    child: Text(
                      item.showWord,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                // 如果有图标，显示图标（这里暂时不实现，因为当前数据模型没有图标字段）
                // if (item.icon != null && item.icon!.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(left: 4),
                //     child: CachedNetworkImage(
                //       imageUrl: item.icon!,
                //       height: 15,
                //     ),
                //   )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //获取搜索建议并构造其控件
  Future<void> requestSearchSuggestions(String keyWord) async {
    // 如果关键词为空，清空搜索建议
    if (keyWord.trim().isEmpty) {
      searchSuggestionItems.clear();
      return;
    }
    
    List<SearchSuggestItem> list = [];
    try {
      list = await SearchApi.getSearchSuggests(keyWord: keyWord);
    } catch (e) {
      log("requestSearchSuggestions:$e");
      // 出错时不清空现有建议，保持用户体验
      return;
    }
    
    // 更新搜索建议列表
    searchSuggestionItems.clear();
    for (var i in list) {
      searchSuggestionItems.add(
        SizedBox(
          width: double.infinity,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                i.showWord,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            onTap: () {
              setTextFieldText(i.realWord);
              // 使用小延迟确保文本设置完成后再搜索
              Future.microtask(() => search(i.realWord));
            },
          ),
        ),
      );
    }
  }

  //搜索框内容改变
  onSearchWordChanged(String keyWord) {
    //搜索框不为空,且不为空字符,请求显示搜索提示
    if (keyWord.trim().isNotEmpty) {
      showSearchSuggest.value = true;
      // 使用防抖动流
      _searchSuggestionController?.add(keyWord);
    } else {
      showSearchSuggest.value = false;
      searchSuggestionItems.clear();
    }

    //搜索框不为空,显示删除按钮
    if (keyWord.isNotEmpty) {
      showEditDelete.value = true;
    } else {
      showEditDelete.value = false;
    }
  }

  //搜索某词
  search(String keyWord) {
    //不为空且不为空字符,保存历史并搜索
    if (keyWord.trim().isNotEmpty) {
      log("searching: $keyWord");
      try {
        _saveSearchedWord(keyWord.trim());
      } catch (e) {
        log("保存搜索历史时出错: $e");
        // 即使保存历史出错，也不影响搜索功能
      }
      
      // 使用Get.to进行页面跳转，确保正确导航
      try {
        Get.to(() => SearchResultPage(
            key: ValueKey('SearchResultPage:$keyWord'), keyWord: keyWord));
      } catch (e) {
        log("跳转到搜索结果页面时出错: $e");
        // 显示错误提示
        Get.snackbar("错误", "无法跳转到搜索结果页面，请重试");
      }
    } else if (keyWord.isEmpty && defaultSearchWord.isNotEmpty) {
      setTextFieldText(defaultSearchWord);
      // 使用微任务确保文本设置完成后执行搜索
      Future.microtask(() => search(defaultSearchWord));
    } else {
      // 关键词为空且没有默认搜索词
      Get.snackbar("提示", "请输入搜索关键词");
    }
  }

  //获取/刷新历史搜索词控件
  _refreshHistoryWord() async {
    var box = BiliYouStorage.history;
    List<Widget> widgetList = [];
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    for (String i in list.reversed) {
      widgetList.add(
        Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          child: GestureDetector(
            child: Chip(
              label: Text(i),
              onDeleted: () {
                //点击删除某条历史记录
                _deleteSearchedWord(i);
              },
            ),
            onTap: () {
              //点击某条历史记录
              setTextFieldText(i);
              // 使用小延迟确保文本设置完成后再搜索
              Future.microtask(() => search(i));
            },
          ),
        ),
      );
    }
    historySearchedWords.value = widgetList;
  }

  //保存搜索词
  _saveSearchedWord(String keyWord) async {
    var box = BiliYouStorage.history;
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    //不存在相同的词就放进去
    if (!list.contains(keyWord)) {
      list.add(keyWord);
      box.put("searchHistory", list);
    }
    _refreshHistoryWord(); //刷新历史记录控件
  }

  //删除所有搜索历史
  clearAllSearchedWords() async {
    var box = BiliYouStorage.history;
    box.put("searchHistory", <String>[]);
    _refreshHistoryWord(); //刷新历史记录控件
  }

  //删除历史记录某个词
  _deleteSearchedWord(String word) async {
    var box = BiliYouStorage.history;
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    list.remove(word);
    box.put("searchHistory", list);
    _refreshHistoryWord();
  }

  setTextFieldText(String text) {
    textEditingController.text = text;
    textEditingController.selection =
        TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  @override
  void onClose() {
    textFeildFocusNode.dispose();
    textEditingController.dispose();
    _searchSuggestionSubscription?.cancel();
    _searchSuggestionController?.close();
    super.onClose();
  }
}
