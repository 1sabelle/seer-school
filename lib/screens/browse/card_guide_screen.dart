import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/widgets/card_preview_overlay.dart';
import '../../providers/card_providers.dart';
import '../../providers/guide_providers.dart';
import '../practice/widgets/card_image_widget.dart';

class CardGuideScreen extends ConsumerWidget {
  final String cardId;

  const CardGuideScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(allCardsProvider);
    final card = cards.where((c) => c.id == cardId).firstOrNull;
    final guide = ref.watch(cardGuideProvider(cardId));

    if (card == null || guide == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Card Guide')),
        body: const Center(child: Text('Guide not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card image (centred, tap to zoom)
            Center(
              child: GestureDetector(
                onTap: () => showCardPreview(
                  context,
                  assetPath: card.assetPath,
                  cardName: card.name,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: CardImageWidget(
                    assetPath: card.assetPath,
                    cardName: card.name,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card name
            Center(
              child: Text(
                card.name,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                card.theme,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.agedInkBlue,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Description
            _SectionTitle('Story & Symbolism'),
            const SizedBox(height: 8),
            Text(
              guide.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),

            // Element meaning
            _MeaningCard(
              icon: Icons.air_rounded,
              label:
                  '${card.element?.name[0].toUpperCase()}${card.element?.name.substring(1) ?? ''} — Element',
              text: guide.elementMeaning,
            ),

            // Suit meaning (minor arcana only)
            if (guide.suitMeaning != null) ...[
              const SizedBox(height: 12),
              _MeaningCard(
                icon: Icons.style_rounded,
                label: 'Suit Meaning',
                text: guide.suitMeaning!,
              ),
            ],

            // Numerology meaning
            if (guide.numerologyMeaning != null) ...[
              const SizedBox(height: 12),
              _MeaningCard(
                icon: Icons.tag_rounded,
                label: 'Numerology',
                text: guide.numerologyMeaning!,
              ),
            ],

            // Court persona meaning
            if (guide.courtPersonaMeaning != null) ...[
              const SizedBox(height: 12),
              _MeaningCard(
                icon: Icons.person_rounded,
                label: 'Court Persona',
                text: guide.courtPersonaMeaning!,
              ),
            ],

            const SizedBox(height: 24),

            // Upright
            _InterpretationSection(
              title: 'Upright',
              text: guide.uprightMeaning,
              color: AppColors.sageGreen,
            ),
            const SizedBox(height: 16),

            // Reversed
            _InterpretationSection(
              title: 'Reversed',
              text: guide.reversedMeaning,
              color: AppColors.dustyRose,
            ),
            const SizedBox(height: 24),

            // Reflection questions
            _SectionTitle('Reflection Questions'),
            const SizedBox(height: 12),
            ...guide.reflectionQuestions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.mutedGold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: AppColors.agedInkBlue,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.deepBurgundy,
          ),
    );
  }
}

class _MeaningCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _MeaningCard({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.mutedGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.mutedGold),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.agedInkBlue,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _InterpretationSection extends StatelessWidget {
  final String title;
  final String text;
  final Color color;

  const _InterpretationSection({
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
