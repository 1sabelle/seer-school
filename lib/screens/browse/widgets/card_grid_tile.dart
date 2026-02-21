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
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: -0.03), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.02), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.02, end: -0.01), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.01, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
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
          return Transform.rotate(
            angle: _shakeAnimation.value,
            child: child,
          );
        },
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
                      if (widget.isUnlocked)
                        Image.asset(
                          widget.card.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallback();
                          },
                        )
                      else
                        Image.asset(
                          'assets/cards/back.jpg',
                          fit: BoxFit.cover,
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
              widget.isUnlocked ? widget.card.name : '????',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.isUnlocked
                        ? null
                        : AppColors.agedInkBlue.withValues(alpha: 0.4),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
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
        border: Border.all(color: AppColors.mutedGold, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            widget.card.name,
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
  }

  Color _masteryColor(double score) {
    if (score >= 0.8) return AppColors.sageGreen;
    if (score >= 0.5) return AppColors.mutedGold;
    return AppColors.dustyRose;
  }
}
