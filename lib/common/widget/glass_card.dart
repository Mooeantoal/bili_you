import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// 液态玻璃卡片组件
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double? blurAmount;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.blurAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: LiquidGlassRenderer(
        borderRadius: BorderRadius.circular(borderRadius),
        backgroundColor: backgroundColor ??
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
        blurAmount: blurAmount ?? 20.0,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}