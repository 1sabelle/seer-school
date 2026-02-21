import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class CardImageWidget extends StatelessWidget {
  final String assetPath;
  final String cardName;

  const CardImageWidget({
    super.key,
    required this.assetPath,
    required this.cardName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 360),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _PlaceholderCard(cardName: cardName);
          },
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  final String cardName;

  const _PlaceholderCard({required this.cardName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.agedInkBlue, AppColors.deepBurgundy],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mutedGold, width: 2),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            cardName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.parchment,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
