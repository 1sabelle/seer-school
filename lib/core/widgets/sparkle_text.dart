import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme.dart';
import 'rise_in.dart';
import 'sparkle.dart';

/// A section's heading in Lora, with a small lilac sparkle before it.
class SectionHeading extends StatelessWidget {
  final String text;

  const SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Sparkle(size: 10),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

/// A line between two sparkles that take turns twinkling, like belle.fyi's
/// mail link.
class TwinkleFramed extends StatelessWidget {
  final Widget child;
  final double sparkleSize;

  const TwinkleFramed({super.key, required this.child, this.sparkleSize = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TwinklingSparkle(size: sparkleSize),
        const SizedBox(width: 12),
        Flexible(child: child),
        const SizedBox(width: 12),
        TwinklingSparkle(size: sparkleSize, phase: 0.5),
      ],
    );
  }
}

/// What an empty page shows: a little constellation twinkling over a Lora
/// line, an explanation, and optionally what to do about it.
class StarryEmptyState extends StatelessWidget {
  final String title;
  final String body;
  final Widget? action;

  const StarryEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RiseIn(child: _Constellation()),
            const SizedBox(height: 24),
            RiseIn(
              delay: const Duration(milliseconds: 150),
              child: Text(
                title,
                style: AppTheme.display(fontSize: 26),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            RiseIn(
              delay: const Duration(milliseconds: 300),
              child: Text(
                body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 32),
              RiseIn(
                delay: const Duration(milliseconds: 450),
                child: action!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Constellation extends StatelessWidget {
  const _Constellation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 72,
      height: 64,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 12,
            child: TwinklingSparkle(size: 40, color: AppColors.cream),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: TwinklingSparkle(size: 14, phase: 0.5),
          ),
          Positioned(
            left: 2,
            bottom: 0,
            child: TwinklingSparkle(size: 10, phase: 0.25),
          ),
        ],
      ),
    );
  }
}
