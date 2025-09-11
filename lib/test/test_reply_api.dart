import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';

/// 测试评论API的功能
void testReplyApi() async {
  try {
    // 测试视频BV1xx411c7mD (av170001)
    String testBvid = 'BV1xx411c7mD';
    int testAvid = BvidAvidUtil.bvid2Av(testBvid);
    
    print('测试评论API');
    print('BVID: $testBvid');
    print('AVID: $testAvid');
    
    // 获取评论
    var result = await ReplyApiV2.getComments(
      type: 1, // 视频稿件
      oid: testAvid.toString(),
      sort: 1, // 按点赞数排序
      ps: 10, // 每页10条
      pn: 1, // 第1页
    );
    
    print('评论获取成功！');
    print('总评论数: ${result.page.acount}');
    print('当前页评论数: ${result.replies.length}');
    print('热评数: ${result.hots.length}');
    
    // 打印前几条评论
    if (result.replies.isNotEmpty) {
      print('\n前几条评论:');
      for (int i = 0; i < result.replies.length && i < 3; i++) {
        var comment = result.replies[i];
        print('${i + 1}. ${comment.member.uname}: ${comment.content.message}');
        print('   点赞数: ${comment.like}, 回复数: ${comment.rcount}');
      }
    }
    
    if (result.hots.isNotEmpty) {
      print('\n热评:');
      for (int i = 0; i < result.hots.length && i < 2; i++) {
        var comment = result.hots[i];
        print('${i + 1}. ${comment.member.uname}: ${comment.content.message}');
        print('   点赞数: ${comment.like}, 回复数: ${comment.rcount}');
      }
    }
    
  } catch (e) {
    print('测试失败: $e');
  }
}