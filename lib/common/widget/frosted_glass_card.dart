import 'package:flutter/material.dart';
import 'dart:ui';

/// 使用BackdropFilter实现的毛玻璃卡片组件
class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double blurSigma;

  const FrostedGlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.blurSigma = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}