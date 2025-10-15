import 'package:flutter/material.dart';
import 'package:bili_you/pages/user_space/user_space_page.dart';

class UserSpaceTestPage extends StatefulWidget {
  const UserSpaceTestPage({Key? key, this.uid}) : super(key: key);
  final String? uid; // 可选的UID参数

  @override
  State<UserSpaceTestPage> createState() => _UserSpaceTestPageState();
}

class _UserSpaceTestPageState extends State<UserSpaceTestPage> {
  final TextEditingController _urlController = TextEditingController();
  late String _uid; // 使用late关键字

  @override
  void initState() {
    super.initState();
    // 如果传入了uid参数，则使用它，否则使用默认值
    _uid = widget.uid ?? "316627722";
  }

  // 从URL中提取UID
  String _extractUidFromUrl(String url) {
    // 处理类似 https://space.bilibili.com/123456 的URL
    final RegExp uidRegExp = RegExp(r'space\.bilibili\.com/(\d+)');
    final match = uidRegExp.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    }
    
    // 处理直接输入的UID
    final RegExp numberRegExp = RegExp(r'^\d+$');
    if (numberRegExp.hasMatch(url)) {
      return url;
    }
    
    // 如果都匹配不到，返回默认UID
    return "316627722";
  }

  void _navigateToUserSpace() {
    final input = _urlController.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        _uid = _extractUidFromUrl(input);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户空间测试页面'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // URL输入区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: '输入用户空间URL或UID，例如：https://space.bilibili.com/123456 或 123456',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _navigateToUserSpace,
                  child: const Text('跳转'),
                ),
              ],
            ),
          ),
          // 用户空间页面
          Expanded(
            child: UserSpacePage(uid: _uid),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}