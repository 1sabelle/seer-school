import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants.dart';
import '../../../models/hint_category.dart';

class HintPickerWidget extends StatelessWidget {
  final List<HintOption> options;
  final String? selectedKey;
  final bool isRevealed;
  final String correctAnswer;
  final ValueChanged<String> onSelect;

  const HintPickerWidget({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.isRevealed,
    required this.correctAnswer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final hasSymbols = options.any((o) => o.assetPath != null);

    if (hasSymbols) {
      return _buildSymbolPicker(context);
    }
    return _buildTextPicker(context);
  }

  Widget _buildSymbolPicker(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedKey == option.key;
        final isCorrectAnswer = option.key == correctAnswer;

        Color borderColor = AppColors.warmBeige;
        Color bgColor = AppColors.lightParchment;

        if (isRevealed) {
          if (isCorrectAnswer) {
            borderColor = AppColors.sageGreen;
            bgColor = AppColors.sageGreen.withValues(alpha: 0.1);
          } else if (isSelected && !isCorrectAnswer) {
            borderColor = AppColors.dustyRose;
            bgColor = AppColors.dustyRose.withValues(alpha: 0.1);
          }
        } else if (isSelected) {
          borderColor = AppColors.mutedGold;
          bgColor = AppColors.mutedGold.withValues(alpha: 0.1);
        }

        final iconColor = isRevealed && isCorrectAnswer
            ? AppColors.sageGreen
            : isRevealed && isSelected
                ? AppColors.dustyRose
                : isSelected
                    ? AppColors.mutedGold
                    : AppColors.agedInkBlue;

        return GestureDetector(
          onTap: isRevealed ? null : () => onSelect(option.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 88,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: option.assetPath != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SvgPicture.asset(
                          option.assetPath!,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.displayLabel,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      option.displayLabel,
                      style: TextStyle(
                        color: AppColors.darkBrown,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: options.map((option) {
        final isSelected = selectedKey == option.key;
        final isCorrectAnswer = option.key == correctAnswer;

        Color borderColor = AppColors.warmBeige;
        Color bgColor = AppColors.lightParchment;

        if (isRevealed) {
          if (isCorrectAnswer) {
            borderColor = AppColors.sageGreen;
            bgColor = AppColors.sageGreen.withValues(alpha: 0.1);
          } else if (isSelected && !isCorrectAnswer) {
            borderColor = AppColors.dustyRose;
            bgColor = AppColors.dustyRose.withValues(alpha: 0.1);
          }
        } else if (isSelected) {
          borderColor = AppColors.mutedGold;
          bgColor = AppColors.mutedGold.withValues(alpha: 0.1);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: isRevealed ? null : () => onSelect(option.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.displayLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ),
                  if (isRevealed && isCorrectAnswer)
                    const Icon(Icons.check_rounded,
                        color: AppColors.sageGreen, size: 20),
                  if (isRevealed && isSelected && !isCorrectAnswer)
                    const Icon(Icons.close_rounded,
                        color: AppColors.dustyRose, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
