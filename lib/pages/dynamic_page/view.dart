import 'package:flutter/material.dart';

class DynamicPage extends StatelessWidget {
  const DynamicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("动态页面"),
      ),
    );
  }
}