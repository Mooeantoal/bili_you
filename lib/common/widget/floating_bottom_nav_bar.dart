import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class BiliYouFloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BiliYouFloatingBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingNavbar(
      items: [
        FloatingNavbarItem(icon: Icons.home_outlined, title: '首页'),
        FloatingNavbarItem(icon: Icons.star_border_outlined, title: '动态'),
        FloatingNavbarItem(icon: Icons.person_outline, title: '我的'),
        FloatingNavbarItem(icon: Icons.bug_report, title: '测试'),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      selectedBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      elevation: 10,
      borderRadius: 16,
      itemBorderRadius: 8,
    );
  }
}