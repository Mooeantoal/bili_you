import 'dart:developer';

import 'package:bili_you/common/api/danmaku_api.dart';
import 'package:bili_you/common/models/network/proto/danmaku/danmaku.pb.dart';
import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/common/widget/player/base_player.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ns_danmaku/danmaku_controller.dart';
import 'package:ns_danmaku/danmaku_view.dart';
import 'package:ns_danmaku/models/danmaku_item.dart';
import 'package:ns_danmaku/models/danmaku_option.dart';

class BiliDanmakuController extends GetxController {
  BiliDanmakuController({required this.biliVideoPlayerController});

  final BiliVideoPlayerController biliVideoPlayerController;
  
  // dmSegList 现在是一个包含所有分段所有弹幕的扁平化列表
  final List<DanmakuElem> dmSegList = [];
  int currentIndex = 0;
  bool _isInitialized = false;
  bool _isInitializedState = false;
  bool _isDanmakuOpened = true;
  double fontScale = 1.0;
  double fontOpacity = 1.0;
  double speed = 1.0;
  int initDuration = 8000;

  bool get isDanmakuOpened => _isDanmakuOpened;
  bool get isInitialized => _isInitialized;

  VoidCallback? reloadDanmaku;
  VoidCallback? refreshDanmaku;

  void toggleDanmaku() {
    _isDanmakuOpened = !_isDanmakuOpened;
    refreshDanmaku?.call();
    update();
  }

  void _findPositionIndex(int milliseconds) {
    for (int i = 0; i < dmSegList.length; i++) {
      if (dmSegList[i].progress >= milliseconds) {
        currentIndex = i;
        return;
      }
    }
    currentIndex = dmSegList.length;
  }

  // 【最终修复】根据真实的 API 重写了 initDanmaku 方法
  Future<void> initDanmaku() async {
    if (_isInitialized) return;
    _isInitialized = true;
    dmSegList.clear();
    currentIndex = 0;

    try {
      // 【重要】TODO: 请根据您的实际情况修改获取 cid 的方式
      // 示例: final cid = biliVideoPlayerController.videoParams.cid;
      final cid = 123456789; // 临时占位符，请替换为真实的 cid

      // 弹幕是分段的，我们循环获取前几段
      // 对于一个10分钟的视频，通常有3-6段弹幕
      for (int i = 1; i <= 5; i++) {
        try {
          // 调用真实的 API 方法
          final DmSegMobileReply reply = await DanmakuApi.requestDanmaku(
            cid: cid,
            segmentIndex: i,
          );
          // 假设 DmSegMobileReply 有一个名为 elems 的字段，包含弹幕列表
          if (reply.elems.isNotEmpty) {
            dmSegList.addAll(reply.elems);
          } else {
            // 如果返回的段没有弹幕，可能已经到末尾了，可以停止加载
            break;
          }
        } catch (e) {
          // 如果某个段加载失败，可以记录日志并继续加载下一段
          log('加载第 $i 段弹幕失败: $e');
        }
      }
      log('共加载了 ${dmSegList.length} 条弹幕');
    } catch (e) {
      log('弹幕初始化失败: $e');
    }
  }
}

class BiliDanmaku extends StatefulWidget {
  const BiliDanmaku({super.key, required this.controller});

  final BiliDanmakuController controller;

  @override
  State<BiliDanmaku> createState() => _BiliDanmakuState();
}

class _BiliDanmakuState extends State<BiliDanmaku> {
  DanmakuController? danmakuController;
  bool isListenerLocked = false;
  bool isPlaying = true;

  void videoPlayerStateChangedCallback(PlayerStateModel value) {
    if (value.isBuffering || !value.isPlaying) {
      danmakuController?.pause();
    } else if (value.isPlaying) {
      danmakuController?.resume();
    }
  }

  void videoPlayerSeekToCallback(Duration position) {
    danmakuController?.clear();
    widget.controller._findPositionIndex(position.inMilliseconds);
  }

  void videoPlayerListenerCallback() {
    if (!widget.controller.isDanmakuOpened) {
      danmakuController?.clear();
      return;
    }
    if (!isListenerLocked &&
        widget.controller.isInitialized &&
        widget.controller.isDanmakuOpened) {
      isListenerLocked = true;
      var currentPosition =
          (widget.controller.biliVideoPlayerController.position).inMilliseconds;
      
      if (widget.controller.currentIndex < widget.controller.dmSegList.length) {
        var element = widget.controller.dmSegList[widget.controller.currentIndex];
        var delta = currentPosition - element.progress;
        if (delta >= 0 && delta < 200) {
          late DanmakuItemType type;
          if (element.mode >= 1 && element.mode <= 3) {
            type = DanmakuItemType.scroll;
          } else if (element.mode == 4) {
            type = DanmakuItemType.bottom;
          } else if (element.mode == 5) {
            type = DanmakuItemType.top;
          }
          danmakuController?.addItems([
            DanmakuItem(element.content,
                color: Color.fromARGB(255, (element.color << 8) >> 24,
                    (element.color << 16) >> 24, (element.color << 24) >> 24),
                time: element.progress,
                type: type)
          ]);
          widget.controller.currentIndex++;
        } else {
          widget.controller._findPositionIndex(widget
              .controller.biliVideoPlayerController.position.inMilliseconds);
        }
      }
      
      danmakuController?.updateOption(DanmakuOption(
          fontSize: 16 * widget.controller.fontScale,
          opacity: widget.controller.fontOpacity,
          area: 0.5,
          duration: widget.controller.initDuration /
              (widget.controller.biliVideoPlayerController.speed *
                  widget.controller.speed)));
      isListenerLocked = false;
    }
  }

  void addAllListeners() {
    var controller = widget.controller;
    controller.biliVideoPlayerController
        .addListener(videoPlayerListenerCallback);
    controller.biliVideoPlayerController
        .addStateChangedListener(videoPlayerStateChangedCallback);
    controller.biliVideoPlayerController
        .addSeekToListener(videoPlayerSeekToCallback);
  }

  void removeAllListeners() {
    var controller = widget.controller;
    controller.biliVideoPlayerController
        .removeListener(videoPlayerListenerCallback);
    controller.biliVideoPlayerController
        .removeSeekToListener(videoPlayerSeekToCallback);
    controller.biliVideoPlayerController
        .removeStateChangedListener(videoPlayerStateChangedCallback);
  }

  @override
  void initState() {
    super.initState();

    var controller = widget.controller;
    if (!controller._isInitializedState) {
      if (SettingsUtil.getValue(SettingsStorageKeys.defaultShowDanmaku,
          defaultValue: true)) {
        controller._isDanmakuOpened = true;
      } else {
        controller._isDanmakuOpened = false;
      }
      widget.controller.reloadDanmaku = () {
        widget.controller._isInitialized = false;
        widget.controller.currentIndex = 0;
        widget.controller.dmSegList.clear();
        if (mounted) {
          setState(() {});
        }
      };
      widget.controller.refreshDanmaku = () {
        if (mounted) setState(() {});
      };
    }
    widget.controller._isInitializedState = true;

    addAllListeners();
  }

  @override
  void dispose() {
    if (!widget.controller.biliVideoPlayerController.isFullScreen) {
      danmakuController?.clear();
      danmakuController = null;
    }
    removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      widget.controller.initDuration = (box.maxWidth / 80).toInt();
      return DanmakuView(
        createdController: (danmakuController) async {
          widget.controller.initDanmaku();
          this.danmakuController = danmakuController;
        },
        option: DanmakuOption(
            fontSize: 16 * widget.controller.fontScale,
            opacity: widget.controller.fontOpacity,
            area: 0.5,
            duration: widget.controller.initDuration /
                (widget.controller.biliVideoPlayerController.speed *
                    widget.controller.speed)),
        statusChanged: (isPlaying) {
          this.isPlaying = isPlaying;
        },
      );
    });
  }
}
