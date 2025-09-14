import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPlayer extends StatefulWidget {
  final String bvid;
  final double aspectRatio;

  const WebViewPlayer({
    super.key,
    required this.bvid,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<WebViewPlayer> createState() => _WebViewPlayerState();
}

class _WebViewPlayerState extends State<WebViewPlayer> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.bilibili.com/video/${widget.bvid}'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: WebViewWidget(controller: controller),
    );
  }
}