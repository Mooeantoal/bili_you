import 'dart:developer';
import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/add_reply_util.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 定义ReplySortType枚举
enum ReplySortType { hot, time }

class ReplyController extends GetxController {
  ReplyController({
    required this.bvid,
    required this.replyType,
  });
  String bvid;
  late String tag; // 添加tag属性
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  ScrollController scrollController = ScrollController();
  List<ReplyItem> replyItems = [];
  List<ReplyItem> topReplyItems = [];
  List<ReplyItem> newReplyItems = []; //新增的评论
  int upperMid = 0;
  int replyCount = 0;
  int pageNum = 1;
  final ReplyType replyType;
  RxString sortTypeText = "按热度".obs;
  RxString sortInfoText = "热门评论".obs;
  ReplySort _replySort = ReplySort.like;
  
  // 添加sortType属性
  Rx<ReplySortType> sortType = ReplySortType.hot.obs;
  
  Function()? updateWidget;

  // 添加一个标志，用于跟踪是否使用无登录限制API
  bool useUnlimitedApi = false;

  @override
  void onInit() {
    tag = "ReplyPage:$bvid";
    refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    
    // 监听sortType变化并更新_replySort
    sortType.listen((value) {
      _replySort = value == ReplySortType.hot ? ReplySort.like : ReplySort.time;
    });
    
    super.onInit();
  }

  void onReady() async {
    await addReplyItems().then((value) {
      refreshController.finishRefresh();
      update();
    });
    super.onReady();
  }

  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<bool> addReplyItems() async {
    try {
      ReplyInfo replyInfo = await ReplyApi.getReply(
          oid: bvid,
          pageNum: pageNum,
          sort: _replySort,
          type: replyType,
          useUnlimitedApi: useUnlimitedApi);
      //更新up主mid
      upperMid = replyInfo.upperMid;
      //更新评论数量
      replyCount = replyInfo.replyCount;
      //更新排序方式显示文本
      if (_replySort == ReplySort.like) {
        sortTypeText.value = "按热度";
        sortInfoText.value = "热门评论";
      } else {
        sortTypeText.value = "按时间";
        sortInfoText.value = "最新评论";
      }
      //添加置顶评论
      if (pageNum == 1) topReplyItems.addAll(replyInfo.topReplies);
      //添加普通评论
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

  //切换排列方式
  void toggleSort() {
    if (_replySort == ReplySort.like) {
      sortTypeText.value = "按时间";
      sortInfoText.value = "最新评论";
      //切换为按时间排列
      _replySort = ReplySort.time;
    } else {
      sortTypeText.value = "按热度";
      sortInfoText.value = "热门评论";
      //切换为按热度排列
      _replySort = ReplySort.like;
    }
    //刷新评论
    refreshController.callRefresh();
  }

  // 切换API模式
  void toggleApiMode() {
    useUnlimitedApi = !useUnlimitedApi;
    refreshController.callRefresh();
  }

  showAddReplySheet() async {
    await AddReplyUtil.showAddReplySheet(
        replyType: replyType,
        oid: bvid,
        newReplyItems: newReplyItems,
        updateWidget: updateWidget,
        scrollController: scrollController);
  }
}
