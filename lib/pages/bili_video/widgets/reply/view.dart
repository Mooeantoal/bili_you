import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'index.dart';

class ReplyPage extends StatefulWidget {
  const ReplyPage({
    Key? key,
    required this.replyId,
    required this.replyType,
  })  : tag = "ReplyPage:$replyId",
        super(key: key);
  final String replyId;
  final ReplyType replyType;
  final String tag;

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  _ReplyPageState();

  @override
  bool get wantKeepAlive => true;

  late ReplyController controller;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    controller = Get.put(
      ReplyController(
        bvid: widget.replyId,
        replyType: widget.replyType,
      ),
      tag: widget.tag,
    );
    
    // 加载评论页面
    _loadReplyPage();
  }

  void _loadReplyPage() async {
    String url;
    if (widget.replyType == ReplyType.video) {
      // 对于视频，使用BV号加载评论
      url = 'https://www.bilibili.com/video/${widget.replyId}/#reply';
    } else {
      // 其他类型保持原有逻辑或按需添加
      url = 'https://www.bilibili.com/video/${widget.replyId}/#reply';
    }
    
    controller.webViewController.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                "正在显示网页版评论区",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: WebViewWidget(
            controller: controller.webViewController,
          ),
        ),
      ],
    );
  }
}