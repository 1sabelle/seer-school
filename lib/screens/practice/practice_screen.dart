import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/card_enums.dart';
import '../../providers/practice_providers.dart';
import '../../providers/statistics_providers.dart';
import 'widgets/card_image_widget.dart';
import 'widgets/hint_slot_widget.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const PracticeScreen({super.key, this.cardId});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  Suit? _filterSuit;
  Arcana? _filterArcana;
  bool _practiceWeakest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(drawSessionProvider);
      if (session == null) {
        if (widget.cardId != null) {
          ref
              .read(drawSessionProvider.notifier)
              .drawSpecificCard(widget.cardId!);
        } else {
          ref.read(drawSessionProvider.notifier).drawNewCard();
        }
      }
    });
  }

  void _drawNext() {
    if (_practiceWeakest) {
      ref.read(drawSessionProvider.notifier).drawWeakestCard();
    } else {
      ref
          .read(drawSessionProvider.notifier)
          .drawNewCard(suit: _filterSuit, arcana: _filterArcana);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(drawSessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterSheet(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Active filter indicator
            if (_filterSuit != null ||
                _filterArcana != null ||
                _practiceWeakest)
              _buildFilterChips(),

            // Card image with hero animation
            Hero(
              tag: 'card_${session.card.id}',
              child: CardImageWidget(
                assetPath: session.card.assetPath,
                cardName: session.card.name,
              ),
            ),
            const SizedBox(height: 8),

            // Card name
            Text(
              session.card.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Keywords (reveal-only for Major Arcana)
            if (session.card.isMajor && session.allRevealed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  children: session.card.keywords
                      .map((k) => Chip(
                            label: Text(k),
                            backgroundColor:
                                AppColors.mutedGold.withValues(alpha: 0.15),
                            side: BorderSide.none,
                            labelStyle: const TextStyle(
                              color: AppColors.darkBrown,
                              fontSize: 13,
                            ),
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Hint slots
            ...List.generate(session.hints.length, (i) {
              return HintSlotWidget(
                hint: session.hints[i],
                index: i,
                onSelect: (key) {
                  ref.read(drawSessionProvider.notifier).selectAnswer(i, key);
                },
                onReveal: () {
                  HapticFeedback.mediumImpact();
                  ref.read(drawSessionProvider.notifier).revealHint(i);
                },
              );
            }),

            const SizedBox(height: 16),

            // Action buttons
            if (!session.allRevealed &&
                session.hints.any((h) => h.hasSelection && !h.isRevealed))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(drawSessionProvider.notifier).revealAll();
                  },
                  child: const Text('Reveal All'),
                ),
              ),

            if (session.allRevealed) ...[
              const SizedBox(height: 8),
              _buildScoreRow(session),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _drawNext,
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  label: const Text('Draw Next Card'),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        children: [
          if (_practiceWeakest)
            Chip(
              label: const Text('Weakest Cards'),
              onDeleted: () => setState(() => _practiceWeakest = false),
              backgroundColor: AppColors.dustyRose.withValues(alpha: 0.2),
              side: BorderSide.none,
            ),
          if (_filterSuit != null)
            Chip(
              label: Text(
                  _filterSuit!.name[0].toUpperCase() +
                      _filterSuit!.name.substring(1)),
              onDeleted: () => setState(() => _filterSuit = null),
              backgroundColor: AppColors.mutedGold.withValues(alpha: 0.2),
              side: BorderSide.none,
            ),
          if (_filterArcana != null)
            Chip(
              label: Text(
                  _filterArcana == Arcana.major ? 'Major Arcana' : 'Minor Arcana'),
              onDeleted: () => setState(() => _filterArcana = null),
              backgroundColor: AppColors.agedInkBlue.withValues(alpha: 0.15),
              side: BorderSide.none,
            ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final hasStats =
        ref.read(statisticsServiceProvider).getTotalAttempts() > 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.parchment,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.warmBeige,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Practice Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              if (hasStats)
                _FilterOption(
                  icon: Icons.trending_down_rounded,
                  label: 'Practice Weakest',
                  subtitle: 'Focus on cards you struggle with',
                  isSelected: _practiceWeakest,
                  onTap: () {
                    setState(() {
                      _practiceWeakest = !_practiceWeakest;
                      if (_practiceWeakest) {
                        _filterSuit = null;
                        _filterArcana = null;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),

              Text(
                'Filter by Arcana',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.agedInkBlue,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _FilterChip(
                      label: 'Major',
                      isSelected: _filterArcana == Arcana.major,
                      onTap: () {
                        setState(() {
                          _filterArcana =
                              _filterArcana == Arcana.major ? null : Arcana.major;
                          _practiceWeakest = false;
                          _filterSuit = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterChip(
                      label: 'Minor',
                      isSelected: _filterArcana == Arcana.minor,
                      onTap: () {
                        setState(() {
                          _filterArcana =
                              _filterArcana == Arcana.minor ? null : Arcana.minor;
                          _practiceWeakest = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Filter by Suit',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.agedInkBlue,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: Suit.values.map((suit) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _FilterChip(
                        label: suit.name[0].toUpperCase() +
                            suit.name.substring(1),
                        isSelected: _filterSuit == suit,
                        onTap: () {
                          setState(() {
                            _filterSuit =
                                _filterSuit == suit ? null : suit;
                            _practiceWeakest = false;
                            _filterArcana = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              if (_filterSuit != null ||
                  _filterArcana != null ||
                  _practiceWeakest)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _filterSuit = null;
                        _filterArcana = null;
                        _practiceWeakest = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All Filters'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreRow(DrawSession session) {
    final correct = session.hints.where((h) => h.isCorrect).length;
    final total = session.hints.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.mutedGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.mutedGold, size: 24),
          const SizedBox(width: 8),
          Text(
            '$correct / $total correct',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.mutedGold,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.deepBurgundy.withValues(alpha: 0.08)
                : AppColors.lightParchment,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.deepBurgundy : AppColors.warmBeige,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppColors.deepBurgundy
                      : AppColors.agedInkBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.agedInkBlue,
                            )),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded,
                    color: AppColors.deepBurgundy, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.deepBurgundy.withValues(alpha: 0.1)
              : AppColors.lightParchment,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.deepBurgundy : AppColors.warmBeige,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color:
                      isSelected ? AppColors.deepBurgundy : AppColors.darkBrown,
                ),
          ),
        ),
      ),
    );
  }
}
