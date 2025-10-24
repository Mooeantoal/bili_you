import 'dart:developer';
import 'dart:async';

import 'package:bili_you/common/api/search_api.dart';
import 'package:bili_you/common/models/local/search/hot_word_item.dart';
import 'package:bili_you/common/models/local/search/search_suggest_item.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/pages/search_result/index.dart';
import 'package:bili_you/pages/search_result/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stream_transform/stream_transform.dart';

class SearchInputPageController extends GetxController {
  SearchInputPageController();
  RxBool showSearchSuggest = false.obs;
  RxList<Widget> searchSuggestionItems = <Widget>[].obs;
  TextEditingController textEditingController = TextEditingController();
  final FocusNode textFeildFocusNode = FocusNode();
  late String defaultSearchWord;
  RxBool showEditDelete = false.obs;

  // history
  late final RxList<String> historyList;

  // suggestion
  StreamController<String>? _ctr;
  StreamSubscription<String>? _sub;
  late final RxList<SearchSuggestItem> searchSuggestList;

  // trending
  late final RxList<HotWordItem> hotSearchList;

  @override
  void onInit() {
    super.onInit();
    print('Search controller initialized');
    historyList = List<String>.from(
      BiliYouStorage.history.get("searchHistory", defaultValue: <String>[]) ?? [],
    ).obs;
    print('History list loaded: ${historyList.length} items');
    
    searchSuggestList = <SearchSuggestItem>[].obs;
    hotSearchList = <HotWordItem>[].obs;
    
    _ctr = StreamController<String>();
    _sub = _ctr!.stream
        .debounce(const Duration(milliseconds: 200), trailing: true)
        .listen(querySearchSuggest);
        
    queryHotSearchList();
  }

  // 搜索
  Future<void> submit() async {
    if (textEditingController.text.isEmpty) {
      if (defaultSearchWord.isNotEmpty) {
        textEditingController.text = defaultSearchWord;
      } else {
        return;
      }
    }

    // 保存搜索历史
    if (!historyList.contains(textEditingController.text)) {
      historyList.insert(0, textEditingController.text);
      BiliYouStorage.history.put("searchHistory", historyList);
    }

    textFeildFocusNode.unfocus();
    Get.to(() => SearchResultPage(
        key: ValueKey('SearchResultPage:${textEditingController.text}'), 
        keyWord: textEditingController.text));
  }

  // 获取热搜关键词
  Future<void> queryHotSearchList() async {
    try {
      var list = await SearchApi.getHotWords();
      print('Hot search words loaded: ${list.length} items');
      for (var item in list) {
        print('Hot word: ${item.keyWord} - ${item.showWord}');
      }
      hotSearchList.value = list;
    } catch (e) {
      log("queryHotSearchList: $e");
      // 即使出现错误，也要确保hotSearchList是一个空列表而不是null
      hotSearchList.value = [];
    }
  }

  void onClickKeyword(String keyword) {
    textEditingController.text = keyword;
    searchSuggestList.clear();
    submit();
  }

  Future<void> querySearchSuggest(String value) async {
    print('Query search suggest for: "$value"');
    if (value.isEmpty) {
      searchSuggestList.clear();
    } else {
      try {
        var list = await SearchApi.getSearchSuggests(keyWord: value);
        print('Search suggest results: ${list.length} items');
        for (var item in list) {
          print('Suggest item: ${item.showWord} - ${item.realWord}');
        }
        searchSuggestList.value = list;
      } catch (e) {
        log("querySearchSuggest: $e");
        searchSuggestList.value = [];
      }
    }
  }

  void onLongSelect(String word) {
    historyList.remove(word);
    BiliYouStorage.history.put("searchHistory", historyList);
  }

  void onClearHistory() {
    historyList.clear();
    BiliYouStorage.history.put("searchHistory", []);
  }

//获取搜索建议并构造其控件
  Future<void> requestSearchSuggestions(String keyWord) async {
    print('Request search suggestions for: "$keyWord"');
    late List<SearchSuggestItem> list;
    try {
      list = await SearchApi.getSearchSuggests(keyWord: keyWord);
      print('Search suggestions loaded: ${list.length} items');
    } catch (e) {
      log("requestSearchSuggestions:$e");
      list = [];
      return;
    }
    searchSuggestionItems.clear();
    for (var i in list) {
      searchSuggestionItems.add(InkWell(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            i.showWord,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        onTap: () {
          setTextFieldText(i.realWord);
          search(i.realWord);
        },
      ));
    }
  }

//搜索框内容改变
  onSearchWordChanged(String keyWord) {
    print('Search word changed: "$keyWord"');
    // 添加到流控制器中用于防抖搜索建议
    _ctr?.add(keyWord);
    
    //搜索框不为空,且不为空字符,请求显示搜索提示
    if (keyWord.trim().isNotEmpty) {
      showSearchSuggest.value = true;
      requestSearchSuggestions(keyWord);
    } else {
      showSearchSuggest.value = false;
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
      _saveSearchedWord(keyWord.trim());
      Get.to(() => SearchResultPage(
          key: ValueKey('SearchResultPage:$keyWord'), keyWord: keyWord));
    } else if (keyWord.isEmpty && defaultSearchWord.isNotEmpty) {
      setTextFieldText(defaultSearchWord);
      search(defaultSearchWord);
    }
  }

//获取/刷新历史搜索词控件
  _refreshHistoryWord() async {
    print('Refreshing search history');
    var box = BiliYouStorage.history;
    List<Widget> widgetList = [];
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    print('Search history loaded: ${list.length} items');
    for (var item in list) {
      print('History item: $item');
    }
    for (String i in list.reversed) {
      widgetList.add(
        GestureDetector(
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
            search(i);
          },
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

  _initData() async {
    print('Initializing search data');
    _refreshHistoryWord();
    textFeildFocusNode.addListener(() {
      if (textFeildFocusNode.hasFocus &&
          textEditingController.text.isNotEmpty) {
        showEditDelete.value = true;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    print('Search controller ready');
    _initData();
  }

  @override
  void onClose() {
    textFeildFocusNode.dispose();
    textEditingController.dispose();
    _sub?.cancel();
    _ctr?.close();
    super.onClose();
  }
  
  Rx<List<Widget>> historySearchedWords = Rx<List<Widget>>([]);
}














