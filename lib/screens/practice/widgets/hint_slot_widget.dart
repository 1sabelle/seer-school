import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/manuscript_frame_painter.dart';
import '../../../core/widgets/ornamental_divider.dart';
import '../../../models/hint_category.dart';
import 'hint_picker_widget.dart';
import 'result_indicator.dart';

class HintSlotWidget extends StatefulWidget {
  final HintSlot hint;
  final int index;
  final ValueChanged<String> onSelect;

  const HintSlotWidget({
    super.key,
    required this.hint,
    required this.index,
    required this.onSelect,
  });

  @override
  State<HintSlotWidget> createState() => _HintSlotWidgetState();
}

class _HintSlotWidgetState extends State<HintSlotWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hint.isRevealed
        ? (widget.hint.isCorrect
            ? AppColors.sageGreen.withValues(alpha: 0.5)
            : AppColors.dustyRose.withValues(alpha: 0.5))
        : AppColors.warmBeige;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightParchment,
            Color.lerp(AppColors.lightParchment, AppColors.parchment, 0.15)!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: ManuscriptFramePainter(color: borderColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _toggleExpand,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.hint.category.displayLabel,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.agedInkBlue,
                              letterSpacing: 0.8,
                              fontFeatures: [FontFeature.enable('smcp')],
                            ),
                      ),
                      const Spacer(),
                      if (widget.hint.isRevealed)
                        ResultIndicator(isCorrect: widget.hint.isCorrect),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.expand_more,
                          color: AppColors.agedInkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Expandable picker
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const OrnamentalDivider(color: AppColors.warmBeige),
                    const SizedBox(height: 6),
                    HintPickerWidget(
                      options: widget.hint.options,
                      selectedKey: widget.hint.selectedAnswer,
                      isRevealed: widget.hint.isRevealed,
                      correctAnswer: widget.hint.correctAnswer,
                      onSelect: widget.onSelect,
                    ),
                  ],
                ),
              ),
            ),

            // Show correct answer when revealed
            if (widget.hint.isRevealed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Correct: ${_getCorrectDisplayLabel()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.sageGreen,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getCorrectDisplayLabel() {
    final correct = widget.hint.options
        .where((o) => o.key == widget.hint.correctAnswer)
        .toList();
    if (correct.isNotEmpty) return correct.first.displayLabel;
    return widget.hint.correctAnswer;
  }
}
