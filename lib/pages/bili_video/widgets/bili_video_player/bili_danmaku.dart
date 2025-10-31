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
  
  // 假设 dmSegList 直接存储 DanmakuElem 对象
  final List<DanmakuElem> dmSegList = [];
  int currentSegmentIndex = 0;
  int currentIndex = 0;
  int segmentCount = 0;
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

  // 【修复1】添加了 toggleDanmaku 方法
  void toggleDanmaku() {
    _isDanmakuOpened = !_isDanmakuOpened;
    refreshDanmaku?.call();
    update();
  }

  // 【修复2】修正了 _findPositionIndex 的逻辑，不再访问 .elems
  void _findPositionIndex(int milliseconds) {
    for (int i = 0; i < dmSegList.length; i++) {
      if (dmSegList[i].progress >= milliseconds) {
        currentIndex = i;
        return;
      }
    }
    currentIndex = dmSegList.length;
  }

  Future<void> initDanmaku() async {
    if (_isInitialized) return;
    _isInitialized = true;
    dmSegList.clear();
    try {
      // 【修复3】TODO: 请根据您的实际情况修改获取 cid 的方式
      // final cid = biliVideoPlayerController.videoParams.cid; // 示例
      final cid = "YOUR_CID_HERE"; // 临时占位符，请替换

      // 【修复4】TODO: 请替换为正确的 API 调用方法
      // 假设 API 返回的是 List<DanmakuElem>
      final List<DanmakuElem>? danmakuData = await DanmakuApi.getDanmakuList(cid: cid); // 假设方法名是 getDanmakuList

      if (danmakuData != null) {
        dmSegList.addAll(danmakuData);
      }
    } catch (e) {
      log('弹幕加载失败: $e');
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

  // 【修复5】修正了 videoPlayerListenerCallback 的逻辑，不再访问 .elems
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
        widget.controller.currentSegmentIndex = 0;
        widget.controller.dmSegList.clear();
        widget.controller.segmentCount = 0;
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
      // 【修复6】将 double 转换为 int
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
