import 'package:flutter/material.dart';
import 'package:bili_you/pages/test/piliplus_comments_page.dart';

class CommentsTestPage extends StatelessWidget {
  const CommentsTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论测试页面'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PiliPlusCommentsPage(
                  videoUrl: 'https://www.bilibili.com/video/BV1xhmnYFEir/',
                ),
              ),
            );
          },
          child: const Text('打开PiliPlus评论页面'),
        ),
      ),
    );
  }
}