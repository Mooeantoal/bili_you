import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';

/// 带高斯模糊效果的侧边导航栏组件
class BlurredNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;

  const BlurredNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      borderRadius: 16.0,
      blurSigma: 8.0,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}