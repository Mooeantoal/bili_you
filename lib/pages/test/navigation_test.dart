import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationTestPage extends StatelessWidget {
  const NavigationTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导航测试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '测试底部导航栏是否正确抬高',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              '底部安全区域高度: ${MediaQuery.of(context).padding.bottom}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        color: Colors.blue,
        height: 60 + MediaQuery.of(context).padding.bottom,
        child: const Center(
          child: Text(
            '底部导航栏',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}