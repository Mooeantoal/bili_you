import 'dart:developer';

import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 新版评论区控制器
/// 使用原生API而不是WebView
class ReplyControllerV2 extends GetxController {
  ReplyControllerV2({
    required this.bvid,
  });

  final String bvid;
  
  // 状态管理
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalComments = 0.obs;
  
  // 数据
  final RxList<CommentItem> hotComments = <CommentItem>[].obs;
  final RxList<CommentItem> comments = <CommentItem>[].obs;
  CommentPageData? _pageData;
  
  // 控制器
  late EasyRefreshController refreshController;
  late ScrollController scrollController;
  
  // 排序方式 (0:按时间, 1:按点赞数, 2:按回复数)
  final RxInt sortType = 1.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    scrollController = ScrollController();
    
    // 初始加载评论
    loadComments(refresh: true);
  }
  
  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  /// 加载评论
  Future<void> loadComments({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isLoading.value = true;
        hasError.value = false;
        errorMessage.value = '';
      }
      
      // 将bvid转换为avid
      int avid;
      try {
        avid = BvidAvidUtil.bvid2Av(bvid);
        if (avid <= 0) {
          throw Exception('无效的视频ID');
        }
      } catch (e) {
        log('BVID转换失败: bvid=$bvid, error=$e');
        throw Exception('视频ID转换失败，请检查视频链接');
      }
      
      log('加载评论: bvid=$bvid, avid=$avid, page=${currentPage.value}, sort=${sortType.value}');
      
      var data = await ReplyApiV2.getComments(
        type: 1, // 视频稿件
        oid: avid.toString(),
        sort: sortType.value,
        ps: 20,
        pn: currentPage.value,
      );
      
      _pageData = data;
      totalComments.value = data.page.acount;
      
      if (refresh) {
        // 刷新时清空并重新加载
        hotComments.clear();
        comments.clear();
        
        // 添加热评
        hotComments.addAll(data.hots);
        
        // 添加置顶评论
        if (data.upper?.top != null) {
          comments.insert(0, data.upper!.top!);
        }
        
        // 添加普通评论
        comments.addAll(data.replies);
      } else {
        // 加载更多时追加
        comments.addAll(data.replies);
      }
      
      // 检查是否还有更多评论
      hasMore.value = data.replies.length >= 20;
      
      isLoading.value = false;
      hasError.value = false;
      
      if (refresh) {
        refreshController.finishRefresh(IndicatorResult.success);
      } else {
        refreshController.finishLoad(
          hasMore.value ? IndicatorResult.success : IndicatorResult.noMore,
        );
      }
      
      log('评论加载成功: 热评${hotComments.length}条, 普通评论${comments.length}条, 总数${totalComments.value}');
      
    } catch (e) {
      log('加载评论失败: $e');
      
      isLoading.value = false;
      hasError.value = true;
      
      // 提供更友好的错误信息
      String friendlyError = e.toString();
      if (friendlyError.contains('Exception: ')) {
        friendlyError = friendlyError.replaceFirst('Exception: ', '');
      }
      
      errorMessage.value = friendlyError;
      
      if (refresh) {
        refreshController.finishRefresh(IndicatorResult.fail);
      } else {
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }
  }
  
  /// 刷新评论
  Future<void> onRefresh() async {
    await loadComments(refresh: true);
  }
  
  /// 加载更多评论
  Future<void> onLoadMore() async {
    if (!hasMore.value) return;
    
    currentPage.value++;
    await loadComments(refresh: false);
  }
  
  /// 改变排序方式
  Future<void> changeSortType(int newSortType) async {
    if (sortType.value == newSortType) return;
    
    sortType.value = newSortType;
    await loadComments(refresh: true);
  }
  
  /// 获取时间格式化字符串
  String getTimeString(int timestamp) {
    var now = DateTime.now();
    var commentTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var difference = now.difference(commentTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 获取排序类型文本
  String getSortTypeText(int sortType) {
    switch (sortType) {
      case 0:
        return '按时间';
      case 1:
        return '按热度';
      case 2:
        return '按回复';
      default:
        return '按热度';
    }
  }
  
  /// 点击评论项
  void onCommentTap(CommentItem comment) {
    // TODO: 实现点击评论的逻辑，比如查看回复
    log('点击评论: ${comment.content.message}');
  }
  
  /// 点赞评论
  Future<void> likeComment(CommentItem comment) async {
    // TODO: 实现点赞评论的逻辑
    log('点赞评论: ${comment.content.message}');
  }
  
  /// 回复评论
  Future<void> replyComment(CommentItem comment) async {
    // TODO: 实现回复评论的逻辑
    log('回复评论: ${comment.content.message}');
  }
}