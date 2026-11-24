import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.lilac;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accent,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
