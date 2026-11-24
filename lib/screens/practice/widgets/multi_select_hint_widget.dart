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
                borderColor = AppColors.teal;
                bgColor = AppColors.teal.withValues(alpha: 0.15);
                textColor = AppColors.teal;
              } else if (isCorrectOption && !isSelected) {
                // Missed — should have been selected
                borderColor = AppColors.lilac;
                bgColor = AppColors.lilac.withValues(alpha: 0.1);
                textColor = AppColors.lilac;
              } else if (!isCorrectOption && isSelected) {
                // Wrong — intruder selected
                borderColor = AppColors.rose;
                bgColor = AppColors.rose.withValues(alpha: 0.15);
                textColor = AppColors.rose;
              } else {
                // Correctly avoided intruder
                borderColor = AppColors.border;
                bgColor = AppColors.navy;
                textColor = AppColors.muted.withValues(alpha: 0.4);
              }
            } else if (isSelected) {
              borderColor = AppColors.lilac;
              bgColor = AppColors.lilac.withValues(alpha: 0.12);
              textColor = AppColors.text;
            } else {
              borderColor = AppColors.border;
              bgColor = AppColors.navy;
              textColor = AppColors.text;
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
                            size: 14, color: AppColors.teal),
                      ),
                    if (isRevealed && !isCorrectOption && isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.close_rounded,
                            size: 14, color: AppColors.rose),
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
                    ? AppColors.border
                    : AppColors.periwinkle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: selectedKeys.isEmpty
                        ? AppColors.muted.withValues(alpha: 0.4)
                        : AppColors.onPeriwinkle,
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
