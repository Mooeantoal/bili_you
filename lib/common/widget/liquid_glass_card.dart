import 'package:flutter/material.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

/// 使用 oc_liquid_glass 实现的液态玻璃卡片组件
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double refractStrength;
  final double blurRadiusPx;
  final double specStrength;

  const LiquidGlassCard({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 16.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.refractStrength = -0.08,
    this.blurRadiusPx = 2.0,
    this.specStrength = 25.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: OCLiquidGlassGroup(
        settings: OCLiquidGlassSettings(
          refractStrength: refractStrength,
          blurRadiusPx: blurRadiusPx,
          specStrength: specStrength,
        ),
        child: OCLiquidGlass(
          width: width,
          height: height,
          borderRadius: borderRadius,
          color: color ?? Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Container(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}