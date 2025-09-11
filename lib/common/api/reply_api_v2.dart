import 'dart:developer';

import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:dio/dio.dart';

/// 基于B站官方API文档的评论API
/// 参考：https://socialsisteryi.github.io/bilibili-API-collect/docs/comment/
class ReplyApiV2 {
  /// 获取评论区明细（翻页加载）
  /// 
  /// 参数：
  /// - [type] 评论区类型代码（1:视频稿件, 2:话题, 11:相簿, 12:专栏, 17:动态等）
  /// - [oid] 目标评论区id（对于视频是avid）
  /// - [sort] 排序方式 (0:按时间, 1:按点赞数, 2:按回复数)
  /// - [nohot] 是否不显示热评 (0:显示, 1:不显示)
  /// - [ps] 每页项数 (1-20，建议使用20)
  /// - [pn] 页码 (从1开始)
  /// 
  /// 注意：API符合B站官方文档规范
  static Future<CommentPageData> getComments({
    required int type,
    required String oid,
    int sort = 1, // 默认按点赞数排序
    int nohot = 0, // 默认显示热评
    int ps = 20, // 默认每页20条
    int pn = 1, // 默认第1页
  }) async {
    // 参数验证
    if (ps < 1 || ps > 20) {
      throw ArgumentError('每页项数ps必须在1-20范围内，当前值: $ps');
    }
    if (pn < 1) {
      throw ArgumentError('页码pn必须大于0，当前值: $pn');
    }
    if (sort < 0 || sort > 2) {
      throw ArgumentError('排序方式sort必须在0-2范围内，当前值: $sort');
    }
    if (nohot < 0 || nohot > 1) {
      throw ArgumentError('热评参数nohot必须为0或1，当前值: $nohot');
    }
    
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        log('获取评论: type=$type, oid=$oid, sort=$sort, ps=$ps, pn=$pn (尝试 ${retryCount + 1}/$maxRetries)');
        
        var response = await HttpUtils().get(
          ApiConstants.reply,
          queryParameters: {
            'type': type,
            'oid': oid,
            'sort': sort,
            'nohot': nohot,
            'ps': ps,
            'pn': pn,
          },
          options: Options(
            headers: {
              'user-agent': ApiConstants.userAgent,
              'referer': ApiConstants.bilibiliBase,
            },
          ),
        );

        log('评论API响应状态: ${response.statusCode}');
        
        if (response.data == null) {
          throw Exception('评论API返回数据为空');
        }

        if (response.data['code'] != 0) {
          String errorMsg = response.data['message'] ?? '未知错误';
          int errorCode = response.data['code'] ?? -1;
          
          // 特殊错误码处理
          switch (errorCode) {
            case -404:
              throw Exception('评论区不存在或已关闭，请尝试刷新或使用网页版评论区');
            case -403:
              throw Exception('评论区访问被限制，请登录后重试');
            case -400:
              throw Exception('请求参数错误，请检查视频是否存在');
            case 12002:
              throw Exception('评论区已关闭');
            case 12009:
              throw Exception('评论区需要登录后查看');
            default:
              throw Exception('获取评论失败: $errorMsg (code: $errorCode)');
          }
        }

        var data = response.data['data'];
        if (data == null) {
          log('评论数据为空，返回空结果');
          return CommentPageData.empty();
        }

        log('评论获取成功: 条数=${(data['replies'] as List?)?.length ?? 0}, 热评=${(data['hots'] as List?)?.length ?? 0}');
        return CommentPageData.fromJson(data);
        
      } catch (e) {
        retryCount++;
        log('获取评论区数据失败 (尝试 $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          // 最后一次尝试失败，抛出更友好的错误信息
          if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
            throw Exception('网络连接失败，请检查网络连接');
          } else if (e.toString().contains('code:')) {
            rethrow; // 保持原始错误信息
          } else {
            throw Exception('评论加载失败，请稍后重试');
          }
        }
        
        // 等待一段时间后重试
        await Future.delayed(Duration(milliseconds: 1000 * retryCount));
      }
    }
    
    // 这里不会执行到，但为了类型安全
    return CommentPageData.empty();
  }

  /// 获取评论回复（楼中楼）
  /// 
  /// 参数：
  /// - [type] 评论区类型代码
  /// - [oid] 目标评论区id
  /// - [root] 根评论rpid
  /// - [ps] 每页项数
  /// - [pn] 页码
  static Future<CommentReplyData> getCommentReplies({
    required int type,
    required String oid,
    required int root,
    int ps = 20,
    int pn = 1,
  }) async {
    try {
      var response = await HttpUtils().get(
        ApiConstants.replyReply,
        queryParameters: {
          'type': type,
          'oid': oid,
          'root': root,
          'ps': ps,
          'pn': pn,
        },
        options: Options(
          headers: {
            'user-agent': ApiConstants.userAgent,
            'referer': ApiConstants.bilibiliBase,
          },
        ),
      );

      if (response.data['code'] != 0) {
        throw Exception('获取评论回复失败: ${response.data['message']}');
      }

      var data = response.data['data'];
      if (data == null) {
        return CommentReplyData.empty();
      }

      return CommentReplyData.fromJson(data);
    } catch (e) {
      log('获取评论回复失败: $e');
      rethrow;
    }
  }
}

/// 评论页面数据
class CommentPageData {
  final PageInfo page;
  final ConfigInfo config;
  final List<CommentItem> replies;
  final List<CommentItem> hots;
  final UpperInfo? upper;

  CommentPageData({
    required this.page,
    required this.config,
    required this.replies,
    required this.hots,
    this.upper,
  });

  factory CommentPageData.fromJson(Map<String, dynamic> json) {
    return CommentPageData(
      page: PageInfo.fromJson(json['page'] ?? {}),
      config: ConfigInfo.fromJson(json['config'] ?? {}),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e))
              .toList() ??
          [],
      hots: (json['hots'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e))
              .toList() ??
          [],
      upper: json['upper'] != null ? UpperInfo.fromJson(json['upper']) : null,
    );
  }

  factory CommentPageData.empty() {
    return CommentPageData(
      page: PageInfo.empty(),
      config: ConfigInfo.empty(),
      replies: [],
      hots: [],
    );
  }
}

/// 评论回复数据
class CommentReplyData {
  final PageInfo page;
  final CommentItem? root;
  final List<CommentItem> replies;
  final UpperInfo? upper;

  CommentReplyData({
    required this.page,
    this.root,
    required this.replies,
    this.upper,
  });

  factory CommentReplyData.fromJson(Map<String, dynamic> json) {
    return CommentReplyData(
      page: PageInfo.fromJson(json['page'] ?? {}),
      root: json['root'] != null ? CommentItem.fromJson(json['root']) : null,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e))
              .toList() ??
          [],
      upper: json['upper'] != null ? UpperInfo.fromJson(json['upper']) : null,
    );
  }

  factory CommentReplyData.empty() {
    return CommentReplyData(
      page: PageInfo.empty(),
      replies: [],
    );
  }
}

/// 页面信息
class PageInfo {
  final int num; // 当前页码
  final int size; // 每页项数
  final int count; // 根评论条数
  final int acount; // 总计评论条数

  PageInfo({
    required this.num,
    required this.size,
    required this.count,
    required this.acount,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      num: json['num'] ?? 1,
      size: json['size'] ?? 20,
      count: json['count'] ?? 0,
      acount: json['acount'] ?? 0,
    );
  }

  factory PageInfo.empty() {
    return PageInfo(num: 1, size: 20, count: 0, acount: 0);
  }
}

/// 评论区配置信息
class ConfigInfo {
  final bool showAdmin;
  final bool showEntry;
  final bool showFloor;
  final bool showTopic;
  final bool showUpFlag;
  final bool readOnly;
  final bool showDelLog;

  ConfigInfo({
    required this.showAdmin,
    required this.showEntry,
    required this.showFloor,
    required this.showTopic,
    required this.showUpFlag,
    required this.readOnly,
    required this.showDelLog,
  });

  factory ConfigInfo.fromJson(Map<String, dynamic> json) {
    return ConfigInfo(
      showAdmin: json['showadmin'] == 1,
      showEntry: json['showentry'] == 1,
      showFloor: json['showfloor'] == 1,
      showTopic: json['showtopic'] == 1,
      showUpFlag: json['show_up_flag'] == true,
      readOnly: json['read_only'] == true,
      showDelLog: json['show_del_log'] == true,
    );
  }

  factory ConfigInfo.empty() {
    return ConfigInfo(
      showAdmin: false,
      showEntry: false,
      showFloor: false,
      showTopic: false,
      showUpFlag: false,
      readOnly: false,
      showDelLog: false,
    );
  }
}

/// UP主信息
class UpperInfo {
  final int mid;
  final CommentItem? top; // 置顶评论

  UpperInfo({
    required this.mid,
    this.top,
  });

  factory UpperInfo.fromJson(Map<String, dynamic> json) {
    return UpperInfo(
      mid: json['mid'] ?? 0,
      top: json['top'] != null ? CommentItem.fromJson(json['top']) : null,
    );
  }
}

/// 评论条目
class CommentItem {
  final int rpid; // 评论ID
  final int oid; // 评论区对象ID
  final int type; // 评论区类型代码
  final int mid; // 发送者mid
  final int root; // 根评论rpid
  final int parent; // 回复父评论rpid
  final int dialog; // 回复对方rpid
  final int count; // 二级评论条数
  final int rcount; // 回复评论条数
  final int floor; // 评论楼层号
  final int state; // 评论状态
  final int ctime; // 评论发送时间
  final int like; // 评论获赞数
  final int action; // 当前用户操作状态 (0:无, 1:已点赞, 2:已点踩)
  final bool invisible; // 评论是否被隐藏
  
  final CommentMember member; // 评论发送者信息
  final CommentContent content; // 评论内容信息
  final List<CommentItem> replies; // 评论回复预览

  CommentItem({
    required this.rpid,
    required this.oid,
    required this.type,
    required this.mid,
    required this.root,
    required this.parent,
    required this.dialog,
    required this.count,
    required this.rcount,
    required this.floor,
    required this.state,
    required this.ctime,
    required this.like,
    required this.action,
    required this.invisible,
    required this.member,
    required this.content,
    required this.replies,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      rpid: json['rpid'] ?? 0,
      oid: json['oid'] ?? 0,
      type: json['type'] ?? 0,
      mid: json['mid'] ?? 0,
      root: json['root'] ?? 0,
      parent: json['parent'] ?? 0,
      dialog: json['dialog'] ?? 0,
      count: json['count'] ?? 0,
      rcount: json['rcount'] ?? 0,
      floor: json['floor'] ?? 0,
      state: json['state'] ?? 0,
      ctime: json['ctime'] ?? 0,
      like: json['like'] ?? 0,
      action: json['action'] ?? 0,
      invisible: json['invisible'] == true,
      member: CommentMember.fromJson(json['member'] ?? {}),
      content: CommentContent.fromJson(json['content'] ?? {}),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// 评论发送者信息
class CommentMember {
  final String mid;
  final String uname; // 昵称
  final String sex; // 性别
  final String sign; // 签名
  final String avatar; // 头像URL
  final LevelInfo levelInfo; // 等级信息
  final VipInfo vip; // 会员信息
  final OfficialVerifyInfo officialVerify; // 认证信息

  CommentMember({
    required this.mid,
    required this.uname,
    required this.sex,
    required this.sign,
    required this.avatar,
    required this.levelInfo,
    required this.vip,
    required this.officialVerify,
  });

  factory CommentMember.fromJson(Map<String, dynamic> json) {
    return CommentMember(
      mid: json['mid']?.toString() ?? '0',
      uname: json['uname'] ?? '',
      sex: json['sex'] ?? '',
      sign: json['sign'] ?? '',
      avatar: json['avatar'] ?? '',
      levelInfo: LevelInfo.fromJson(json['level_info'] ?? {}),
      vip: VipInfo.fromJson(json['vip'] ?? {}),
      officialVerify: OfficialVerifyInfo.fromJson(json['official_verify'] ?? {}),
    );
  }
}

/// 用户等级信息
class LevelInfo {
  final int currentLevel;

  LevelInfo({required this.currentLevel});

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(currentLevel: json['current_level'] ?? 0);
  }
}

/// 会员信息
class VipInfo {
  final int vipType; // 大会员类型 (0:无, 1:月会员, 2:年以上会员)
  final int vipStatus; // 大会员状态 (0:无, 1:有)
  final String nicknameColor; // 昵称颜色

  VipInfo({
    required this.vipType,
    required this.vipStatus,
    required this.nicknameColor,
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) {
    return VipInfo(
      vipType: json['vipType'] ?? 0,
      vipStatus: json['vipStatus'] ?? 0,
      nicknameColor: json['nickname_color'] ?? '',
    );
  }
}

/// 认证信息
class OfficialVerifyInfo {
  final int type; // 认证类型 (-1:无, 0:个人认证, 1:机构认证)
  final String desc; // 认证信息

  OfficialVerifyInfo({
    required this.type,
    required this.desc,
  });

  factory OfficialVerifyInfo.fromJson(Map<String, dynamic> json) {
    return OfficialVerifyInfo(
      type: json['type'] ?? -1,
      desc: json['desc'] ?? '',
    );
  }
}

/// 评论内容信息
class CommentContent {
  final String message; // 评论内容
  final int plat; // 评论发送端 (1:web, 2:android, 3:ios, 4:wp)
  final String device; // 评论发送平台设备
  final List<CommentMember> members; // at到的用户信息
  final Map<String, EmoteInfo> emote; // 表情转义
  final int maxLine; // 收起最大行数

  CommentContent({
    required this.message,
    required this.plat,
    required this.device,
    required this.members,
    required this.emote,
    required this.maxLine,
  });

  factory CommentContent.fromJson(Map<String, dynamic> json) {
    // 解析表情
    Map<String, EmoteInfo> emotes = {};
    if (json['emote'] != null) {
      Map<String, dynamic> emoteMap = json['emote'];
      emoteMap.forEach((key, value) {
        emotes[key] = EmoteInfo.fromJson(value);
      });
    }

    return CommentContent(
      message: json['message'] ?? '',
      plat: json['plat'] ?? 0,
      device: json['device'] ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => CommentMember.fromJson(e))
              .toList() ??
          [],
      emote: emotes,
      maxLine: json['max_line'] ?? 6,
    );
  }
}

/// 表情信息
class EmoteInfo {
  final int id;
  final String text; // 表情转义符
  final String url; // 表情图片URL
  final String jumpTitle; // 表情名称
  final int type; // 表情类型 (1:免费, 2:会员专属, 3:购买所得, 4:颜文字)

  EmoteInfo({
    required this.id,
    required this.text,
    required this.url,
    required this.jumpTitle,
    required this.type,
  });

  factory EmoteInfo.fromJson(Map<String, dynamic> json) {
    return EmoteInfo(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      url: json['url'] ?? '',
      jumpTitle: json['jump_title'] ?? '',
      type: json['type'] ?? 1,
    );
  }
}