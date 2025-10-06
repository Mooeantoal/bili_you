import 'package:bili_you/common/models/local/search/hot_word_item.dart'; // 导入HotWordItem
import 'package:bili_you/pages/search_test/models.dart';
import 'package:flutter/material.dart';

class HotKeyword extends StatelessWidget {
  final double width;
  // 修改为可以接受不同类型的列表
  final List<dynamic> hotSearchList;
  final Function? onClick;
  final bool showMore;
  const HotKeyword({
    super.key,
    required double width,
    required this.hotSearchList,
    this.onClick,
    this.showMore = true,
  }) : width = width / 2 - 4;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 0.4,
      spacing: 5.0,
      children: [
        for (var i in hotSearchList)
          SizedBox(
            width: width,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                onTap: () {
                  // 根据不同的数据类型获取关键词
                  String keyword = '';
                  if (i is SearchTrendingItemModel) {
                    keyword = i.keyword ?? '';
                  } else if (i is HotWordItem) {
                    keyword = i.keyWord;
                  }
                  onClick?.call(keyword);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 10),
                  child: Tooltip(
                    // 根据不同的数据类型获取显示名称
                    message: i is SearchTrendingItemModel 
                        ? (i.keyword ?? '') 
                        : (i is HotWordItem ? i.keyWord : ''),
                    child: Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(6, 5, 0, 5),
                            child: Text(
                              // 根据不同的数据类型获取显示文本
                              i is SearchTrendingItemModel 
                                  ? (i.showName ?? i.keyword ?? '') 
                                  : (i is HotWordItem ? i.showWord : ''),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        // 处理图标显示
                        if (i is SearchTrendingItemModel && i.icon != null && i.icon!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Image.network(
                              i.icon!,
                              height: 15,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                          )
                        else if (i is SearchTrendingItemModel && i.showLiveIcon == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Image.asset(
                              'assets/images/live/live.gif',
                              width: 48,
                              height: 15,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}