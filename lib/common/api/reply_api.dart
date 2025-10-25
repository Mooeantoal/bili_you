import 'package:dio/dio.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/models/local/reply/reply_reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_content.dart';
import 'package:bili_you/common/models/local/reply/reply_member.dart';
import 'package:bili_you/common/models/local/reply/official_verify.dart';
import 'package:bili_you/common/models/local/reply/vip.dart';

class ReplyApi {
  // 创建一个专门用于UAPI请求的Dio实例
  static final Dio _uapiDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: Headers.jsonContentType,
  ));

  // 使用UAPI获取评论列表
  static Future<ReplyInfo> getReply({
    required String oid,
    required int pageNum,
    required ReplyType type,
    ReplySort sort = ReplySort.like,
  }) async {
    try {
      // 使用UAPI提供的API获取评论
      // 确保oid是数字字符串
      final cleanOid = oid.toString();
      final url = 'https://uapis.cn/api/v1/social/bilibili/replies'
          '?oid=$cleanOid'
          '&sort=${sort.index}'
          '&ps=20'
          '&pn=$pageNum';
      
      print('请求评论API: $url');

      // 使用专门的Dio实例发送请求，避免baseUrl干扰
      final response = await _uapiDio.get(url);

      if (response.statusCode == 200) {
        // 解析响应数据
        final data = response.data;

        // 检查API返回的code字段
        if (data['code'] != 0) {
          // 根据错误代码提供更具体的错误信息
          final code = data['code'];
          final message = data['message'] ?? '未知错误';

          // 特别处理常见错误
          if (code == 500) {
            throw "服务器内部错误，请稍后再试";
          } else if (code == 404) {
            throw "请求的资源不存在";
          } else if (code == 403) {
            throw "访问被拒绝，请检查权限设置";
          } else if (code == -404) {
            // B站特有的错误码，表示视频不存在或无评论
            throw "视频不存在或暂无评论";
          } else {
            throw "API错误: $message (code: $code)";
          }
        }

        if (data['data'] == null) {
          return ReplyInfo.zero;
        }

        final replyData = data['data'];

        // 解析热门评论（仅第一页）
        List<ReplyItem> topReplies = [];
        if (pageNum == 1 && replyData['hots'] != null) {
          // 检查hots字段是否为List类型
          if (replyData['hots'] is List) {
            for (var hotComment in replyData['hots']) {
              // 确保hotComment是Map类型
              if (hotComment is Map<String, dynamic>) {
                topReplies.add(_parseReplyItem(hotComment));
              }
            }
          }
        }

        // 解析普通评论
        List<ReplyItem> replies = [];
        if (replyData['replies'] != null) {
          // 检查replies字段是否为List类型
          if (replyData['replies'] is List) {
            for (var comment in replyData['replies']) {
              // 确保comment是Map类型
              if (comment is Map<String, dynamic>) {
                replies.add(_parseReplyItem(comment));
              }
            }
          }
        }

        // 解析up主mid
        int upperMid = 0;
        if (replyData['upper'] != null && replyData['upper'] is Map<String, dynamic>) {
          upperMid = replyData['upper']['mid'] is String 
              ? int.tryParse(replyData['upper']['mid']) ?? 0 
              : replyData['upper']['mid'] ?? 0;
        }

        // 解析评论总数
        int replyCount = 0;
        if (replyData['page'] != null && replyData['page'] is Map<String, dynamic>) {
          replyCount = replyData['page']['count'] ?? 0;
        }

        return ReplyInfo(
          replies: replies,
          topReplies: topReplies,
          upperMid: upperMid,
          replyCount: replyCount,
        );
      } else {
        // 处理HTTP错误状态码
        if (response.statusCode == 500) {
          throw "服务器内部错误，请稍后再试";
        } else if (response.statusCode == 404) {
          throw "请求的资源不存在";
        } else if (response.statusCode == 403) {
          throw "访问被拒绝，请检查权限设置";
        } else {
          throw "HTTP错误: ${response.statusCode}";
        }
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}, type: ${e.type}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      // 特别处理500错误
      if (e.response?.statusCode == 500) {
        throw "服务器内部错误，请稍后再试";
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout || 
                 e.type == DioExceptionType.sendTimeout) {
        throw "网络连接超时，请检查网络设置";
      } else if (e.type == DioExceptionType.badResponse) {
        throw "服务器响应格式错误，请稍后再试";
      } else {
        throw "网络请求失败，请稍后再试";
      }
    } catch (e) {
      print('Unexpected error: $e');
      // 如果是字符串类型的错误，直接抛出
      if (e is String) {
        rethrow;
      } else {
        throw "获取评论时发生未知错误: $e";
      }
    }
  }

  // 使用UAPI获取楼中楼评论
  static Future<ReplyReplyInfo> getReplyReply({
    required String oid,
    required int rootId,
    required int pageNum,
    int pageSize = 20,
  }) async {
    try {
      // 使用UAPI提供的API获取楼中楼评论
      // 确保oid是数字字符串
      final cleanOid = oid.toString();
      final url = 'https://uapis.cn/api/v1/social/bilibili/replies'
          '?oid=$cleanOid'
          '&root=$rootId'
          '&ps=$pageSize'
          '&pn=$pageNum';
      
      print('请求楼中楼评论API: $url');

      // 使用专门的Dio实例发送请求，避免baseUrl干扰
      final response = await _uapiDio.get(url);

      if (response.statusCode == 200) {
        // 解析响应数据
        final data = response.data;

        // 检查API返回的code字段
        if (data['code'] != 0) {
          // 根据错误代码提供更具体的错误信息
          final code = data['code'];
          final message = data['message'] ?? '未知错误';

          // 特别处理常见错误
          if (code == 500) {
            throw "服务器内部错误，请稍后再试";
          } else if (code == 404) {
            throw "请求的资源不存在";
          } else if (code == 403) {
            throw "访问被拒绝，请检查权限设置";
          } else if (code == -404) {
            // B站特有的错误码，表示评论不存在
            throw "评论不存在或已被删除";
          } else {
            throw "API错误: $message (code: $code)";
          }
        }

        if (data['data'] == null) {
          return ReplyReplyInfo.zero;
        }

        final replyData = data['data'];

        // 解析楼中楼评论
        List<ReplyItem> replies = [];
        if (replyData['replies'] != null) {
          // 检查replies字段是否为List类型
          if (replyData['replies'] is List) {
            for (var reply in replyData['replies']) {
              // 确保reply是Map类型
              if (reply is Map<String, dynamic>) {
                replies.add(_parseReplyItem(reply));
              }
            }
          }
        }

        // 解析根评论（如果存在）
        ReplyItem rootReply = ReplyItem.zero;
        if (replyData['root'] != null && replyData['root'] is Map<String, dynamic>) {
          rootReply = _parseReplyItem(replyData['root']);
        }

        // 解析up主mid
        int upperMid = 0;
        if (replyData['upper'] != null && replyData['upper'] is Map<String, dynamic>) {
          upperMid = replyData['upper']['mid'] is String 
              ? int.tryParse(replyData['upper']['mid']) ?? 0 
              : replyData['upper']['mid'] ?? 0;
        }

        // 解析评论总数
        int replyCount = 0;
        if (replyData['page'] != null && replyData['page'] is Map<String, dynamic>) {
          replyCount = replyData['page']['count'] ?? 0;
        }

        return ReplyReplyInfo(
          replies: replies,
          rootReply: rootReply,
          upperMid: upperMid,
          replyCount: replyCount,
        );
      } else {
        // 处理HTTP错误状态码
        if (response.statusCode == 500) {
          throw "服务器内部错误，请稍后再试";
        } else if (response.statusCode == 404) {
          throw "请求的资源不存在";
        } else if (response.statusCode == 403) {
          throw "访问被拒绝，请检查权限设置";
        } else {
          throw "HTTP错误: ${response.statusCode}";
        }
      }
    } on DioException catch (e) {
      print('DioException in getReplyReply: ${e.message}, type: ${e.type}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      // 特别处理500错误
      if (e.response?.statusCode == 500) {
        throw "服务器内部错误，请稍后再试";
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout || 
                 e.type == DioExceptionType.sendTimeout) {
        throw "网络连接超时，请检查网络设置";
      } else if (e.type == DioExceptionType.badResponse) {
        throw "服务器响应格式错误，请稍后再试";
      } else {
        throw "网络请求失败，请稍后再试";
      }
    } catch (e) {
      print('Unexpected error in getReplyReply: $e');
      // 如果是字符串类型的错误，直接抛出
      if (e is String) {
        rethrow;
      } else {
        throw "获取楼中楼评论时发生未知错误: $e";
      }
    }
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

enum ReplySort { time, like, reply }