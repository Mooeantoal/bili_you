import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/controller_v2.dart';
import 'package:bili_you/common/utils/debug_utils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 新版评论区视图
/// 使用原生API，提供更好的用户体验
class ReplyPageV2 extends StatefulWidget {
  const ReplyPageV2({
    Key? key,
    required this.bvid,
  })  : tag = "ReplyPageV2:$bvid",
        super(key: key);

  final String bvid;
  final String tag;

  @override
  State<ReplyPageV2> createState() => _ReplyPageV2State();
}

class _ReplyPageV2State extends State<ReplyPageV2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ReplyControllerV2 controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ReplyControllerV2(bvid: widget.bvid),
      tag: widget.tag,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Obx(() {
      if (controller.isLoading.value && controller.comments.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (controller.hasError.value && controller.comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '评论加载失败',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.loadComments(refresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      DebugUtils.showNativeReplyDebugDialog(bvid: widget.bvid);
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('调试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      
      return Column(
        children: [
          // 评论区头部
          _buildHeader(),
          // 评论列表
          Expanded(
            child: EasyRefresh(
              controller: controller.refreshController,
              onRefresh: controller.onRefresh,
              onLoad: controller.onLoadMore,
              child: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  // 热评区域
                  if (controller.hotComments.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader('热门评论'),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildCommentItem(controller.hotComments[index], isHot: true);
                        },
                        childCount: controller.hotComments.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildDivider(),
                    ),
                  ],
                  // 普通评论区域
                  if (controller.comments.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader('全部评论'),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildCommentItem(controller.comments[index]);
                        },
                        childCount: controller.comments.length,
                      ),
                    ),
                  ],
                  // 空状态
                  if (controller.comments.isEmpty && controller.hotComments.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无评论',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Obx(() => Text(
                '评论 ${controller.totalComments.value}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              )),
          const Spacer(),
          // 排序按钮
          Obx(() => PopupMenuButton<int>(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.getSortTypeText(controller.sortType.value),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
                  ],
                ),
                onSelected: controller.changeSortType,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1, child: Text('按热度')),
                  const PopupMenuItem(value: 0, child: Text('按时间')),
                  const PopupMenuItem(value: 2, child: Text('按回复')),
                ],
              )),
        ],
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 8,
      color: Colors.grey[100],
    );
  }

  /// 构建评论项
  Widget _buildCommentItem(CommentItem comment, {bool isHot = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHot ? Colors.orange[50] : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息行
          Row(
            children: [
              // 头像
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: comment.member.avatar,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder: () {
                    return Container(
                      width: 32,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // 用户名和等级
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 用户名
                        Text(
                          comment.member.uname,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: comment.member.vip.vipStatus == 1
                                ? Colors.pink
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // 等级
                        _buildLevelBadge(comment.member.levelInfo.currentLevel),
                        // VIP标识
                        if (comment.member.vip.vipStatus == 1) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        // 认证标识
                        if (comment.member.officialVerify.type >= 0) ...[
                          const SizedBox(width: 4),
                          Icon(
                            comment.member.officialVerify.type == 0
                                ? Icons.verified_user
                                : Icons.verified,
                            size: 14,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                    // 时间
                    Text(
                      controller.getTimeString(comment.ctime),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // 热评标识
              if (isHot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '热',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 评论内容
          _buildCommentContent(comment.content),
          const SizedBox(height: 12),
          // 操作栏
          Row(
            children: [
              // 点赞
              GestureDetector(
                onTap: () => controller.likeComment(comment),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      comment.action == 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 16,
                      color: comment.action == 1 ? Colors.blue : Colors.grey[600],
                    ),
                    if (comment.like > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        comment.like.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: comment.action == 1 ? Colors.blue : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 回复
              GestureDetector(
                onTap: () => controller.replyComment(comment),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reply_outlined, size: 16, color: Colors.grey[600]),
                    if (comment.rcount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        comment.rcount.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              // 楼层号
              if (comment.floor > 0)
                Text(
                  '#${comment.floor}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
            ],
          ),
          // 回复预览
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRepliesPreview(comment.replies),
          ],
        ],
      ),
    );
  }

  /// 构建等级徽章
  Widget _buildLevelBadge(int level) {
    if (level <= 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: _getLevelColor(level), width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        'Lv$level',
        style: TextStyle(
          fontSize: 8,
          color: _getLevelColor(level),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 获取等级颜色
  Color _getLevelColor(int level) {
    if (level >= 6) return Colors.red;
    if (level >= 5) return Colors.orange;
    if (level >= 4) return Colors.green;
    if (level >= 3) return Colors.blue;
    if (level >= 2) return Colors.cyan;
    return Colors.grey;
  }

  /// 构建评论内容
  Widget _buildCommentContent(CommentContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文本内容
        _buildRichText(content),
        // at的用户
        if (content.members.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: content.members.map((member) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '@${member.uname}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// 构建富文本内容（处理表情）
  Widget _buildRichText(CommentContent content) {
    String text = content.message;
    List<InlineSpan> spans = [];
    
    // 简单的文本处理，实际应该更复杂地解析表情和@用户
    spans.add(TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        height: 1.4,
      ),
    ));
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  /// 构建回复预览
  Widget _buildRepliesPreview(List<CommentItem> replies) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...replies.take(3).map((reply) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${reply.member.uname}: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: reply.content.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          if (replies.length > 3)
            Text(
              '查看全部${replies.length}条回复 >',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
              ),
            ),
        ],
      ),
    );
  }
}