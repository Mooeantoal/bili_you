// lib/common/api/danmaku_api.dart

import 'dart:typed_data';
import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/models/network/proto/danmaku/danmaku.pb.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// DanmakuApi：获取分段弹幕并在后台解析 protobuf，同时支持发送弹幕
class DanmakuApi {
  /// 请求弹幕（返回解析好的 DmSegMobileReply）
  /// [type] 通常为 1
  /// [cid] 视频的 cid（oid）
  /// [segmentIndex] 分段索引（0,1,...）
  static Future<DmSegMobileReply> requestDanmaku({
    int type = 1,
    required int cid,
    required int segmentIndex,
  }) async {
    final query = <String, dynamic>{
      'type': type,
      'oid': cid,
      'segment_index': segmentIndex,
    };

    final Response response = await HttpUtils().get(
      ApiConstants.danmaku,
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );

    final Uint8List bytes;
    if (response.data is Uint8List) {
      bytes = response.data as Uint8List;
    } else if (response.data is List<int>) {
      bytes = Uint8List.fromList(response.data as List<int>);
    } else {
      throw Exception(
          'DanmakuApi: unexpected response type: ${response.data.runtimeType}');
    }

    return await compute(_parseDanmakuFromBytes, bytes);
  }

  /// 发送弹幕
  /// [mid] 用户ID
  /// [cid] 视频cid
  /// [playTime] 弹幕出现时间（秒）
  /// [color] 弹幕颜色 0xRRGGBB
  /// [msg] 弹幕文本
  /// [fontSize] 字号
  /// [mode] 弹幕模式，1=滚动，5=顶部，4=底部
  /// [accessKey] 登录用户token
  static Future<void> sendDanmaku({
    required int mid,
    required int cid,
    required double playTime,
    required int color,
    required String msg,
    int fontSize = 25,
    int mode = 1,
    required String accessKey,
  }) async {
    final data = {
      'type': 1,
      'oid': cid,
      'mid': mid,
      'msg': msg,
      'progress': (playTime * 1000).toInt(), // 毫秒
      'color': color,
      'fontsize': fontSize,
      'mode': mode,
      'rnd': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'access_key': accessKey,
    };

    try {
      await HttpUtils().post(
        ApiConstants.addReply, // 这里用 B站弹幕发送接口
        data: data,
      );
    } catch (e) {
      debugPrint('DanmakuApi send error: $e');
      rethrow;
    }
  }
}

/// 顶层函数，用于 compute 解析 protobuf（二进制 -> DmSegMobileReply）
DmSegMobileReply _parseDanmakuFromBytes(Uint8List bytes) {
  try {
    return DmSegMobileReply.fromBuffer(bytes);
  } catch (e) {
    debugPrint('DanmakuApi parse error: $e');
    return DmSegMobileReply(); // 返回空对象
  }
}
