import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarot_card.dart';
import '../models/card_enums.dart';
import '../models/hint_category.dart';
import '../services/card_service.dart';
import '../services/practice_service.dart';
import '../services/statistics_service.dart';
import 'card_providers.dart';
import 'deck_providers.dart';
import 'statistics_providers.dart';

class DrawSession {
  final TarotCardDefinition card;
  final List<HintSlot> hints;
  final bool allRevealed;

  const DrawSession({
    required this.card,
    required this.hints,
    this.allRevealed = false,
  });

  DrawSession copyWith({
    List<HintSlot>? hints,
    bool? allRevealed,
  }) {
    return DrawSession(
      card: card,
      hints: hints ?? this.hints,
      allRevealed: allRevealed ?? this.allRevealed,
    );
  }
}

class DrawSessionNotifier extends Notifier<DrawSession?> {
  @override
  DrawSession? build() => null;

  CardService get _cardService => ref.read(cardServiceProvider);
  PracticeService get _practiceService => ref.read(practiceServiceProvider);
  StatisticsService get _statisticsService =>
      ref.read(statisticsServiceProvider);

  void drawNewCard({Suit? suit, Arcana? arcana}) {
    final card = _cardService.drawRandom(suit: suit, arcana: arcana);
    _startSession(card);
  }

  void drawWeakestCard() {
    final weakest = _statisticsService.getWeakestCards(limit: 10);
    final card = _cardService.drawFromIds(weakest);
    _startSession(card);
  }

  void drawSpecificCard(String cardId) {
    final card = _cardService.getById(cardId);
    if (card != null) {
      _startSession(card);
    }
  }

  void _startSession(TarotCardDefinition card) {
    final hints = _practiceService.generateHints(card);
    state = DrawSession(card: card, hints: hints);
  }

  void selectAnswer(int hintIndex, String answerKey) {
    if (state == null) return;
    final hints = List<HintSlot>.from(state!.hints);
    if (hints[hintIndex].isRevealed) return;

    hints[hintIndex] = hints[hintIndex].copyWith(selectedAnswer: answerKey);
    state = state!.copyWith(hints: hints);
  }

  void revealHint(int hintIndex) {
    if (state == null) return;
    final hints = List<HintSlot>.from(state!.hints);
    final hint = hints[hintIndex];
    if (hint.isRevealed || !hint.hasSelection) return;

    hints[hintIndex] = hint.copyWith(isRevealed: true);

    // Record the attempt
    _statisticsService.recordAttempt(
      state!.card.id,
      hint.category,
      hint.isCorrect,
    );

    final allRevealed = hints.every((h) => h.isRevealed);
    state = state!.copyWith(hints: hints, allRevealed: allRevealed);
  }

  void revealAll() {
    if (state == null) return;
    final hints = List<HintSlot>.from(state!.hints);
    for (var i = 0; i < hints.length; i++) {
      if (!hints[i].isRevealed && hints[i].hasSelection) {
        _statisticsService.recordAttempt(
          state!.card.id,
          hints[i].category,
          hints[i].isCorrect,
        );
        hints[i] = hints[i].copyWith(isRevealed: true);
      }
    }
    final allRevealed = hints.every((h) => h.isRevealed);
    state = state!.copyWith(hints: hints, allRevealed: allRevealed);
  }
}

final practiceServiceProvider = Provider<PracticeService>((ref) {
  return PracticeService(ref.watch(cardServiceProvider));
});

final drawSessionProvider =
    NotifierProvider<DrawSessionNotifier, DrawSession?>(
        DrawSessionNotifier.new);

// ---------------------------------------------------------------------------
// Practice Queue
// ---------------------------------------------------------------------------

enum PracticeQueueStatus { active, allDone, empty }

class PracticeQueueState {
  final List<String> remaining;
  final Set<String> practiced;
  final PracticeQueueStatus status;

  const PracticeQueueState({
    this.remaining = const [],
    this.practiced = const {},
    this.status = PracticeQueueStatus.empty,
  });

  int get totalCards => remaining.length + practiced.length;
  int get completedCount => practiced.length;
  double get progress => totalCards == 0 ? 0 : completedCount / totalCards;

  PracticeQueueState copyWith({
    List<String>? remaining,
    Set<String>? practiced,
    PracticeQueueStatus? status,
  }) {
    return PracticeQueueState(
      remaining: remaining ?? this.remaining,
      practiced: practiced ?? this.practiced,
      status: status ?? this.status,
    );
  }
}

class PracticeQueueNotifier extends Notifier<PracticeQueueState> {
  @override
  PracticeQueueState build() {
    final unlocked = ref.watch(unlockedCardsProvider);
    if (unlocked.isEmpty) {
      return const PracticeQueueState(status: PracticeQueueStatus.empty);
    }
    return _buildQueue(unlocked);
  }

  PracticeQueueState _buildQueue(Set<String> unlocked) {
    final dailyCardId = ref.read(dailyDrawProvider);
    final ids = unlocked.toList()..shuffle();

    // Put daily card first if it exists
    if (dailyCardId != null && ids.contains(dailyCardId)) {
      ids.remove(dailyCardId);
      ids.insert(0, dailyCardId);
    }

    return PracticeQueueState(
      remaining: ids,
      practiced: const {},
      status: PracticeQueueStatus.active,
    );
  }

  void startNext() {
    if (state.remaining.isEmpty) return;
    final nextId = state.remaining.first;
    ref.read(drawSessionProvider.notifier).drawSpecificCard(nextId);
  }

  void completeCurrentCard(String cardId) {
    final newRemaining = state.remaining.where((id) => id != cardId).toList();
    final newPracticed = {...state.practiced, cardId};
    final newStatus = newRemaining.isEmpty
        ? PracticeQueueStatus.allDone
        : PracticeQueueStatus.active;

    state = state.copyWith(
      remaining: newRemaining,
      practiced: newPracticed,
      status: newStatus,
    );
  }

  void reset() {
    final unlocked = ref.read(unlockedCardsProvider);
    if (unlocked.isEmpty) {
      state = const PracticeQueueState(status: PracticeQueueStatus.empty);
      return;
    }
    state = _buildQueue(unlocked);
    startNext();
  }
}

final practiceQueueProvider =
    NotifierProvider<PracticeQueueNotifier, PracticeQueueState>(
        PracticeQueueNotifier.new);
