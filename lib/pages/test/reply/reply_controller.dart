import 'package:get/get.dart';
import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

class ReplyController extends GetxController {
  // 评论数据
  var replies = <ReplyItem>[].obs;
  var hotReplies = <ReplyItem>[].obs;
  
  // 加载状态
  var isLoading = false.obs;
  var hasMore = true.obs;
  var errorMessage = ''.obs;
  
  // 分页信息
  var currentPage = 1.obs;
  var totalReplies = 0.obs;
  
  // 排序方式
  var sortType = ReplySort.like.obs;
  
  // UP主mid
  var upMid = 0.obs;
  
  /// 加载评论数据
  Future<void> loadReplies(String oid, ReplyType type) async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final replyInfo = await ReplyApi.getReply(
        oid: oid,
        pageNum: currentPage.value,
        type: type,
        sort: sortType.value,
      );
      
      // 更新UP主mid
      upMid.value = replyInfo.upperMid;
      totalReplies.value = replyInfo.replyCount;
      
      if (currentPage.value == 1) {
        // 刷新数据
        hotReplies.value = replyInfo.topReplies;
        replies.value = replyInfo.replies;
      } else {
        // 加载更多数据
        replies.addAll(replyInfo.replies);
      }
      
      // 判断是否还有更多数据
      hasMore.value = replyInfo.replies.isNotEmpty;
      
      // 更新当前页码
      if (hasMore.value) {
        currentPage.value++;
      }
    } catch (e) {
      print('加载评论时发生错误: $e');
      errorMessage.value = e.toString();
      // 特别处理服务器内部错误
      if (e.toString().contains('服务器内部错误')) {
        // 不再继续请求，避免重复错误
        hasMore.value = false;
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 刷新评论
  Future<void> refreshReplies(String oid, ReplyType type) async {
    currentPage.value = 1;
    hasMore.value = true;
    await loadReplies(oid, type);
  }
  
  /// 加载楼中楼评论
  Future<List<ReplyItem>> loadSubReplies(String oid, int rootId) async {
    try {
      final replyReplyInfo = await ReplyApi.getReplyReply(
        oid: oid,
        rootId: rootId,
        pageNum: 1,
        pageSize: 20,
      );
      
      return replyReplyInfo.replies;
    } catch (e) {
      print('加载楼中楼评论时发生错误: $e');
      // 如果加载失败，返回空列表
      return [];
    }
  }
  
  /// 更改排序方式
  void changeSortType(ReplySort newSortType, String oid, ReplyType type) {
    if (sortType.value != newSortType) {
      sortType.value = newSortType;
      refreshReplies(oid, type);
    }
  }
  
  /// 重置控制器状态
  void reset() {
    replies.clear();
    hotReplies.clear();
    currentPage.value = 1;
    hasMore.value = true;
    errorMessage.value = '';
    isLoading.value = false;
    upMid.value = 0;
    totalReplies.value = 0;
  }
}