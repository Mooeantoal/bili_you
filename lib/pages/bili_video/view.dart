import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';
import 'package:bili_you/common/widget/video_audio_player.dart';
/// 临时 BiliVideoPage
/// 注意：视频和评论都是占位 UI
class BiliVideoPage extends StatefulWidget {
  const BiliVideoPage({super.key, required this.bvid, required this.cid, this.isBangumi = false, this.ssid, this.progress});
  final String bvid;
  final int cid;
  final int? ssid;
  final bool isBangumi;
  final int? progress;

  @override
  State<BiliVideoPage> createState() => _BiliVideoPageState();
}

class _BiliVideoPageState extends State<BiliVideoPage> with WidgetsBindingObserver {
  late BiliVideoController controller;

  @override
  void initState() {
    controller = Get.put(
      BiliVideoController(
        bvid: widget.bvid,
        cid: widget.cid,
        isBangumi: widget.isBangumi,
        progress: widget.progress,
        ssid: widget.ssid,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose(); // 占位释放
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 视频占位
          VideoAudioPlayer(controller.biliVideoPlayerController),
          // 简介和评论占位
          Expanded(
            child: Column(
              children: const [
                SizedBox(height: 20),
                Text("简介占位", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text("评论占位", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
