import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/practice_providers.dart';
import 'widgets/card_image_widget.dart';
import 'widgets/hint_slot_widget.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const PracticeScreen({super.key, this.cardId});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cardId != null) {
        ref
            .read(drawSessionProvider.notifier)
            .drawSpecificCard(widget.cardId!);
      } else {
        final queue = ref.read(practiceQueueProvider);
        final session = ref.read(drawSessionProvider);
        if (queue.status == PracticeQueueStatus.active && session == null) {
          ref.read(practiceQueueProvider.notifier).startNext();
        }
      }
    });
  }

  void _nextCard() {
    final session = ref.read(drawSessionProvider);
    if (session != null) {
      ref
          .read(practiceQueueProvider.notifier)
          .completeCurrentCard(session.card.id);
    }
    final queue = ref.read(practiceQueueProvider);
    if (queue.status == PracticeQueueStatus.active) {
      ref.read(practiceQueueProvider.notifier).startNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(practiceQueueProvider);
    final session = ref.watch(drawSessionProvider);

    // All done always wins — regardless of deep-link
    if (queue.status == PracticeQueueStatus.allDone) {
      return _buildAllDoneScreen(context, queue);
    }

    // No unlocked cards
    if (queue.status == PracticeQueueStatus.empty && widget.cardId == null) {
      return _buildEmptyScreen(context);
    }

    // Waiting for session to load
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _buildPracticeScaffold(session, queue);
  }

  Widget _buildEmptyScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.mutedGold.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                'Draw your first card',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Draw a card from the deck to unlock\nit for practice.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.agedInkBlue,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  StatefulNavigationShell.of(context).goBranch(0);
                },
                icon: const Icon(Icons.style, size: 20),
                label: const Text('Go to Deck'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllDoneScreen(BuildContext context, PracticeQueueState queue) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 56,
                color: AppColors.mutedGold.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 20),
              Text(
                'All Done!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You practiced ${queue.completedCount} ${queue.completedCount == 1 ? 'card' : 'cards'} this session.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.agedInkBlue,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(practiceQueueProvider.notifier).reset();
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Practice Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeScaffold(
      DrawSession session, PracticeQueueState queue) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: Column(
        children: [
          // Progress indicator (only when navigating the queue, not deep-link)
          if (widget.cardId == null && queue.totalCards > 0)
            _buildProgressBar(queue),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _buildPracticeBody(session),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PracticeQueueState queue) {
    // completedCount doesn't include the current card yet, so show +1 for display
    final current = queue.completedCount + 1;
    final total = queue.totalCards;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current of $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.agedInkBlue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? current / total : 0,
              backgroundColor: AppColors.warmBeige,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.mutedGold),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPracticeBody(DrawSession session) {
    return SingleChildScrollView(
      key: ValueKey(session.card.id),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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

          // Reveal All button
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
                onPressed: _nextCard,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('Next Card'),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
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
