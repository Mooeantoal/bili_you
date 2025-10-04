import 'package:flutter/material.dart';
import 'dart:ui'; // 导入用于毛玻璃效果的库

class TextTag extends StatelessWidget {
  final String text;

  const TextTag({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}