import 'package:flutter/material.dart';

class TextTag extends StatelessWidget {
  final String text;

  const TextTag({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 使用纯色背景替代模糊效果
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        // 添加轻微的阴影效果
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
