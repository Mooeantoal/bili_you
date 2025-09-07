import 'dart:developer';

import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/add_reply_util.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReplyController extends GetxController {
  ReplyController({
    required this.bvid,
    required this.replyType,
  });
  String bvid;
  late String tag;
  final ReplyType replyType;

  @override
  void onInit() {
    tag = "ReplyPage:$bvid";
    super.onInit();
  }
}
