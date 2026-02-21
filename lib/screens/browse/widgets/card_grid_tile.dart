import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/tarot_card.dart';

class CardGridTile extends StatelessWidget {
  final TarotCardDefinition card;
  final double? masteryScore;
  final VoidCallback onTap;

  const CardGridTile({
    super.key,
    required this.card,
    this.masteryScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      card.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.agedInkBlue,
                                AppColors.deepBurgundy,
                              ],
                            ),
                            border: Border.all(
                                color: AppColors.mutedGold, width: 1),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                card.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.parchment,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Mastery indicator
                    if (masteryScore != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _masteryColor(masteryScore!),
                            border: Border.all(
                                color: AppColors.parchment, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Color _masteryColor(double score) {
    if (score >= 0.8) return AppColors.sageGreen;
    if (score >= 0.5) return AppColors.mutedGold;
    return AppColors.dustyRose;
  }
}
