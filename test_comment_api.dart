import 'package:bili_you/common/api/piliplus_reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

void main() async {
  try {
    print('开始测试获取评论...');
    
    // 测试获取评论
    final replyInfo = await PiliPlusReplyApi.getReply(
      oid: '1559365249', // 使用指定视频的aid
      pageNum: 1,
      type: ReplyType.video,
      sort: ReplySort.like,
    );
    
    print('获取评论成功!');
    print('普通评论数量: ${replyInfo.replies.length}');
    print('热门评论数量: ${replyInfo.topReplies.length}');
    print('总评论数: ${replyInfo.replyCount}');
    
    // 显示前几条评论的内容
    print('\n前3条普通评论:');
    for (int i = 0; i < replyInfo.replies.length && i < 3; i++) {
      final comment = replyInfo.replies[i];
      print('评论${i + 1}: ${comment.member.name} - ${comment.content.message}');
    }
    
    if (replyInfo.topReplies.isNotEmpty) {
      print('\n热门评论:');
      for (int i = 0; i < replyInfo.topReplies.length && i < 3; i++) {
        final comment = replyInfo.topReplies[i];
        print('热门评论${i + 1}: ${comment.member.name} - ${comment.content.message}');
      }
    }
  } catch (e) {
    print('测试过程中出现错误: $e');
  }
}