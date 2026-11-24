import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets/sparkle.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  /// Wide enough for the four tabs, so the bar floats rather than spanning
  /// a wide screen.
  static const _maxWidth = 440.0;

  static const _tabs = [
    (icon: Icons.auto_awesome, label: 'Home'),
    (icon: Icons.school, label: 'Practice'),
    (icon: Icons.style, label: 'Deck'),
    (icon: Icons.insights, label: 'Statistics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final selected = navigationShell.currentIndex == index;
                  return Expanded(
                    child: _NavItem(
                      icon: _tabs[index].icon,
                      label: _tabs[index].label,
                      selected: selected,
                      onTap: () => navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.periwinkle : AppColors.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.raised : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The selected tab's icon gets a twinkle twirling in at its
            // corner, like belle.fyi's nav links.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: color),
                Positioned(
                  right: -9,
                  top: -5,
                  child: TwirlInSparkle(shown: selected),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.body(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
