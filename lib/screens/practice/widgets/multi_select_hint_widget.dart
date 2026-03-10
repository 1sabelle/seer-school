import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/hint_category.dart';

class MultiSelectHintWidget extends StatelessWidget {
  final List<HintOption> options;
  final Set<String> selectedKeys;
  final Set<String> correctKeys;
  final bool isRevealed;
  final ValueChanged<String> onToggle;
  final VoidCallback onConfirm;

  const MultiSelectHintWidget({
    super.key,
    required this.options,
    required this.selectedKeys,
    required this.correctKeys,
    required this.isRevealed,
    required this.onToggle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedKeys.contains(option.key);
            final isCorrectOption = correctKeys.contains(option.key);

            Color borderColor;
            Color bgColor;
            Color textColor;

            if (isRevealed) {
              if (isCorrectOption && isSelected) {
                // Correctly selected
                borderColor = AppColors.sageGreen;
                bgColor = AppColors.sageGreen.withValues(alpha: 0.15);
                textColor = AppColors.sageGreen;
              } else if (isCorrectOption && !isSelected) {
                // Missed — should have been selected
                borderColor = AppColors.mutedGold;
                bgColor = AppColors.mutedGold.withValues(alpha: 0.1);
                textColor = AppColors.mutedGold;
              } else if (!isCorrectOption && isSelected) {
                // Wrong — intruder selected
                borderColor = AppColors.dustyRose;
                bgColor = AppColors.dustyRose.withValues(alpha: 0.15);
                textColor = AppColors.dustyRose;
              } else {
                // Correctly avoided intruder
                borderColor = AppColors.warmBeige;
                bgColor = AppColors.lightParchment;
                textColor = AppColors.agedInkBlue.withValues(alpha: 0.4);
              }
            } else if (isSelected) {
              borderColor = AppColors.mutedGold;
              bgColor = AppColors.mutedGold.withValues(alpha: 0.12);
              textColor = AppColors.darkBrown;
            } else {
              borderColor = AppColors.warmBeige;
              bgColor = AppColors.lightParchment;
              textColor = AppColors.darkBrown;
            }

            return GestureDetector(
              onTap: isRevealed ? null : () => onToggle(option.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRevealed && isCorrectOption && isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_rounded,
                            size: 14, color: AppColors.sageGreen),
                      ),
                    if (isRevealed && !isCorrectOption && isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.close_rounded,
                            size: 14, color: AppColors.dustyRose),
                      ),
                    Text(
                      option.displayLabel,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (!isRevealed) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: selectedKeys.isEmpty ? null : onConfirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedKeys.isEmpty
                    ? AppColors.warmBeige
                    : AppColors.deepBurgundy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: selectedKeys.isEmpty
                        ? AppColors.agedInkBlue.withValues(alpha: 0.4)
                        : AppColors.parchment,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
