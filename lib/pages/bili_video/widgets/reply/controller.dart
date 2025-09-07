import 'dart:developer';

import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/add_reply_util.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReplyController extends GetxController {
  ReplyController({
    required this.bvid,
    required this.replyType,
  });
  String bvid;
  late String tag;
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  ScrollController scrollController = ScrollController();
  List<ReplyItem> replyItems = [];
  List<ReplyItem> topReplyItems = [];
  List<ReplyItem> newReplyItems = [];
  int upperMid = 0;
  int replyCount = 0;
  int pageNum = 1;
  final ReplyType replyType;
  Function()? updateWidget;

  @override
  void onInit() {
    tag = "ReplyPage:$bvid";
    refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    super.onInit();
  }

  @override
  void onReady() async {
    await addReplyItems().then((value) {
      refreshController.finishRefresh();
      update();
    });
    super.onReady();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onLoad() async {
    await addReplyItems().then((value) {
      if (value) {
        refreshController.finishLoad(IndicatorResult.success);
        refreshController.resetFooter();
      } else {
        refreshController.finishLoad(IndicatorResult.fail);
      }
      update();
    });
  }

  Future<void> onRefresh() async {
    replyItems.clear();
    topReplyItems.clear();
    pageNum = 1;
    await addReplyItems().then((value) {
      if (value) {
        refreshController.finishRefresh(IndicatorResult.success);
      } else {
        refreshController.finishRefresh(IndicatorResult.fail);
      }
      update();
    });
  }

  Future<bool> addReplyItems() async {
    try {
      ReplyInfo replyInfo = await ReplyApi.getReply(
          oid: bvid, pageNum: pageNum, type: replyType);
      upperMid = replyInfo.upperMid;
      replyCount = replyInfo.replyCount;
      if (pageNum == 1) topReplyItems.addAll(replyInfo.topReplies);
      replyItems.addAll(replyInfo.replies);
      pageNum++;
      update();
      return true;
    } catch (e) {
      log("reply load failed:$e");
      update();
      return false;
    }
  }

  toggleApiMode() {
    // TODO: implement toggleApiMode
  }
}
