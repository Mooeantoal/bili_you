import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';

void main() async {
  try {
    print('开始测试API调用...');
    
    // 测试获取评论数据
    final replyInfo = await ReplyApi.getReply(
      oid: '113309709829793',
      pageNum: 1,
      type: ReplyType.video,
      sort: ReplySort.like,
    );
    
    print('API调用成功!');
    print('获取到 ${replyInfo.replies.length} 条评论');
    print('获取到 ${replyInfo.topReplies.length} 条热门评论');
    print('总评论数: ${replyInfo.replyCount}');
    print('UP主ID: ${replyInfo.upperMid}');
    
    // 测试获取楼中楼评论（使用第一条评论的rpid作为rootId）
    if (replyInfo.replies.isNotEmpty) {
      final firstReply = replyInfo.replies.first;
      print('测试获取楼中楼评论，rootId: ${firstReply.rpid}');
      
      final replyReplyInfo = await ReplyApi.getReplyReply(
        oid: '113309709829793',
        rootId: firstReply.rpid,
        pageNum: 1,
        pageSize: 20,
      );
      
      print('楼中楼评论获取成功!');
      print('获取到 ${replyReplyInfo.replies.length} 条楼中楼评论');
      print('根评论ID: ${replyReplyInfo.rootReply.rpid}');
    }
  } catch (e) {
    print('测试过程中发生错误: $e');
  }
}