import 'package:bili_you/pages/user_space/full_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserSpacePage extends StatefulWidget {
  const UserSpacePage({super.key, required this.mid});
  final int mid;

  @override
  State<UserSpacePage> createState() => _UserSpacePageState();
}

class _UserSpacePageState extends State<UserSpacePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 使用功能更完整的用户空间页面
    return FullUserSpacePage(mid: widget.mid);
  }

  @override
  bool get wantKeepAlive => true;
}