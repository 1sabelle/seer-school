import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme.dart';

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
    barrierColor: AppColors.night.withValues(alpha: 0.92),
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
    // The shape of the card images (500 by 864 pixels), so the whole card
    // shows rather than a crop of it.
    const aspectRatio = 864.0 / 500.0;

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
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lilac.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: AppColors.cardMargin,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
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
                style: AppTheme.display(fontSize: 26),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
