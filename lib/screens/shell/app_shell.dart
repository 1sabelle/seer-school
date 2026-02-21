import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        height: 72,
        backgroundColor: AppColors.deepBurgundy,
        indicatorColor: AppColors.mutedGold.withValues(alpha: 0.25),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome,
                color: AppColors.parchment.withValues(alpha: 0.6)),
            selectedIcon:
                const Icon(Icons.auto_awesome, color: AppColors.mutedGold),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school,
                color: AppColors.parchment.withValues(alpha: 0.6)),
            selectedIcon:
                const Icon(Icons.school, color: AppColors.mutedGold),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.style,
                color: AppColors.parchment.withValues(alpha: 0.6)),
            selectedIcon:
                const Icon(Icons.style, color: AppColors.mutedGold),
            label: 'Deck',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights,
                color: AppColors.parchment.withValues(alpha: 0.6)),
            selectedIcon:
                const Icon(Icons.insights, color: AppColors.mutedGold),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}
