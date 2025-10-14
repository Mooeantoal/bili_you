import 'package:flutter/material.dart';
import 'package:bili_you/pages/user_space/user_space_page.dart';

class TestUserSpacePage extends StatelessWidget {
  const TestUserSpacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用一个测试UID，实际应用中应该从参数传入
    const String testUid = "2"; // B站官方账号UID
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试用户空间页面'),
      ),
      body: UserSpacePage(uid: testUid),
    );
  }
}