
class SearchSuggestModel {
  final List<SearchSuggestItem>? tag;

  SearchSuggestModel({this.tag});

  factory SearchSuggestModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestModel(
      tag: (json['tag'] as List?)
          ?.map((item) => SearchSuggestItem.fromJson(item))
          .toList(),
    );
  }
}

class SearchSuggestItem {
  final String? term;
  final String? value;
  final String? termType;
  final String? textRich;

  SearchSuggestItem({this.term, this.value, this.termType, this.textRich});

  factory SearchSuggestItem.fromJson(Map<String, dynamic> json) {
    return SearchSuggestItem(
      term: json['term'],
      value: json['value'],
      termType: json['term_type'],
      textRich: json['text_rich'],
    );
  }
}

class SearchTrendingData {
  final List<SearchTrendingItemModel>? list;
  final String? trackid;

  SearchTrendingData({this.list, this.trackid});

  factory SearchTrendingData.fromJson(Map<String, dynamic> json) {
    return SearchTrendingData(
      list: (json['list'] as List?)
          ?.map((item) => SearchTrendingItemModel.fromJson(item))
          .toList(),
      trackid: json['trackid'],
    );
  }
}

class SearchTrendingItemModel {
  final String? keyword;
  final String? showName;
  final String? icon;
  final bool? showLiveIcon;

  SearchTrendingItemModel({
    this.keyword,
    this.showName,
    this.icon,
    this.showLiveIcon,
  });

  factory SearchTrendingItemModel.fromJson(Map<String, dynamic> json) {
    return SearchTrendingItemModel(
      keyword: json['keyword'],
      showName: json['show_name'],
      icon: json['icon'],
      showLiveIcon: json['show_live_icon'] == 1,
    );
  }
}

class SearchRcmdData {
  final List<SearchTrendingItemModel>? list;
  final String? trackid;

  SearchRcmdData({this.list, this.trackid});

  factory SearchRcmdData.fromJson(Map<String, dynamic> json) {
    return SearchRcmdData(
      list: (json['list'] as List?)
          ?.map((item) => SearchTrendingItemModel.fromJson(item))
          .toList(),
      trackid: json['trackid'],
    );
  }
}