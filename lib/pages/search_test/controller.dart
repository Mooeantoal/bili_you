import 'dart:async';
import 'package:bili_you/common/api/search_api.dart'; // 导入SearchApi
import 'package:bili_you/common/models/local/search/hot_word_item.dart'; // 导入HotWordItem
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/utils/settings.dart';
import 'package:bili_you/pages/search_test/api.dart';
import 'package:bili_you/pages/search_test/models.dart';
import 'package:bili_you/pages/search_result/view.dart'; // 添加搜索结果页面导入
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stream_transform/stream_transform.dart';

class SearchTestController extends GetxController {
  SearchTestController(this.tag);
  final String tag;

  final searchFocusNode = FocusNode();
  final controller = TextEditingController();

  String? hintText;

  int initIndex = 0;

  // uid
  final RxBool showUidBtn = false.obs;

  // history
  final RxBool recordSearchHistory = true.obs;
  late final RxList<String> historyList;

  // suggestion
  final bool searchSuggestion = true;
  StreamController<String>? _ctr;
  StreamSubscription<String>? _sub;
  late final RxList<SearchSuggestItem> searchSuggestList;

  // trending
  final bool enableHotKey = true;
  late final Rx<List<HotWordItem>> hotSearchData; // 修改为复用的HotWordItem列表

  // rcmd
  final bool enableSearchRcmd = true;
  late final Rx<SearchRcmdData?> recommendData;

  @override
  void onInit() {
    super.onInit();
    final params = Get.parameters;
    hintText = params['hintText'];
    final text = params['text'];
    if (text != null) {
      controller.text = text;
    }

    historyList = List<String>.from(
      BiliYouStorage.history.get('searchHistory') ?? [],
    ).obs;

    if (searchSuggestion) {
      _ctr = StreamController<String>();
      _sub = _ctr!.stream
          .debounce(const Duration(milliseconds: 200), trailing: true)
          .listen(querySearchSuggest);
      searchSuggestList = <SearchSuggestItem>[].obs;
    }

    if (enableHotKey) {
      hotSearchData = Rx<List<HotWordItem>>([]); // 初始化为空列表
      queryHotSearchList(); // 获取热搜数据
    }

    if (enableSearchRcmd) {
      recommendData = Rx<SearchRcmdData?>(null);
      queryRecommendList();
    }
  }

  void validateUid() {
    showUidBtn.value = RegExp(r'^\d+$').hasMatch(controller.text);
  }

  void onChange(String value) {
    validateUid();
    if (searchSuggestion) {
      if (value.isEmpty) {
        searchSuggestList.clear();
      } else {
        _ctr!.add(value);
      }
    }
  }

  void onClear() {
    if (controller.value.text != '') {
      controller.clear();
      searchSuggestList.clear();
      searchFocusNode.requestFocus();
      showUidBtn.value = false;
    } else {
      Get.back();
    }
  }

  // 搜索
  Future<void> submit() async {
    if (controller.text.isEmpty) {
      if (hintText == null || hintText!.isEmpty) {
        return;
      }
      controller.text = hintText!;
      validateUid();
    }

    if (recordSearchHistory.value) {
      historyList
        ..remove(controller.text)
        ..insert(0, controller.text);
      BiliYouStorage.history.put('searchHistory', historyList);
    }

    searchFocusNode.unfocus();
    // 跳转到搜索结果页面
    await Get.to(() => SearchResultPage(keyWord: controller.text));
    searchFocusNode.requestFocus();
  }

  // 获取热搜关键词 - 复用当前搜索页面的热搜数据
  Future<void> queryHotSearchList() async {
    try {
      List<HotWordItem> wordList = await SearchApi.getHotWords();
      hotSearchData.value = wordList;
    } catch (e) {
      print('获取热搜榜失败: $e');
    }
  }

  Future<void> queryRecommendList() async {
    try {
      var res = await SearchTestApi.getSearchRecommend();
      if (res['code'] == 0) {
        recommendData.value = SearchRcmdData.fromJson(res['data']);
      }
    } catch (e) {
      print('获取搜索推荐失败: $e');
    }
  }

  void onClickKeyword(String keyword) {
    controller.text = keyword;
    validateUid();

    searchSuggestList.clear();
    submit();
  }

  Future<void> querySearchSuggest(String value) async {
    try {
      var res = await SearchTestApi.getSearchSuggest(term: value);
      if (res['code'] == 0) {
        SearchSuggestModel data = SearchSuggestModel.fromJson(res['data']);
        if (data.tag != null) {
          searchSuggestList.value = data.tag!;
        }
      }
    } catch (e) {
      print('获取搜索建议失败: $e');
    }
  }

  void onLongSelect(String word) {
    historyList.remove(word);
    BiliYouStorage.history.put('searchHistory', historyList);
  }

  void onClearHistory() {
    // 显示确认对话框
    Get.defaultDialog(
      title: '确定清空搜索历史？',
      content: const Text('此操作不可撤销'),
      confirm: ElevatedButton(
        onPressed: () {
          historyList.clear();
          BiliYouStorage.history.put('searchHistory', []);
          Get.back();
        },
        child: const Text('确定'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('取消'),
      ),
    );
  }

  @override
  void onClose() {
    searchFocusNode.dispose();
    controller.dispose();
    _sub?.cancel();
    _ctr?.close();
    super.onClose();
  }
}