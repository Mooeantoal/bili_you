import 'dart:developer';
import 'dart:math' as math;

import 'package:bili_you/common/models/local/video/audio_play_item.dart';
import 'package:bili_you/common/models/local/video/video_play_item.dart';
import 'package:bili_you/common/utils/index.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:bili_you/common/widget/slider_dialog.dart';
import 'package:bili_you/common/widget/video_audio_player.dart';
import 'package:bili_you/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BiliVideoPlayerPanel extends StatefulWidget {
  const BiliVideoPlayerPanel(this.controller, {super.key});
  final BiliVideoPlayerPanelController controller;

  @override
  State<BiliVideoPlayerPanel> createState() => _BiliVideoPlayerPanelState();
}

class _BiliVideoPlayerPanelState extends State<BiliVideoPlayerPanel> {
  // Define color constants for the panel
  static const Color iconColor = Colors.white;
  static const Color textColor = Colors.white;

  GlobalKey danmakuCheckBoxKey = GlobalKey();
  GlobalKey playButtonKey = GlobalKey();
  GlobalKey sliderKey = GlobalKey();
  GlobalKey durationTextKey = GlobalKey();
  late double tempSpeed;
  bool isHorizontalGestureInProgress = false;
  bool isVerticalGestureInProgress = false;
  static const gestureEdgeDeadZone = 0.1;

  // Corrected function with explicit types for math.min
  var isInDeadZone = (double x, double bound) =>
      math.min(x, bound - x) < gestureEdgeDeadZone * bound;

  final panelDecoration = const BoxDecoration(boxShadow: [
    BoxShadow(color: Colors.black45, blurRadius: 15, spreadRadius: 5)
  ]);

  void playStateChangedCallback(VideoAudioState value) {
    widget.controller._isPlayerPlaying = value.isPlaying;
    widget.controller._isPlayerEnd = value.isEnd;
    widget.controller._isPlayerBuffering = value.isBuffering;
    if (playButtonKey.currentState?.mounted ?? false) {
      playButtonKey.currentState?.setState(() {});
    }
  }

  void playerListenerCallback() async {
    if (!widget.controller._isSliderDraging) {
      widget.controller._position =
          widget.controller._biliVideoPlayerController.position;
    }
    widget.controller._fartherestBuffed =
        widget.controller._biliVideoPlayerController.fartherestBuffered;
    if (sliderKey.currentState?.mounted ?? false) {
      sliderKey.currentState?.setState(() {});
    }
    if (durationTextKey.currentState?.mounted ?? false) {
      durationTextKey.currentState?.setState(() {});
    }
  }

  void toggleFullScreen() {
    if (widget.controller._biliVideoPlayerController.isFullScreen) {
      Navigator.of(context).pop();
    }
    widget.controller._biliVideoPlayerController.toggleFullScreen();
  }

  void toggleDanmaku() {
    widget.controller._biliVideoPlayerController.biliDanmakuController!
        .toggleDanmaku();
    if (SettingsUtil.getValue(SettingsStorageKeys.rememberDanmakuSwitch,
            defaultValue: false) ==
        true) {
      SettingsUtil.setValue(
          SettingsStorageKeys.defaultShowDanmaku,
          widget.controller._biliVideoPlayerController.biliDanmakuController!
              .isDanmakuOpened);
    }
    if (danmakuCheckBoxKey.currentState?.mounted ?? false) {
      danmakuCheckBoxKey.currentState!.setState(() {});
    }
  }

  @override
  void initState() {
    if (!widget.controller._isInitializedState) {
      widget.controller._isPlayerPlaying =
          widget.controller._biliVideoPlayerController.isPlaying;
      widget.controller._show = !widget.controller._isPlayerPlaying;
      widget.controller.asepectRatio =
          widget.controller._biliVideoPlayerController.videoAspectRatio;
    }
    widget.controller._isInitializedState = true;
    widget.controller._biliVideoPlayerController
        .addStateChangedListener(playStateChangedCallback);
    widget.controller._biliVideoPlayerController
        .addListener(playerListenerCallback);
    initControl();
    super.initState();
  }

  Future initControl() async {
    widget.controller._volume = await VolumeController().getVolume();
    widget.controller._brightness = await ScreenBrightness().current;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller._biliVideoPlayerController
        .removeStateChangedListener(playStateChangedCallback);
    widget.controller._biliVideoPlayerController
        .removeListener(playerListenerCallback);
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  List<Widget> buildVideoQualityTiles() {
    List<Widget> list = [];
    for (var i
        in widget.controller._biliVideoPlayerController.videoPlayInfo!.videos) {
      list.add(RadioListTile(
        title: Text(i.quality.description),
        subtitle: Text(i.codecs),
        value: i,
        groupValue: widget.controller._biliVideoPlayerController.videoPlayItem,
        onChanged: (value) {
          widget.controller._biliVideoPlayerController.changeVideoItem(value!);
          Navigator.of(context).pop();
        },
      ));
    }
    return list;
  }

  List<Widget> buildAudioQualityTiles() {
    List<Widget> list = [];
    for (var i
        in widget.controller._biliVideoPlayerController.videoPlayInfo!.audios) {
      list.add(RadioListTile(
        title: Text(i.quality.description),
        subtitle: Text(i.codecs),
        value: i,
        groupValue: widget.controller._biliVideoPlayerController.audioPlayItem,
        onChanged: (value) {
          widget.controller._biliVideoPlayerController.changeAudioItem(value!);
          Navigator.of(context).pop();
        },
      ));
    }
    return list;
  }

  List<Widget> buildPlaybackSpeedTiles() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0];
    return speeds
        .map((speed) => RadioListTile(
              title: Text('${speed}x'),
              value: speed,
              groupValue: widget.controller._biliVideoPlayerController.speed,
              onChanged: (value) {
                widget.controller._biliVideoPlayerController
                    .setPlayBackSpeed(value!);
                Navigator.of(context).pop();
              },
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              setState(() {
                widget.controller._show = !widget.controller._show;
              });
            },
            onHorizontalDragStart: (details) {
              if (!isVerticalGestureInProgress &&
                  !isInDeadZone(details.localPosition.dy,
                      MediaQuery.of(context).size.height)) {
                isHorizontalGestureInProgress = true;
                widget.controller._isSliderDraging = true;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (isHorizontalGestureInProgress) {
                var width = MediaQuery.of(context).size.width;
                var value = details.localPosition.dx / width;
                widget.controller._position = Duration(
                    milliseconds:
                        (value * widget.controller._duration.inMilliseconds)
                            .round());
                if (sliderKey.currentState?.mounted ?? false) {
                  sliderKey.currentState?.setState(() {});
                }
                if (durationTextKey.currentState?.mounted ?? false) {
                  durationTextKey.currentState?.setState(() {});
                }
              }
            },
            onHorizontalDragEnd: (details) {
              if (isHorizontalGestureInProgress) {
                isHorizontalGestureInProgress = false;
                widget.controller._isSliderDraging = false;
                widget.controller._biliVideoPlayerController
                    .seekTo(widget.controller._position);
              }
            },
            onVerticalDragStart: (details) {
              if (!isHorizontalGestureInProgress &&
                  isInDeadZone(details.localPosition.dx,
                      MediaQuery.of(context).size.width)) {
                isVerticalGestureInProgress = true;
                tempSpeed = widget.controller._biliVideoPlayerController.speed;
                widget.controller._biliVideoPlayerController
                    .setPlayBackSpeed(1.0);
              }
            },
            onVerticalDragUpdate: (details) async {
              if (isVerticalGestureInProgress) {
                var height = MediaQuery.of(context).size.height;
                var dy = details.delta.dy;
                if (details.localPosition.dx <
                    MediaQuery.of(context).size.width / 2) {
                  var brightness = widget.controller._brightness - dy / height;
                  brightness = brightness.clamp(0.0, 1.0);
                  widget.controller._brightness = brightness;
                  await ScreenBrightness().setScreenBrightness(brightness);
                  if (mounted) {
                    setState(() {});
                  }
                } else {
                  var volume = widget.controller._volume - dy / height;
                  volume = volume.clamp(0.0, 1.0);
                  widget.controller._volume = volume;
                  VolumeController().setVolume(volume);
                }
              }
            },
            onVerticalDragEnd: (details) {
              if (isVerticalGestureInProgress) {
                isVerticalGestureInProgress = false;
                widget.controller._biliVideoPlayerController
                    .setPlayBackSpeed(tempSpeed);
              }
            },
            child: Stack(
              children: [
                if (widget.controller._isPlayerEnd)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        widget.controller._biliVideoPlayerController
                            .seekTo(Duration.zero);
                        widget.controller._biliVideoPlayerController.play();
                      },
                      child: Container(
                        color: Colors.black,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.replay, color: Colors.white, size: 50),
                            SizedBox(height: 10),
                            Text("点击重新播放",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.controller._show)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    height: widget.controller._show ? 45 : 0,
                    child: Container(
                      decoration: panelDecoration,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: iconColor),
                            onPressed: () {
                              if (widget.controller._biliVideoPlayerController
                                  .isFullScreen) {
                                toggleFullScreen();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.picture_in_picture,
                                color: iconColor),
                            onPressed: () {
                              widget.controller._biliVideoPlayerController
                                  .enablePictureInPicture();
                            },
                          ),
                          IconButton(
                            key: danmakuCheckBoxKey,
                            icon: Icon(
                              widget.controller._biliVideoPlayerController
                                          .biliDanmakuController !=
                                      null
                                  ? widget
                                          .controller
                                          ._biliVideoPlayerController
                                          .biliDanmakuController!
                                          .isDanmakuOpened
                                      ? Icons.comment
                                      : Icons.comment_bank_outlined
                                  : Icons.comment_bank_outlined,
                              color: iconColor,
                            ),
                            onPressed: toggleDanmaku,
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: iconColor),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SafeArea(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.video_library),
                                      title: const Text("视频画质"),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: const Text("选择画质"),
                                                  content: SingleChildScrollView(
                                                    child: Column(
                                                      children:
                                                          buildVideoQualityTiles(),
                                                    ),
                                                  ),
                                                ));
                                      },
                                    ),
                                    if (widget
                                        .controller
                                        ._biliVideoPlayerController
                                        .videoPlayInfo!
                                        .audios
                                        .isNotEmpty)
                                      ListTile(
                                        leading: const Icon(Icons.music_note),
                                        title: const Text("音频音质"),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AlertDialog(
                                                    title: const Text("选择音质"),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children:
                                                            buildAudioQualityTiles(),
                                                      ),
                                                    ),
                                                  ));
                                        },
                                      ),
                                    ListTile(
                                      leading: const Icon(Icons.speed),
                                      title: const Text("播放速度"),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: const Text("播放速度"),
                                                  content: SingleChildScrollView(
                                                    child: Column(
                                                      children:
                                                          buildPlaybackSpeedTiles(),
                                                    ),
                                                  ),
                                                ));
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.fullscreen),
                                      title: const Text("全屏"),
                                      onTap: toggleFullScreen,
                                    ),
                                  ],
                                )),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.controller._show)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      height: widget.controller._show ? 60 : 0,
                      child: FrostedGlassCard(
                        borderRadius: 0,
                        blurSigma: 8.0,
                        backgroundColor: Colors.black.withOpacity(0.4),
                        child: Column(
                          children: [
                            _VideoProgressSlider(
                              key: sliderKey,
                              controller: widget.controller,
                            ),
                            Row(
                              children: [
                                _PlayButton(
                                  key: playButtonKey,
                                  controller: widget.controller,
                                ),
                                _DurationText(
                                  key: durationTextKey,
                                  controller: widget.controller,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    widget.controller._volume > 0
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                    color: iconColor,
                                  ),
                                  onPressed: () {
                                    if (widget.controller._volume > 0) {
                                      widget.controller._volume = 0;
                                      VolumeController().setVolume(0);
                                    } else {
                                      widget.controller._volume = 1.0;
                                      VolumeController().setVolume(1.0);
                                    }
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Slider(
                                    min: 0,
                                    max: 1,
                                    value: widget.controller._volume,
                                    onChanged: (value) {
                                      widget.controller._volume = value;
                                      VolumeController().setVolume(value);
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white30,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    widget.controller._biliVideoPlayerController
                                            .isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: iconColor,
                                  ),
                                  onPressed: toggleFullScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.controller._isPlayerBuffering)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        });
  }
}

class _VideoProgressSlider extends StatefulWidget {
  const _VideoProgressSlider({required this.controller, super.key});
  final BiliVideoPlayerPanelController controller;

  @override
  State<_VideoProgressSlider> createState() => _VideoProgressSliderState();
}

class _VideoProgressSliderState extends State<_VideoProgressSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0,
      max: widget.controller._duration.inMilliseconds.toDouble(),
      value: widget.controller._position.inMilliseconds.toDouble(),
      onChanged: (value) {
        if (mounted) {
          setState(() {
            widget.controller._position = Duration(milliseconds: value.round());
          });
        }
      },
      onChangeStart: (value) {
        widget.controller._isSliderDraging = true;
      },
      onChangeEnd: (value) {
        widget.controller._isSliderDraging = false;
        widget.controller._biliVideoPlayerController
            .seekTo(widget.controller._position);
      },
      activeColor: Colors.blue,
      inactiveColor: Colors.white30,
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.controller, super.key});
  final BiliVideoPlayerPanelController controller;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (widget.controller._isPlayerBuffering) {
      icon = const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      );
    } else if (widget.controller._isPlayerPlaying) {
      icon = const Icon(Icons.pause, color: _BiliVideoPlayerPanelState.iconColor);
    } else {
      icon = const Icon(Icons.play_arrow,
          color: _BiliVideoPlayerPanelState.iconColor);
    }
    return IconButton(
      icon: icon,
      onPressed: () {
        if (widget.controller._isPlayerPlaying) {
          widget.controller._biliVideoPlayerController.pause();
        } else {
          widget.controller._biliVideoPlayerController.play();
        }
      },
    );
  }
}

class _DurationText extends StatefulWidget {
  const _DurationText({required this.controller, super.key});
  final BiliVideoPlayerPanelController controller;

  @override
  State<_DurationText> createState() => _DurationTextState();
}

class _DurationTextState extends State<_DurationText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      '${_formatDuration(widget.controller._position)} / ${_formatDuration(widget.controller._duration)}',
      style: const TextStyle(
          color: _BiliVideoPlayerPanelState.textColor, fontSize: 12),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}

class BiliVideoPlayerPanelController extends ChangeNotifier {
  late final BiliVideoPlayerController _biliVideoPlayerController;
  late final Duration _duration;
  bool _show = true;
  bool _isPlayerPlaying = false;
  bool _isPlayerEnd = false;
  bool _isPlayerBuffering = false;
  bool _isSliderDraging = false;
  Duration _position = Duration.zero;
  Duration _fartherestBuffed = Duration.zero;
  double _volume = 1.0;
  double _brightness = 1.0;
  bool _isInitializedState = false;
  double? asepectRatio;

  BiliVideoPlayerPanelController({
    required BiliVideoPlayerController biliVideoPlayerController,
  })  : _biliVideoPlayerController = biliVideoPlayerController,
        _duration = biliVideoPlayerController.duration;
}