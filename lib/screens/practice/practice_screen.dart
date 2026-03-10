import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/widgets/card_preview_overlay.dart';
import '../../models/hint_category.dart';
import '../../providers/guide_providers.dart';
import '../../providers/practice_providers.dart';
import 'widgets/card_image_widget.dart';
import 'widgets/free_text_hint_widget.dart';
import 'widgets/hint_picker_widget.dart';
import 'widgets/multi_select_hint_widget.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const PracticeScreen({super.key, this.cardId});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  /// Index of the hint currently being shown.
  int _currentHintIndex = 0;

  /// Track the current card to detect session changes.
  String? _lastCardId;

  /// Tracks which hint indices the user has peeked at the answer for.
  final Set<int> _peekedHints = {};

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

  @override
  void didUpdateWidget(covariant PracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cardId != oldWidget.cardId) {
      _resetHintIndex();
    }
  }

  void _resetHintIndex() {
    setState(() {
      _currentHintIndex = 0;
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
      _resetHintIndex();
    }
  }

  void _onAnswerSelected(DrawSession session, int hintIndex, String key) {
    HapticFeedback.mediumImpact();
    ref.read(drawSessionProvider.notifier).selectAndReveal(hintIndex, key);

    // Keep the revealed picker visible briefly (green/red highlight), then advance
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        if (_currentHintIndex < session.hints.length - 1) {
          _currentHintIndex++;
        }
      });
    });
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

    // Reset hint index when the card changes (e.g. queue navigation)
    if (session.card.id != _lastCardId) {
      _lastCardId = session.card.id;
      _currentHintIndex = 0;
      _peekedHints.clear();
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
              ElevatedButton(
                onPressed: () {
                  StatefulNavigationShell.of(context).goBranch(0);
                },
                child: const Text('Go to Deck'),
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
      appBar: AppBar(
        title: const Text('Practice'),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator (only when navigating the queue, not deep-link)
          if (widget.cardId == null && queue.totalCards > 0)
            _buildProgressBar(queue),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previousChildren,
                    ?currentChild,
                  ],
                );
              },
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

  void _showCardPreview(DrawSession session) {
    showCardPreview(
      context,
      assetPath: session.card.assetPath,
      cardName: session.card.name,
      heroTag: 'card_${session.card.id}',
    );
  }

  Widget _buildPracticeBody(DrawSession session) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardMaxHeight = (screenHeight * 0.22).clamp(120.0, 200.0);
    final hint = session.hints[_currentHintIndex];

    return Column(
      key: ValueKey(session.card.id),
      children: [
        // Card image and name (compact, tappable)
        GestureDetector(
          onTap: () => _showCardPreview(session),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: cardMaxHeight),
                  child: Hero(
                    tag: 'card_${session.card.id}',
                    child: CardImageWidget(
                      assetPath: session.card.assetPath,
                      cardName: session.card.name,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  session.card.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Step dots
        _buildResultCircles(session),

        const SizedBox(height: 20),

        // Current hint prompt or score
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: session.allRevealed
                  ? _buildCompletedView(session)
                  : _buildHintPrompt(session, hint),
            ),
          ),
        ),
      ],
    );
  }

  String _getAnswerSummary(HintSlot hint) {
    final label = hint.category.displayLabel;
    switch (hint.hintType) {
      case HintType.singleSelect:
        if (hint.selectedAnswer == null) return '$label: —';
        final match = hint.options
            .where((o) => o.key == hint.selectedAnswer)
            .toList();
        final picked = match.isNotEmpty ? match.first.displayLabel : hint.selectedAnswer!;
        return '$label: $picked';
      case HintType.freeText:
        return '$label: ${hint.selectedAnswer ?? '—'}';
      case HintType.multiSelect:
        if (hint.selectedAnswers.isEmpty) return '$label: —';
        final labels = hint.selectedAnswers
            .map((k) {
              final match = hint.options.where((o) => o.key == k).toList();
              return match.isNotEmpty ? match.first.displayLabel : k;
            })
            .join(', ');
        return '$label: $labels';
    }
  }

  Widget _buildResultCircles(DrawSession session) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(session.hints.length, (i) {
        final h = session.hints[i];
        final isCurrent = i == _currentHintIndex && !session.allRevealed;

        final bool isFilled = h.isRevealed;
        final Color fillColor =
            h.isRevealed ? (h.isCorrect ? AppColors.sageGreen : AppColors.dustyRose) : Colors.transparent;
        final Color borderColor = isCurrent
            ? AppColors.mutedGold
            : isFilled
                ? fillColor
                : AppColors.warmBeige;

        final circle = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: isFilled
              ? Center(
                  child: Icon(
                    h.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    size: 9,
                    color: Colors.white,
                  ),
                )
              : null,
        );

        if (!isFilled) return circle;

        return Tooltip(
          message: _getAnswerSummary(h),
          preferBelow: true,
          triggerMode: TooltipTriggerMode.tap,
          textStyle: const TextStyle(
            color: AppColors.parchment,
            fontSize: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkBrown.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: circle,
        );
      }),
    );
  }

  String _promptText(HintSlot hint) {
    switch (hint.category) {
      case HintCategory.arcanaNumber:
        return 'What number is this card?';
      case HintCategory.journeyStage:
        return 'Which stage of the Fool\'s Journey?';
      case HintCategory.keywords:
        return 'Select all keywords for this card';
      default:
        return 'What is the ${hint.category.displayLabel.toLowerCase()}?';
    }
  }

  Widget _buildHintPicker(DrawSession session, HintSlot hint) {
    switch (hint.hintType) {
      case HintType.freeText:
        return FreeTextHintWidget(
          isRevealed: hint.isRevealed,
          isCorrect: hint.isCorrect,
          correctDisplay: hint.correctAnswer,
          onSubmit: (answer) {
            HapticFeedback.mediumImpact();
            ref
                .read(drawSessionProvider.notifier)
                .submitFreeText(_currentHintIndex, answer);
            Future.delayed(const Duration(milliseconds: 400), () {
              if (!mounted) return;
              setState(() {
                if (_currentHintIndex < session.hints.length - 1) {
                  _currentHintIndex++;
                }
              });
            });
          },
        );
      case HintType.multiSelect:
        return MultiSelectHintWidget(
          options: hint.options,
          selectedKeys: hint.selectedAnswers,
          correctKeys: hint.correctAnswers ?? const {},
          isRevealed: hint.isRevealed,
          onToggle: (key) {
            HapticFeedback.selectionClick();
            ref
                .read(drawSessionProvider.notifier)
                .toggleMultiSelect(_currentHintIndex, key);
          },
          onConfirm: () {
            HapticFeedback.mediumImpact();
            ref
                .read(drawSessionProvider.notifier)
                .confirmMultiSelect(_currentHintIndex);
            Future.delayed(const Duration(milliseconds: 400), () {
              if (!mounted) return;
              setState(() {
                if (_currentHintIndex < session.hints.length - 1) {
                  _currentHintIndex++;
                }
              });
            });
          },
        );
      case HintType.singleSelect:
        return HintPickerWidget(
          options: hint.options,
          selectedKey: hint.selectedAnswer,
          isRevealed: hint.isRevealed,
          correctAnswer: hint.correctAnswer,
          onSelect: (key) =>
              _onAnswerSelected(session, _currentHintIndex, key),
        );
    }
  }

  Widget _buildHintPrompt(DrawSession session, HintSlot hint) {
    return SingleChildScrollView(
      key: ValueKey('hint_$_currentHintIndex'),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 96),
      child: Column(
        children: [
          Text(
            _promptText(hint),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.agedInkBlue,
                  letterSpacing: 0.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildHintPicker(session, hint),
        ],
      ),
    );
  }

  void _retryHint(int hintIndex) {
    HapticFeedback.mediumImpact();
    ref.read(drawSessionProvider.notifier).resetHint(hintIndex);
    setState(() {
      _currentHintIndex = hintIndex;
    });
  }

  String _getCorrectDisplay(HintSlot hint) {
    switch (hint.hintType) {
      case HintType.singleSelect:
        final match = hint.options
            .where((o) => o.key == hint.correctAnswer)
            .toList();
        return match.isNotEmpty ? match.first.displayLabel : hint.correctAnswer;
      case HintType.freeText:
        return hint.correctAnswer;
      case HintType.multiSelect:
        if (hint.correctAnswers == null) return hint.correctAnswer;
        return hint.correctAnswers!
            .map((k) {
              final match = hint.options.where((o) => o.key == k).toList();
              return match.isNotEmpty ? match.first.displayLabel : k;
            })
            .join(', ');
    }
  }

  Widget _buildSummaryAction({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedView(DrawSession session) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 96),
      child: Column(
        children: [
          _buildScoreRow(session),
          const SizedBox(height: 20),

          // Answer summary
          ...List.generate(session.hints.length, (i) {
            final hint = session.hints[i];
            final isCorrect = hint.isCorrect;
            final hasPeeked = _peekedHints.contains(i);
            final color = isCorrect ? AppColors.sageGreen : AppColors.dustyRose;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hint.category.displayLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.agedInkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (!isCorrect && hasPeeked)
                          Text(
                            _getCorrectDisplay(hint),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.sageGreen,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (!isCorrect && !hasPeeked) ...[
                    _buildSummaryAction(
                      label: 'Reveal',
                      color: AppColors.mutedGold,
                      onTap: () => setState(() => _peekedHints.add(i)),
                    ),
                    const SizedBox(width: 6),
                    _buildSummaryAction(
                      label: 'Retry',
                      color: AppColors.deepBurgundy,
                      onTap: () => _retryHint(i),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          if (ref.watch(cardGuideProvider(session.card.id)) != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.go('/browse/${session.card.id}/guide'),
                icon: const Icon(Icons.menu_book_rounded, size: 20),
                label: const Text('Read Full Guide'),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nextCard,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text('Next Card'),
            ),
          ),
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

