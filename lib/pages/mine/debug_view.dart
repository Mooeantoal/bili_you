import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class DebugMinePage extends GetView<MineController> {
  const DebugMinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DebugMinePage build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的(调试版)"),
      ),
      body: Container(
        color: Colors.red.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '调试版个人页面',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Obx(() => Text(
                    '用户名: ${controller.name.value}',
                    style: const TextStyle(fontSize: 18),
                  )),
              Obx(() => Text(
                    '等级: ${controller.level.value}',
                    style: const TextStyle(fontSize: 18),
                  )),
              Obx(() => Text(
                    '是否登录: ${controller.islogin_.value}',
                    style: const TextStyle(fontSize: 18),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 重新初始化数据
                  controller.reloadData();
                },
                child: const Text('刷新数据'),
              ),
              const SizedBox(height: 20),
              const Text(
                '如果能看到这个页面，说明组件没有问题',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}