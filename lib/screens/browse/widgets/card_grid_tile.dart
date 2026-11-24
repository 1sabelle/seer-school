import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../models/tarot_card.dart';

class CardGridTile extends StatefulWidget {
  final TarotCardDefinition card;
  final double? masteryScore;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const CardGridTile({
    super.key,
    required this.card,
    this.masteryScore,
    this.isUnlocked = true,
    this.onTap,
  });

  /// The shape of the card images (500 by 864 pixels), so a face is shown
  /// whole rather than cropped to fit.
  static const _cardAspectRatio = 500 / 864;
  static const _nameGap = 4.0;
  static const _nameFontSize = 13.0;
  static const _nameLineHeight = 1.3;

  /// Every name gets room for two lines, so a long name never shrinks its
  /// card next to the others.
  static const _nameHeight = _nameFontSize * _nameLineHeight * 2;

  /// How tall a tile [width] wide is: the whole card plus its name.
  static double heightFor(double width) =>
      width / _cardAspectRatio + _nameGap + _nameHeight;

  @override
  State<CardGridTile> createState() => _CardGridTileState();
}

class _CardGridTileState extends State<CardGridTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: 0.03), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.03, end: -0.03), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.02), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 0.02, end: -0.01), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -0.01, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onLockedTap() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isUnlocked ? widget.onTap : _onLockedTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.rotate(angle: _shakeAnimation.value, child: child);
        },
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: CardGridTile._cardAspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                      // A faint card shape while the image loads
                      const ColoredBox(color: AppColors.raised),
                      if (widget.isUnlocked)
                        Image.asset(
                          widget.card.assetPath,
                          fit: BoxFit.contain,
                          frameBuilder: (context, image, frame, wasSyncLoaded) =>
                              _fadeInWhenLoaded(
                            ColoredBox(
                              color: AppColors.cardMargin,
                              child: image,
                            ),
                            frame,
                            wasSyncLoaded,
                          ),
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallback();
                          },
                        )
                      else
                        Image.asset(
                          'assets/cards/back.jpg',
                          fit: BoxFit.cover,
                          frameBuilder: (context, image, frame, wasSyncLoaded) =>
                              _fadeInWhenLoaded(image, frame, wasSyncLoaded),
                        ),
                      // Mastery indicator (only for unlocked cards)
                      if (widget.isUnlocked && widget.masteryScore != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _masteryColor(widget.masteryScore!),
                              border: Border.all(
                                color: AppColors.night,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: CardGridTile._nameGap),
            SizedBox(
              height: CardGridTile._nameHeight,
              child: Text(
                widget.card.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: CardGridTile._nameFontSize,
                  height: CardGridTile._nameLineHeight,
                  fontWeight: FontWeight.w500,
                  color: widget.isUnlocked
                      ? AppColors.periwinkle
                      : AppColors.periwinkle.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fades a card in once its image has decoded, so switching suits doesn't
  /// flash empty tiles. A card already in memory shows at once.
  Widget _fadeInWhenLoaded(Widget card, int? frame, bool wasSyncLoaded) {
    if (wasSyncLoaded) return card;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: card,
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.muted, AppColors.periwinkle],
        ),
        border: Border.all(color: AppColors.lilac, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            widget.card.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Color _masteryColor(double score) {
    if (score >= 0.8) return AppColors.teal;
    if (score >= 0.5) return AppColors.periwinkle;
    return AppColors.rose;
  }
}
