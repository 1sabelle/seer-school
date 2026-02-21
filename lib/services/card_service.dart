import 'dart:math';
import '../data/card_data.dart' as data;
import '../models/tarot_card.dart';
import '../models/card_enums.dart';

class CardService {
  final Random _random = Random();

  List<TarotCardDefinition> get cards => data.allCards;

  TarotCardDefinition drawRandom({Suit? suit, Arcana? arcana}) {
    var pool = data.allCards.toList();
    if (suit != null) pool = pool.where((c) => c.suit == suit).toList();
    if (arcana != null) pool = pool.where((c) => c.arcana == arcana).toList();
    if (pool.isEmpty) pool = data.allCards;
    return pool[_random.nextInt(pool.length)];
  }

  TarotCardDefinition drawFromIds(List<String> ids) {
    if (ids.isEmpty) return drawRandom();
    final pool = data.allCards.where((c) => ids.contains(c.id)).toList();
    if (pool.isEmpty) return drawRandom();
    return pool[_random.nextInt(pool.length)];
  }

  TarotCardDefinition? getById(String id) {
    try {
      return data.allCards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TarotCardDefinition> getByArcana(Arcana arcana) {
    return data.allCards.where((c) => c.arcana == arcana).toList();
  }

  List<TarotCardDefinition> getBySuit(Suit suit) {
    return data.allCards.where((c) => c.suit == suit).toList();
  }

  List<TarotCardDefinition> getMajorArcana() {
    return getByArcana(Arcana.major);
  }

  /// Get distractor themes from cards of the same arcana type,
  /// excluding the given card.
  List<String> getDistractorThemes(TarotCardDefinition card, int count) {
    final sameArcana = data.allCards
        .where((c) => c.arcana == card.arcana && c.id != card.id)
        .toList()
      ..shuffle(_random);
    return sameArcana.take(count).map((c) => c.theme).toList();
  }
}
