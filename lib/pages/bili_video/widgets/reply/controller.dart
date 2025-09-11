import 'dart:developer';

import 'package:bili_you/common/api/reply_api.dart';
import 'package:bili_you/common/models/local/reply/reply_info.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:bili_you/pages/bili_video/widgets/reply/add_reply_util.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReplyController extends GetxController {
  ReplyController({
    required this.bvid,
    required this.replyType,
  });
  String bvid;
  late String tag;
  final ReplyType replyType;
  
  // WebView 控制器
  late WebViewController webViewController;
  
  // 兼容性属性 - 为了保持与旧代码的兼容性
  late EasyRefreshController refreshController;
  late ScrollController scrollController;

  @override
  void onInit() {
    tag = "ReplyPage:$bvid";
    
    // 初始化控制器
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    scrollController = ScrollController();
    
    // 初始化 WebView 控制器
    webViewController = WebViewController()
      ..setUserAgent(
          'Mozilla/5.0 (iPhone13,3; U; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/15E148 Safari/602.1')
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    
    super.onInit();
  }
  
  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  // 刷新评论页面
  void refreshComments() {
    String url;
    if (replyType == ReplyType.video) {
      url = 'https://www.bilibili.com/video/$bvid/#reply';
    } else {
      url = 'https://www.bilibili.com/video/$bvid/#reply';
    }
    webViewController.loadRequest(Uri.parse(url));
  }
}
