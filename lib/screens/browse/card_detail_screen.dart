import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../models/hint_category.dart';
import '../../providers/card_providers.dart';
import '../../providers/deck_providers.dart';
import '../../providers/statistics_providers.dart';
import '../practice/widgets/card_image_widget.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(allCardsProvider);
    final card = cards.where((c) => c.id == cardId).firstOrNull;

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Card Detail')),
        body: const Center(child: Text('Card not found')),
      );
    }

    final statsService = ref.watch(statisticsServiceProvider);
    final cardStats = statsService.getStatsForCard(cardId);
    final unlockedCards = ref.watch(unlockedCardsProvider);
    final isUnlocked = unlockedCards.contains(cardId);

    return Scaffold(
      appBar: AppBar(title: Text(isUnlocked ? card.name : '???')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isUnlocked)
              CardImageWidget(
                assetPath: card.assetPath,
                cardName: card.name,
              )
            else
              CardImageWidget(
                assetPath: 'assets/cards/back.jpg',
                cardName: 'Locked',
              ),
            const SizedBox(height: 16),

            Text(
              isUnlocked ? card.name : '???',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            if (isUnlocked) ...[
              // Card info
              _InfoRow(label: 'Arcana', value: card.isMajor ? 'Major' : 'Minor'),
              if (card.suit != null)
                _InfoRow(label: 'Suit', value: card.suit!.name[0].toUpperCase() + card.suit!.name.substring(1)),
              if (card.element != null)
                _InfoRow(label: 'Element', value: card.element!.name[0].toUpperCase() + card.element!.name.substring(1)),
              if (card.numerologyKeyword != null)
                _InfoRow(label: 'Numerology', value: card.numerologyKeyword!.displayLabel),
              if (card.courtPersona != null)
                _InfoRow(label: 'Court Persona', value: card.courtPersona!.displayLabel),

              const SizedBox(height: 12),

              // Theme
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.mutedGold.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.agedInkBlue,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.theme,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Keywords
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: card.keywords
                    .map((k) => Chip(
                          label: Text(k),
                          backgroundColor: AppColors.warmBeige,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),

              // Statistics
              if (cardStats.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Your Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ...cardStats.map((stat) {
                  return _StatRow(
                    label: stat.hintCategory,
                    accuracy: stat.accuracy,
                    attempts: stat.totalAttempts,
                  );
                }),
              ],

              const SizedBox(height: 24),

              // Practice this card button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/practice/${card.id}'),
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  label: const Text('Practice This Card'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              Text(
                'Draw this card in your daily practice to unlock its secrets.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.agedInkBlue,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.agedInkBlue,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double accuracy;
  final int attempts;

  const _StatRow({
    required this.label,
    required this.accuracy,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get display label from HintCategory
    String displayLabel = label;
    for (final cat in HintCategory.values) {
      if (cat.name == label) {
        displayLabel = cat.displayLabel;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              displayLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: accuracy,
                backgroundColor: AppColors.warmBeige,
                valueColor: AlwaysStoppedAnimation(
                  accuracy >= 0.8
                      ? AppColors.sageGreen
                      : accuracy >= 0.5
                          ? AppColors.mutedGold
                          : AppColors.dustyRose,
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(accuracy * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            '($attempts)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.agedInkBlue,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
