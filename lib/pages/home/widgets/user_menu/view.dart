import 'dart:io';

import 'package:bili_you/common/models/network/user_relations/user_relation_types.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/common/widget/cached_network_image.dart';
import 'package:bili_you/pages/about/about_page.dart';
import 'package:bili_you/pages/history/history_page.dart';
import 'package:bili_you/pages/login/qrcode_login/view.dart';
import 'package:bili_you/pages/login/web_login/view.dart';
import 'package:bili_you/pages/settings_page/settings_page.dart';
import 'package:bili_you/pages/relation/view.dart';
import 'package:bili_you/pages/mine/view.dart'; // 导入"我的"页面
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'index.dart';

class UserMenuPage extends GetView<UserMenuController> {
  const UserMenuPage({Key? key}) : super(key: key);

  // 主视图 - 改为直接跳转到"我的"页面
  Widget _buildView(context) {
    // 直接跳转到"我的"页面，而不是显示对话框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(GetPageRoute(
        page: () => const MinePage(),
      ));
    });
    
    // 在跳转前显示一个加载指示器
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserMenuController>(
      init: UserMenuController(),
      id: "user_face",
      builder: (_) {
        return _buildView(context);
      },
    );
  }
}

// 保持这个类以避免破坏其他引用，但将其功能改为跳转到"我的"页面
class UserMenuListTile extends StatelessWidget {
  const UserMenuListTile(
      {super.key, required this.icon, required this.title, this.onTap});
  final Function()? onTap;
  final Icon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 35, right: 35, top: 25, bottom: 25),
        child: Row(children: [
          icon,
          SizedBox(
            width: MediaQuery.of(context).size.width / 13,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          )
        ]),
      ),
    );
  }
}
