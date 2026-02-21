import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      size: 64,
                      color: AppColors.warmBeige,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No data yet',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.agedInkBlue,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Practice some cards to see your progress here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.agedInkBlue,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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
                              ? AppColors.sageGreen
                              : AppColors.mutedGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          label: 'Cards Studied',
                          value: '$cardsStudied / 78',
                          icon: Icons.style_rounded,
                          accentColor: AppColors.agedInkBlue,
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
                          accentColor: AppColors.deepBurgundy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          label: 'Correct',
                          value:
                              '${stats.getAllStats().fold(0, (sum, s) => sum + s.correctCount)}',
                          icon: Icons.check_circle_outline,
                          accentColor: AppColors.sageGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Category breakdown
                  CategoryBreakdownWidget(accuracyByCategory: byCategory),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
