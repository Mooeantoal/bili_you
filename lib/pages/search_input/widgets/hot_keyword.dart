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
                onTap: () => onClick?.call(i.keyWord),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 10),
                  child: Tooltip(
                    message: i.keyWord,
                    child: Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(6, 5, 0, 5),
                            child: Text(
                              i.showWord,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 14),
                            ),
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