import 'dart:developer';

import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/video/part_info.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/common/widget/video_tile_item.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:bili_you/pages/user_contribute/view.dart';
import 'package:bili_you/pages/user_space/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserSpacePage extends StatefulWidget {
  const UserSpacePage({super.key, required this.mid}) : tag = "user_space:$mid";
  final int mid;
  final String tag;

  @override
  State<UserSpacePage> createState() => _UserSpacePageState();
}

class _UserSpacePageState extends State<UserSpacePage>
    with AutomaticKeepAliveClientMixin {
  late UserSpacePageController controller;
  @override
  void initState() {
    controller =
        Get.put(UserSpacePageController(mid: widget.mid), tag: widget.tag);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return UserContributePage(mid: widget.mid);
  }

  @override
  bool get wantKeepAlive => true;
}
