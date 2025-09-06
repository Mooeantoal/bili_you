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
  late ReplyController controller;

  @override
  void initState() {
    controller = Get.put(ReplyController(
      bvid: widget.replyId,
      replyType: widget.replyType,
    ));
    controller.tag = widget.tag; // 初始化tag属性
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<ReplyController>(
        tag: controller.tag,
        builder: (context) {
          return Column(
            children: [
              // 添加提示信息
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      "未登录用户默认仅显示3条评论",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        controller.toggleApiMode();
                      },
                      child: Obx(
                        () => Text(
                          controller.useUnlimitedApi ? "标准模式" : "扩展模式",
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.useUnlimitedApi 
                              ? Colors.blue 
                              : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    Obx(
                      () => Text(
                        "${controller.sortInfoText}(${controller.replyCount})",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          controller.toggleSort();
                        },
                        child: Obx(
                          () => Text(controller.sortTypeText.value),
                        )),
                  ],
                ),
              ),
              const Divider(
                height: 1,
              ),
              Expanded(
                  child: SimpleEasyRefresher(
                easyRefreshController: controller.refreshController,
                onLoad: () async {
                  controller.newReplyItems.clear();
                  if (await controller.addReplyItems()) {
                    controller.refreshController.finishLoad();
                    controller.refreshController.resetFooter();
                  } else {
                    controller.refreshController.finishLoad(
                        IndicatorResult.fail);
                  }
                },
                onRefresh: () async {
                  controller.replyItems.clear();
                  controller.topReplyItems.clear();
                  controller.pageNum = 1;
                  if (await controller.addReplyItems()) {
                    controller.refreshController.finishRefresh();
                  } else {
                    controller.refreshController.finishRefresh(
                        IndicatorResult.fail);
                  }
                },
                child: CustomScrollView(
                  controller: controller.scrollController,
                  slivers: [
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                                controller.replyItems.length)),
                  ],
                ),
              ))
            ],
          );
        });
  }

}
