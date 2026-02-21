import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tarot_card.dart';
import 'card_providers.dart';

class DeckNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => _freshDeck();

  List<String> _freshDeck() {
    final ids = ref.read(cardServiceProvider).cards.map((c) => c.id).toList()
      ..shuffle();
    return ids;
  }

  void shuffle() {
    state = _freshDeck();
  }

  /// Draw the top card. Returns the card definition, removes it from deck.
  /// Auto-resets deck if empty.
  TarotCardDefinition? drawTop() {
    if (state.isEmpty) state = _freshDeck();
    final topId = state.first;
    state = state.sublist(1);
    return ref.read(cardServiceProvider).getById(topId);
  }

  int get remaining => state.length;
}

final deckProvider = NotifierProvider<DeckNotifier, List<String>>(
  DeckNotifier.new,
);

class DailyDrawNotifier extends Notifier<String?> {
  static const _keyCardId = 'daily_draw_card_id';
  static const _keyDate = 'daily_draw_date';

  Box get _box => Hive.box('app_settings');

  @override
  String? build() {
    final storedDate = _box.get(_keyDate) as String?;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (storedDate == today) {
      return _box.get(_keyCardId) as String?;
    }
    return null;
  }

  void setDraw(String cardId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _box.put(_keyCardId, cardId);
    _box.put(_keyDate, today);
    state = cardId;
  }

  bool get canDraw => state == null;
}

final dailyDrawProvider = NotifierProvider<DailyDrawNotifier, String?>(
  DailyDrawNotifier.new,
);

final dailyDrawCardProvider = Provider<TarotCardDefinition?>((ref) {
  final id = ref.watch(dailyDrawProvider);
  if (id == null) return null;
  return ref.read(cardServiceProvider).getById(id);
});
