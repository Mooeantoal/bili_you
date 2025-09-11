import 'package:bili_you/common/api/reply_api_v2.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';

/// 测试新版评论API的功能
void main() async {
  print('开始测试新版评论API...');
  
  try {
    // 测试一个知名视频
    String testBvid = 'BV1xx411c7mD'; // 第一个视频
    int testAvid = BvidAvidUtil.bvid2Av(testBvid);
    
    print('测试视频: $testBvid (avid: $testAvid)');
    
    // 获取评论
    var result = await ReplyApiV2.getComments(
      type: 1, // 视频稿件
      oid: testAvid.toString(),
      sort: 1, // 按点赞数排序
      ps: 5, // 每页5条
      pn: 1, // 第1页
    );
    
    print('\n✅ 评论获取成功！');
    print('📊 统计信息:');
    print('   - 总评论数: ${result.page.acount}');
    print('   - 当前页评论数: ${result.replies.length}');
    print('   - 热评数: ${result.hots.length}');
    print('   - 页码: ${result.page.num}');
    print('   - 每页大小: ${result.page.size}');
    
    // 显示热评
    if (result.hots.isNotEmpty) {
      print('\n🔥 热门评论:');
      for (int i = 0; i < result.hots.length && i < 2; i++) {
        var comment = result.hots[i];
        print('   ${i + 1}. ${comment.member.uname}:');
        print('      "${comment.content.message}"');
        print('      👍 ${comment.like} | 💬 ${comment.rcount} | Lv${comment.member.levelInfo.currentLevel}');
      }
    }
    
    // 显示普通评论
    if (result.replies.isNotEmpty) {
      print('\n💬 普通评论:');
      for (int i = 0; i < result.replies.length && i < 3; i++) {
        var comment = result.replies[i];
        print('   ${i + 1}. ${comment.member.uname}:');
        print('      "${comment.content.message}"');
        print('      👍 ${comment.like} | 💬 ${comment.rcount} | Lv${comment.member.levelInfo.currentLevel}');
        
        // 显示VIP状态
        if (comment.member.vip.vipStatus == 1) {
          print('      🎗️ VIP用户');
        }
        
        // 显示认证状态
        if (comment.member.officialVerify.type >= 0) {
          print('      ✅ ${comment.member.officialVerify.desc}');
        }
      }
    }
    
    print('\n🎉 新版评论API测试完成！');
    
  } catch (e) {
    print('\n❌ 测试失败: $e');
    print('请检查网络连接和API接口');
  }
}