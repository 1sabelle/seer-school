import 'package:flutter/material.dart';
import '../constants.dart';

/// Full-screen card image preview overlay.
///
/// Call [showCardPreview] to display it as a modal dialog.
void showCardPreview(
  BuildContext context, {
  required String assetPath,
  required String cardName,
  String? heroTag,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close card preview',
    barrierColor: AppColors.parchment.withValues(alpha: 0.92),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _CardPreviewOverlay(
        assetPath: assetPath,
        cardName: cardName,
        heroTag: heroTag,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _CardPreviewOverlay extends StatelessWidget {
  final String assetPath;
  final String cardName;
  final String? heroTag;

  const _CardPreviewOverlay({
    required this.assetPath,
    required this.cardName,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight =
        screenSize.height - padding.top - padding.bottom - 120;
    final availableWidth = (screenSize.width - 80).clamp(0.0, 360.0);
    const aspectRatio = 384.0 / 240.0;

    var cardWidth = availableWidth;
    var cardHeight = cardWidth * aspectRatio;
    if (cardHeight > availableHeight) {
      cardHeight = availableHeight;
      cardWidth = cardHeight / aspectRatio;
    }

    Widget imageWidget = Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.mutedGold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );

    if (heroTag != null) {
      imageWidget = Hero(tag: heroTag!, child: imageWidget);
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              const SizedBox(height: 16),
              Text(
                cardName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.darkBrown,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
