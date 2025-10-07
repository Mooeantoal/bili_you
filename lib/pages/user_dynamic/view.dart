import 'package:bili_you/pages/user_space/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDynamicPage extends StatefulWidget {
  const UserDynamicPage({super.key, required this.mid});
  final int mid;

  @override
  State<UserDynamicPage> createState() => _UserDynamicPageState();
}

class _UserDynamicPageState extends State<UserDynamicPage>
    with AutomaticKeepAliveClientMixin {
  late UserSpacePageController controller;

  @override
  void initState() {
    controller = Get.find<UserSpacePageController>(
      tag: "user_space:${widget.mid}",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Scaffold(
      body: Center(
        child: Text("用户动态页面（功能待完善）"),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}