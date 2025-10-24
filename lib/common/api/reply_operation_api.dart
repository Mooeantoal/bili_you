import 'package:bili_you/common/api/index.dart';
import 'package:bili_you/common/models/local/reply/add_reply_result.dart';
import 'package:bili_you/common/models/local/reply/reply_add_like_result.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/models/local/reply/reply_content.dart';
import 'package:bili_you/common/models/local/reply/reply_member.dart';
import 'package:bili_you/common/models/local/reply/official_verify.dart';
import 'package:bili_you/common/models/local/reply/vip.dart';
import 'package:bili_you/common/utils/cookie_util.dart';
import 'package:bili_you/common/utils/http_utils.dart';

class ReplyOperationApi {
  static Future<ReplyAddLikeResult> addLike(
      {required ReplyType type,
      required int oid,
      required int rpid,
      required bool likeOrUnlike}) async {
    var response =
        await HttpUtils().post(ApiConstants.replyAddLike, queryParameters: {
      'type': type.code,
      'oid': oid,
      'rpid': rpid,
      'action': likeOrUnlike ? 1 : 0,
      'csrf': await CookieUtils.getCsrf()
    });
    return ReplyAddLikeResult(
        isSuccess: response.data?['code'] == 0,
        error: response.data?['message'] ?? '');
  }

  ///# 发表评论
  ///
  ///type 评论区类型
  ///
  ///oid 目标评论区id
  ///
  ///root 根评论rpid（二级评论以上使用）
  ///
  ///parent 父评论rpid（二级评论同根评论id，若大于二级评论则为要回复的评论id）
  ///
  ///message 评论内容（最大10000字符，表情使用表情转义符）
  ///
  ///platform 发送平台标识
  static Future<AddReplyResult> addReply({
    required ReplyType type,
    required String oid,
    int? root,
    int? parent,
    required String message,
    ReplyPlatform platform = ReplyPlatform.web,
  }) async {
    var response =
        await HttpUtils().post(ApiConstants.addReply, queryParameters: {
      'type': type.code,
      'oid': oid,
      if (root != null) 'root': root,
      if (parent != null) 'parent': parent,
      'message': message,
      'plat': platform.index,
      'csrf': await CookieUtils.getCsrf()
    });
    return AddReplyResult(
        isSuccess: response.data?['code'] == 0,
        error: response.data?['message'] ?? '',
        replyItem: _parseReplyItem(response.data?['data']?['reply'] ?? {}));
  }
  
  // 解析评论项
  static ReplyItem _parseReplyItem(Map<String, dynamic> json) {
    // 解析楼中楼评论
    List<ReplyItem> replies = [];
    if (json['replies'] != null && json['replies'] is List) {
      for (var reply in json['replies']) {
        replies.add(_parseReplyItem(reply));
      }
    }

    // 解析表情
    List<Emote> emotes = [];
    if (json['content'] != null && json['content']['emote'] != null) {
      json['content']['emote'].forEach((key, value) {
        emotes.add(Emote(
          text: value['text'] ?? "",
          url: value['url'] ?? "",
          size: value['meta'] != null && value['meta']['size'] == 2 
              ? EmoteSize.big 
              : EmoteSize.small,
        ));
      });
    }

    // 解析图片
    List<ReplyPicture> pictures = [];
    if (json['content'] != null && json['content']['pictures'] != null) {
      for (var picture in json['content']['pictures']) {
        pictures.add(ReplyPicture(
          size: picture['img_size'] ?? 1,
          url: picture['img_src'] ?? "",
          width: picture['img_width'] ?? 0,
          height: picture['img_height'] ?? 0,
        ));
      }
    }

    // 解析链接
    List<ReplyJumpUrl> jumpUrls = [];
    if (json['content'] != null && json['content']['jump_url'] != null) {
      json['content']['jump_url'].forEach((key, value) {
        jumpUrls.add(ReplyJumpUrl(
          url: key,
          title: value['title'] ?? key,
        ));
      });
    }

    return ReplyItem(
      rpid: json['rpid'] ?? 0,
      oid: json['oid'] ?? 0,
      type: ReplyTypeCode.fromCode(json['type'] ?? 0),
      member: ReplyMember(
        mid: int.tryParse(json['member']['mid'] ?? "0") ?? 0,
        name: json['member']['uname'] ?? '未知用户',
        gender: GenderText.fromText(json['member']['sex'] ?? ""),
        avatarUrl: json['member']['avatar'] ?? '',
        level: json['member']['level_info'] != null 
            ? json['member']['level_info']['current_level'] 
            : 0,
        officialVerify: OfficialVerify(
          type: OfficialVerifyTypeCode.fromCode(
            json['member']['official_verify'] != null 
                ? json['member']['official_verify']['type'] 
                : -1
          ),
          description: json['member']['official_verify'] != null 
              ? json['member']['official_verify']['desc'] 
              : "",
        ),
        vip: Vip(
          isVip: json['member']['vip'] != null && json['member']['vip']['vip_status'] == 1,
          type: VipType.values[json['member']['vip'] != null ? json['member']['vip']['vip_type'] : 0],
        ),
      ),
      rootRpid: json['root'] ?? 0,
      parentRpid: json['parent'] ?? 0,
      dialogRpid: json['dialog'] ?? 0,
      replyCount: json['rcount'] ?? 0,
      replyTime: json['ctime'] ?? 0,
      preReplies: replies,
      likeCount: json['like'] ?? 0,
      hasLike: json['action'] == 1,
      location: json['reply_control'] != null && json['reply_control']['location'] != null
          ? json['reply_control']['location'].replaceAll("IP属地：", "")
          : "",
      content: ReplyContent(
        message: json['content'] != null ? json['content']['message'] : '',
        atMembers: [], // 简化处理
        emotes: emotes,
        pictures: pictures,
        jumpUrls: jumpUrls,
      ),
      tags: [], // 简化处理
    );
  }
}

/// 发表评论用的平台标识
enum ReplyPlatform {
  unkown,
  web,
  android,
  ios,
  wp,
}