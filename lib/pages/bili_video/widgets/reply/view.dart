import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/widgets/reply_item.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class ReplyPage extends StatefulWidget {
  const ReplyPage({
    Key? key,
    required this.replyId,
    required this.replyType,
  })  : tag = "ReplyPage:$replyId",
        super(key: key);
  final String replyId;
  final ReplyType replyType;
  final String tag;

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  _ReplyPageState();

  @override
  bool get wantKeepAlive => true;

  late ReplyController controller;

  @override
  void initState() {
    controller = Get.put(ReplyController(
      bvid: widget.replyId,
      replyType: widget.replyType,
    ));
    controller.tag = widget.tag;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "未登录用户默认仅显示3条评论",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: SimpleEasyRefresher(
              easyRefreshController: controller.refreshController,
              onLoad: () async {
                controller.newReplyItems.clear();
                if (await controller.addReplyItems()) {
                  controller.refreshController.finishLoad(IndicatorResult.success);
                  controller.refreshController.resetFooter();
                } else {
                  controller.refreshController.finishLoad(IndicatorResult.fail);
                }
              },
              onRefresh: () async {
                controller.replyItems.clear();
                controller.topReplyItems.clear();
                controller.pageNum = 1;
                if (await controller.addReplyItems()) {
                  controller.refreshController.finishRefresh(IndicatorResult.success);
                } else {
                  controller.refreshController.finishRefresh(IndicatorResult.fail);
                }
              },
              childBuilder: (context, physics) {
                return CustomScrollView(
                  controller: controller.scrollController,
                  physics: physics,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < controller.topReplyItems.length) {
                            return ReplyItemWidget(
                              reply: controller.topReplyItems[index],
                              isTop: true,
                              isUp: controller.topReplyItems[index].member.mid ==
                                  controller.upperMid,
                            );
                          } else {
                            var i = index - controller.topReplyItems.length;
                            if (i < controller.newReplyItems.length) {
                              return ReplyItemWidget(
                                reply: controller.newReplyItems[i],
                                isUp: controller.newReplyItems[i].member.mid ==
                                    controller.upperMid,
                              );
                            } else {
                              i = i - controller.newReplyItems.length;
                              return ReplyItemWidget(
                                reply: controller.replyItems[i],
                                isUp: controller.replyItems[i].member.mid ==
                                    controller.upperMid,
                              );
                            }
                          }
                        },
                        childCount: controller.topReplyItems.length +
                            controller.newReplyItems.length +
                            controller.replyItems.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}