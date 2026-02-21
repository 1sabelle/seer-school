import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/hint_category.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final Map<String, double> accuracyByCategory;

  const CategoryBreakdownWidget({
    super.key,
    required this.accuracyByCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (accuracyByCategory.isEmpty) return const SizedBox.shrink();

    final entries = accuracyByCategory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'By Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) {
          String displayLabel = entry.key;
          for (final cat in HintCategory.values) {
            if (cat.name == entry.key) {
              displayLabel = cat.displayLabel;
              break;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      '${(entry.value * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _accuracyColor(entry.value),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: AppColors.warmBeige,
                    valueColor: AlwaysStoppedAnimation(_accuracyColor(entry.value)),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppColors.sageGreen;
    if (accuracy >= 0.5) return AppColors.mutedGold;
    return AppColors.dustyRose;
  }
}
