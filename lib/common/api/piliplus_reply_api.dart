import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/models/local/reply/reply_content.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/models/local/reply/reply_member.dart';
import 'package:bili_you/common/models/local/reply/reply_reply_info.dart';
import 'package:bili_you/common/models/local/reply/vip.dart';
import 'package:bili_you/common/models/network/reply/reply.dart' as reply_raw;
import 'package:bili_you/common/models/network/reply/reply_reply.dart'
    as reply_reply_raw;
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:bili_you/common/utils/index.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/local/reply/official_verify.dart';

class PiliPlusReplyApi {
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
      print('请求评论数据: oid=$oid, pn=$pageNum, type=${type.code}, sort=${sort.index}');
      
      // 使用UAPI提供的API获取评论
      final url = 'https://uapis.cn/api/v1/social/bilibili/replies'
          '?oid=$oid'
          '&sort=${sort.index}'
          '&ps=20'
          '&pn=$pageNum';
      
      print('发送请求到: $url');
      
      // 使用专门的Dio实例发送请求，避免baseUrl干扰
      final response = await _uapiDio.get(url);
      print('收到响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // 解析响应数据
        final data = response.data;
        print('收到评论数据: ${data.keys}');
        
        // 检查API返回的code字段
        if (data['code'] != 0) {
          // 根据错误代码提供更具体的错误信息
          final code = data['code'];
          final message = data['message'] ?? '未知错误';
          print('API返回错误: code=$code, message=$message');
          
          // 特别处理500错误
          if (code == 500) {
            throw "服务器内部错误，请稍后再试";
          } else if (code == 404) {
            throw "请求的资源不存在";
          } else if (code == 403) {
            throw "访问被拒绝，请检查权限设置";
          } else {
            throw "API错误: $message (code: $code)";
          }
        }
        
        if (data['data'] == null) {
          print('返回数据为空');
          return ReplyInfo.zero;
        }
        
        final replyData = data['data'];
        
        // 解析热门评论（仅第一页）
        List<ReplyItem> topReplies = [];
        if (pageNum == 1 && replyData['hots'] != null) {
          for (var hotComment in replyData['hots']) {
            topReplies.add(_parseReplyItem(hotComment));
          }
        }
        
        // 解析普通评论
        List<ReplyItem> replies = [];
        if (replyData['replies'] != null) {
          for (var comment in replyData['replies']) {
            replies.add(_parseReplyItem(comment));
          }
        }
        
        return ReplyInfo(
          replies: replies,
          topReplies: topReplies,
          upperMid: replyData['upper'] != null ? replyData['upper']['mid'] : 0,
          replyCount: replyData['page'] != null ? replyData['page']['count'] : 0,
        );
      } else {
        // 处理HTTP错误状态码
        print('HTTP错误: ${response.statusCode}');
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
      print('DioException: ${e.type}, 状态码: ${e.response?.statusCode}, 错误信息: ${e.message}');
      
      // 特别处理500错误
      if (e.response?.statusCode == 500) {
        throw "服务器内部错误，请稍后再试";
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout || 
                 e.type == DioExceptionType.sendTimeout) {
        throw "网络连接超时，请检查网络设置";
      } else {
        throw "网络请求失败，请稍后再试";
      }
    } catch (e) {
      print('获取评论时出错: $e');
      // 如果是字符串类型的错误，直接抛出
      if (e is String) {
        throw e;
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
      print('请求楼中楼评论数据: oid=$oid, root=$rootId, pn=$pageNum, ps=$pageSize');
      
      // 使用UAPI提供的API获取楼中楼评论
      final url = 'https://uapis.cn/api/v1/social/bilibili/replies'
          '?oid=$oid'
          '&root=$rootId'
          '&ps=$pageSize'
          '&pn=$pageNum';
      
      print('发送请求到: $url');
      
      // 使用专门的Dio实例发送请求，避免baseUrl干扰
      final response = await _uapiDio.get(url);
      print('收到响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // 解析响应数据
        final data = response.data;
        print('收到楼中楼评论数据: ${data.keys}');
        
        // 检查API返回的code字段
        if (data['code'] != 0) {
          // 根据错误代码提供更具体的错误信息
          final code = data['code'];
          final message = data['message'] ?? '未知错误';
          print('API返回错误: code=$code, message=$message');
          
          // 特别处理500错误
          if (code == 500) {
            throw "服务器内部错误，请稍后再试";
          } else if (code == 404) {
            throw "请求的资源不存在";
          } else if (code == 403) {
            throw "访问被拒绝，请检查权限设置";
          } else {
            throw "API错误: $message (code: $code)";
          }
        }
        
        if (data['data'] == null) {
          print('返回数据为空');
          return ReplyReplyInfo.zero;
        }
        
        final replyData = data['data'];
        
        // 解析楼中楼评论
        List<ReplyItem> replies = [];
        if (replyData['replies'] != null) {
          for (var reply in replyData['replies']) {
            replies.add(_parseReplyItem(reply));
          }
        }
        
        // 解析根评论（如果存在）
        ReplyItem rootReply = ReplyItem.zero;
        if (replyData['root'] != null) {
          rootReply = _parseReplyItem(replyData['root']);
        }
        
        return ReplyReplyInfo(
          replies: replies,
          rootReply: rootReply,
          upperMid: replyData['upper'] != null ? replyData['upper']['mid'] : 0,
          replyCount: replyData['page'] != null ? replyData['page']['count'] : 0,
        );
      } else {
        // 处理HTTP错误状态码
        print('HTTP错误: ${response.statusCode}');
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
      print('DioException: ${e.type}, 状态码: ${e.response?.statusCode}, 错误信息: ${e.message}');
      
      // 特别处理500错误
      if (e.response?.statusCode == 500) {
        throw "服务器内部错误，请稍后再试";
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout || 
                 e.type == DioExceptionType.sendTimeout) {
        throw "网络连接超时，请检查网络设置";
      } else {
        throw "网络请求失败，请稍后再试";
      }
    } catch (e) {
      print('获取楼中楼评论时出错: $e');
      // 如果是字符串类型的错误，直接抛出
      if (e is String) {
        throw e;
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