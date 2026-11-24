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
            ? AppColors.teal.withValues(alpha: 0.2)
            : AppColors.rose.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? AppColors.teal : AppColors.rose,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 18,
            color: isCorrect ? AppColors.teal : AppColors.rose,
          ),
          const SizedBox(width: 4),
          Text(
            isCorrect ? 'Correct' : 'Incorrect',
            style: TextStyle(
              color: isCorrect ? AppColors.teal : AppColors.rose,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
