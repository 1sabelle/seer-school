import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/statistics_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Title
              Text(
                'Seer School',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      letterSpacing: 1.2,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Learn the Tarot',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.agedInkBlue,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Quick stats
              _QuickStats(stats: stats),

              const SizedBox(height: 32),

              // Navigation buttons
              _NavButton(
                icon: Icons.auto_awesome,
                label: 'Practice',
                subtitle: 'Draw cards and test your knowledge',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: 12),
              _NavButton(
                icon: Icons.grid_view_rounded,
                label: 'Browse Deck',
                subtitle: 'Explore all 78 cards',
                onTap: () => context.go('/browse'),
              ),
              const SizedBox(height: 12),
              _NavButton(
                icon: Icons.insights_rounded,
                label: 'Statistics',
                subtitle: 'Track your learning progress',
                onTap: () => context.go('/statistics'),
              ),

              const Spacer(flex: 3),

              Text(
                'Illustrations by Pamela Colman Smith, 1909',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.agedInkBlue.withValues(alpha: 0.4),
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final dynamic stats;

  const _QuickStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalAttempts = stats.getTotalAttempts();
    if (totalAttempts == 0) return const SizedBox.shrink();

    final accuracy = stats.getOverallAccuracy();
    final cardsStudied = stats.getCardsStudied();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.mutedGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(
              label: 'Cards Studied', value: '$cardsStudied'),
          Container(
            height: 30,
            width: 1,
            color: AppColors.warmBeige,
          ),
          _StatColumn(
              label: 'Accuracy',
              value: '${(accuracy * 100).toStringAsFixed(0)}%'),
          Container(
            height: 30,
            width: 1,
            color: AppColors.warmBeige,
          ),
          _StatColumn(
              label: 'Attempts', value: '$totalAttempts'),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.mutedGold,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.agedInkBlue,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightParchment,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warmBeige),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.deepBurgundy, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    Text(
                      subtitle,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.agedInkBlue,
                              ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.agedInkBlue),
            ],
          ),
        ),
      ),
    );
  }
}
