// lib/common/api/danmaku_api.dart

import 'dart:typed_data';

import 'package:bili_you/common/api/api_constants.dart';
import 'package:bili_you/common/models/network/proto/danmaku/danmaku.pb.dart';
import 'package:bili_you/common/utils/http_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// DanmakuApi：获取分段弹幕并在后台解析 protobuf
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

    // 发起 HTTP 请求，确保以 bytes 形式获取响应体
    final Response response = await HttpUtils().get(
      ApiConstants.danmaku,
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );

    // response.data 应该是 List<int> / Uint8List
    final Uint8List bytes;
    if (response.data is Uint8List) {
      bytes = response.data as Uint8List;
    } else if (response.data is List<int>) {
      bytes = Uint8List.fromList(response.data as List<int>);
    } else {
      throw Exception('unexpected response type: ${response.data.runtimeType}');
    }

    // 在后台 isolate 里解析 protobuf，避免阻塞 UI
    final DmSegMobileReply parsed =
        await compute(_parseDanmakuFromBytes, bytes);

    return parsed;
  }
}

/// 顶层函数，用于 compute 解析 protobuf（二进制 -> DmSegMobileReply）
DmSegMobileReply _parseDanmakuFromBytes(Uint8List bytes) {
  return DmSegMobileReply.fromBuffer(bytes);
}
