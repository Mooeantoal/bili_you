import 'package:flutter/material.dart';
import 'package:bili_you/pages/user_space/user_space_page.dart';

class UserSpaceTestPage extends StatefulWidget {
  const UserSpaceTestPage({Key? key, this.uid, this.mid}) : super(key: key);
  final String? uid; // 可选的UID参数
  final int? mid; // 可选的MID参数

  @override
  State<UserSpaceTestPage> createState() => _UserSpaceTestPageState();
}

class _UserSpaceTestPageState extends State<UserSpaceTestPage> {
  late String _uid; // 使用late关键字

  @override
  void initState() {
    super.initState();
    // 如果传入了uid参数，则使用它
    if (widget.uid != null) {
      _uid = widget.uid!;
    } 
    // 如果传入了mid参数，则转换为字符串使用
    else if (widget.mid != null) {
      _uid = widget.mid.toString();
    }
    // 否则使用默认值
    else {
      _uid = "316627722";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserSpacePage(uid: _uid),
    );
  }
}