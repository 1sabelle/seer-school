import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class ResultIndicator extends StatelessWidget {
  final bool isCorrect;

  const ResultIndicator({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.sageGreen.withValues(alpha: 0.2)
            : AppColors.dustyRose.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? AppColors.sageGreen : AppColors.dustyRose,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 18,
            color: isCorrect ? AppColors.sageGreen : AppColors.dustyRose,
          ),
          const SizedBox(width: 4),
          Text(
            isCorrect ? 'Correct' : 'Incorrect',
            style: TextStyle(
              color: isCorrect ? AppColors.sageGreen : AppColors.dustyRose,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
