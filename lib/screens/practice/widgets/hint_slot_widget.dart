import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../models/hint_category.dart';
import 'hint_picker_widget.dart';
import 'result_indicator.dart';

class HintSlotWidget extends StatefulWidget {
  final HintSlot hint;
  final int index;
  final ValueChanged<String> onSelect;
  final VoidCallback onReveal;

  const HintSlotWidget({
    super.key,
    required this.hint,
    required this.index,
    required this.onSelect,
    required this.onReveal,
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
    if (widget.hint.isRevealed) return;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightParchment,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.hint.isRevealed
              ? (widget.hint.isCorrect
                  ? AppColors.sageGreen.withValues(alpha: 0.5)
                  : AppColors.dustyRose.withValues(alpha: 0.5))
              : AppColors.warmBeige,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    widget.hint.category.displayLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.agedInkBlue,
                        ),
                  ),
                  const Spacer(),
                  if (widget.hint.isRevealed)
                    ResultIndicator(isCorrect: widget.hint.isCorrect)
                  else if (widget.hint.hasSelection) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mutedGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Selected',
                        style: TextStyle(
                          color: AppColors.mutedGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!widget.hint.isRevealed)
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

          // Expandable picker
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: AppColors.warmBeige, height: 1),
                  const SizedBox(height: 12),
                  HintPickerWidget(
                    options: widget.hint.options,
                    selectedKey: widget.hint.selectedAnswer,
                    isRevealed: widget.hint.isRevealed,
                    correctAnswer: widget.hint.correctAnswer,
                    onSelect: widget.onSelect,
                  ),
                  if (widget.hint.hasSelection && !widget.hint.isRevealed) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onReveal();
                        },
                        child: const Text('Reveal Answer'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Show correct answer when revealed and incorrect
          if (widget.hint.isRevealed && !widget.hint.isCorrect)
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
