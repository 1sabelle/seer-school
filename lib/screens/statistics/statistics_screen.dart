import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/widgets/rise_in.dart';
import '../../core/widgets/sparkle_text.dart';
import '../../providers/statistics_providers.dart';
import 'widgets/stat_card_widget.dart';
import 'widgets/suit_breakdown_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsServiceProvider);
    final totalAttempts = stats.getTotalAttempts();
    final accuracy = stats.getOverallAccuracy();
    final cardsStudied = stats.getCardsStudied();
    final byCategory = stats.getAccuracyByCategory();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: totalAttempts == 0
          ? const StarryEmptyState(
              title: 'No data yet',
              body: 'Practice some cards to see your progress here.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCardWidget(
                          label: 'Overall Accuracy',
                          value: '${(accuracy * 100).toStringAsFixed(0)}%',
                          icon: Icons.gps_fixed_rounded,
                          accentColor: accuracy >= 0.7
                              ? AppColors.teal
                              : AppColors.periwinkle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          label: 'Cards Studied',
                          value: '$cardsStudied / 78',
                          icon: Icons.style_rounded,
                          accentColor: AppColors.lilac,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCardWidget(
                          label: 'Total Attempts',
                          value: '$totalAttempts',
                          icon: Icons.repeat_rounded,
                          accentColor: AppColors.cream,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          label: 'Correct',
                          value:
                              '${stats.getAllStats().fold(0, (sum, s) => sum + s.correctCount)}',
                          icon: Icons.check_circle_outline,
                          accentColor: AppColors.teal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Category breakdown
                  RiseIn(
                    delay: const Duration(milliseconds: 150),
                    child:
                        CategoryBreakdownWidget(accuracyByCategory: byCategory),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
