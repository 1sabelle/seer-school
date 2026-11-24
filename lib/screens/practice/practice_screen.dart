import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets/card_preview_overlay.dart';
import '../../core/widgets/shooting_star.dart';
import '../../core/widgets/sparkle.dart';
import '../../core/widgets/sparkle_text.dart';
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

  /// Where the user last touched, so a correct answer's shooting star can
  /// start from the answer they picked.
  Offset? _lastTouch;

  /// Correct hints whose shooting star is still on its way to their step.
  final Set<int> _starsInFlight = {};

  /// Correct hints whose shooting star has landed, so their step bursts.
  final Set<int> _starsLanded = {};

  /// Per card as well as per step: while one card's page fades out under the
  /// next, both show their steps at once.
  final Map<(String, int), GlobalKey> _stepKeys = {};

  GlobalKey _stepKeyFor(String cardId, int hintIndex) =>
      _stepKeys.putIfAbsent((cardId, hintIndex), GlobalKey.new);

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

  /// Sends a shooting star from where the answer was given to its step, when
  /// the answer was right.
  void _celebrateIfCorrect(int hintIndex) {
    final hint = ref.read(drawSessionProvider)?.hints[hintIndex];
    final from = _lastTouch;
    final cardId = _lastCardId;
    if (hint == null || !hint.isCorrect || from == null || cardId == null) {
      return;
    }
    final step =
        _stepKeyFor(cardId, hintIndex).currentContext?.findRenderObject();
    if (step is! RenderBox) return;

    final to = step.localToGlobal(step.size.center(Offset.zero));
    setState(() => _starsInFlight.add(hintIndex));
    flyShootingStar(
      context,
      from: from,
      to: to,
      onLanded: () {
        if (!mounted || cardId != _lastCardId) return;
        setState(() {
          _starsInFlight.remove(hintIndex);
          _starsLanded.add(hintIndex);
        });
      },
    );
  }

  void _onAnswerSelected(DrawSession session, int hintIndex, String key) {
    HapticFeedback.mediumImpact();
    ref.read(drawSessionProvider.notifier).selectAndReveal(hintIndex, key);
    _celebrateIfCorrect(hintIndex);

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
      _starsInFlight.clear();
      _starsLanded.clear();
    }

    return _buildPracticeScaffold(session, queue);
  }

  Widget _buildEmptyScreen(BuildContext context) {
    return Scaffold(
      body: StarryEmptyState(
        title: 'Draw your first card',
        body: 'Draw a card from the deck to unlock\nit for practice.',
        action: ElevatedButton(
          onPressed: () {
            StatefulNavigationShell.of(context).goBranch(0);
          },
          child: const Text('Go to Deck'),
        ),
      ),
    );
  }

  Widget _buildAllDoneScreen(BuildContext context, PracticeQueueState queue) {
    return Scaffold(
      body: StarryEmptyState(
        title: 'All Done!',
        body:
            'You practiced ${queue.completedCount} ${queue.completedCount == 1 ? 'card' : 'cards'} this session.',
        action: ElevatedButton.icon(
          onPressed: () {
            ref.read(practiceQueueProvider.notifier).reset();
          },
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: const Text('Practice Again'),
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
              child: Listener(
                key: ValueKey(session.card.id),
                onPointerDown: (event) => _lastTouch = event.position,
                child: _buildPracticeBody(session),
              ),
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
                      color: AppColors.muted,
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
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.periwinkle),
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
                  style: AppTheme.display(fontSize: 20),
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
        // A correct step stays unlit until its shooting star arrives.
        final isAnswered = h.isRevealed && !_starsInFlight.contains(i);

        final step = _StepStar(
          key: _stepKeyFor(session.card.id, i),
          isCurrent: isCurrent,
          isAnswered: isAnswered,
          isCorrect: h.isCorrect,
          hasLanded: _starsLanded.contains(i),
        );

        if (!h.isRevealed) return step;

        return Tooltip(
          message: _getAnswerSummary(h),
          preferBelow: true,
          triggerMode: TooltipTriggerMode.tap,
          child: step,
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
            _celebrateIfCorrect(_currentHintIndex);
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
            _celebrateIfCorrect(_currentHintIndex);
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
            style: AppTheme.display(fontSize: 22),
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
          style: AppTheme.body(
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
            final color = isCorrect ? AppColors.teal : AppColors.rose;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
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
                                color: AppColors.text,
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
                                  color: AppColors.teal,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (!isCorrect && !hasPeeked) ...[
                    _buildSummaryAction(
                      label: 'Reveal',
                      color: AppColors.lilac,
                      onTap: () => setState(() => _peekedHints.add(i)),
                    ),
                    const SizedBox(width: 6),
                    _buildSummaryAction(
                      label: 'Retry',
                      color: AppColors.periwinkle,
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
    final isPerfect = correct == total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (isPerfect)
            const Positioned.fill(
              child: SparkleBurst(count: 10, fromRadius: 20, toRadius: 90),
            ),
          TwinkleFramed(
            child: Text(
              '$correct / $total correct',
              style: AppTheme.display(fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}

/// One step of a card's practice, drawn as a star: dim until reached,
/// twinkling lilac while current, teal once answered right (bursting as its
/// shooting star lands) and a small rose star when answered wrong.
class _StepStar extends StatelessWidget {
  final bool isCurrent;
  final bool isAnswered;
  final bool isCorrect;
  final bool hasLanded;

  const _StepStar({
    super.key,
    required this.isCurrent,
    required this.isAnswered,
    required this.isCorrect,
    required this.hasLanded,
  });

  @override
  Widget build(BuildContext context) {
    final Widget star;
    if (isAnswered && isCorrect) {
      star = const Sparkle(size: 18, color: AppColors.teal);
    } else if (isAnswered) {
      star = const Sparkle(size: 12, color: AppColors.rose);
    } else if (isCurrent) {
      star = const TwinklingSparkle(size: 18);
    } else {
      star = const Sparkle(size: 10, color: AppColors.border);
    }

    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (hasLanded)
            const Positioned(
              left: -27,
              top: -27,
              width: 80,
              height: 80,
              child: SparkleBurst(
                count: 6,
                fromRadius: 6,
                toRadius: 28,
                sparkleSize: 8,
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: twirlCurve,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey((isAnswered, isCorrect, isCurrent)),
              child: star,
            ),
          ),
        ],
      ),
    );
  }
}
