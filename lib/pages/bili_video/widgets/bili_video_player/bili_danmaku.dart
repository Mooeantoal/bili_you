import 'dart:developer';

import 'package:bili_you/common/api/danmaku_api.dart';
import 'package:bili_you/common/models/network/proto/danmaku/danmaku.pb.dart';
import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/common/widget/player/base_player.dart';

import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:ns_danmaku/danmaku_controller.dart';
import 'package:ns_danmaku/danmaku_view.dart';
import 'package:ns_danmaku/models/danmaku_item.dart';
import 'package:ns_danmaku/models/danmaku_option.dart';

class BiliDanmaku extends StatefulWidget {
  const BiliDanmaku({super.key, required this.controller});

  final BiliDanmakuController controller;

  @override
  State<BiliDanmaku> createState() => _BiliDanmakuState();
}

class BiliDanmakuState extends State<BiliDanmaku> {
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
    }
    if (!isListenerLocked &&
        widget.controller._isInitialized &&
        widget.controller.isDanmakuOpened) {
      isListenerLocked = true;
      var currentPosition =
          (widget.controller.biliVideoPlayerController.position).inMilliseconds;
      if (widget.controller.currentSegmentIndex <
          widget.controller.dmSegList.length) {
        if (widget.controller.currentIndex <
            widget.controller.dmSegList[widget.controller.currentSegmentIndex]
                .elems.length) {
          var element = widget
              .controller
              .dmSegList[widget.controller.currentSegmentIndex]
              .elems[widget.controller.currentIndex];
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
        } else {
          //换下一节
          widget.controller.currentIndex = 0;
          widget.controller.currentSegmentIndex++;
        }
      }
      // updateWidget();
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
    super.initState();
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
      widget.controller.initDuration = box.maxWidth / 80;
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