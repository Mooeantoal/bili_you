import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/floating_bottom_nav_bar.dart';

class FloatingNavbarTestPage extends StatefulWidget {
  const FloatingNavbarTestPage({Key? key}) : super(key: key);

  @override
  State<FloatingNavbarTestPage> createState() => _FloatingNavbarTestPageState();
}

class _FloatingNavbarTestPageState extends State<FloatingNavbarTestPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('悬浮导航栏测试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '悬浮式底部导航栏测试页面',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              '当前选中项: $_currentIndex',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BiliYouFloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}