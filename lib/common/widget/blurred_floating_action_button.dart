import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';

/// 带高斯模糊效果的悬浮按钮组件
class BlurredFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double blurSigma;
  final double borderRadius;

  const BlurredFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.blurSigma = 6.0,
    this.borderRadius = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }
}