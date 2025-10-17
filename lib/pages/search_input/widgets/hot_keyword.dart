import 'package:bili_you/common/models/local/search/hot_word_item.dart';
import 'package:flutter/material.dart';

class HotKeyword extends StatelessWidget {
  final double width;
  final List<HotWordItem> hotSearchList;
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
    print('HotKeyword build called with ${hotSearchList.length} items');
    for (var item in hotSearchList) {
      print('Hot keyword item: ${item.keyWord} - ${item.showWord}');
    }
    
    if (hotSearchList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '暂无热搜数据',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // 使用 GridView 实现双列布局
    return GridView.count(
      crossAxisCount: 2, // 双列显示
      crossAxisSpacing: 5.0, // 列间距
      mainAxisSpacing: 5.0, // 行间距
      shrinkWrap: true, // 自适应高度
      physics: const NeverScrollableScrollPhysics(), // 禁止滚动
      children: [
        for (var i in hotSearchList)
          Material(
            type: MaterialType.transparency,
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              onTap: () => onClick?.call(i.keyWord),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // 调整内边距
                child: Tooltip(
                  message: i.keyWord,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          i.showWord,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 12), // 缩小字体
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}