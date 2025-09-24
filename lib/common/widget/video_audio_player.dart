import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bili_you/common/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoAudioPlayer extends StatefulWidget {
  const VideoAudioPlayer(this.controller,
      {super.key,
      this.width,
      this.height,
      this.asepectRatio,
      this.fit = BoxFit.contain});
  final VideoAudioController controller;
  final double? width;
  final double?
