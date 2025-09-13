import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// 使用 glassmorphism 实现的液态玻璃卡片组件
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double blur;
  final double opacity;
  final double border;

  const LiquidGlassCard({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 16.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.blur = 20.0,
    this.opacity = 0.2,
    this.border = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        blur: blur,
        opacity: opacity,
        border: border,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.05),
          ],
          stops: const [0.1, 1],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.5),
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.5),
          ],
        ),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}