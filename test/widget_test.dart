import 'package:flutter_test/flutter_test.dart';
import 'package:seer_school/data/card_data.dart';
import 'package:seer_school/models/card_enums.dart';

void main() {
  test('All 78 cards are defined', () {
    expect(allCards.length, 78);
  });

  test('22 Major Arcana cards exist', () {
    final major = allCards.where((c) => c.arcana == Arcana.major);
    expect(major.length, 22);
  });

  test('Each suit has 14 cards', () {
    for (final suit in Suit.values) {
      final suitCards = allCards.where((c) => c.suit == suit);
      expect(suitCards.length, 14, reason: '${suit.name} should have 14 cards');
    }
  });

  test('All card IDs are unique', () {
    final ids = allCards.map((c) => c.id).toSet();
    expect(ids.length, allCards.length);
  });

  test('Suit-element mapping is correct', () {
    expect(Suit.wands.element, Element.fire);
    expect(Suit.cups.element, Element.water);
    expect(Suit.swords.element, Element.air);
    expect(Suit.pentacles.element, Element.earth);
  });

  test('Numbered cards have numerology keywords', () {
    final numbered = allCards.where((c) => c.number != null);
    for (final card in numbered) {
      expect(card.numerologyKeyword, isNotNull,
          reason: '${card.name} should have a numerology keyword');
    }
  });

  test('Court cards have court personas', () {
    final courts = allCards.where((c) => c.courtRank != null);
    for (final card in courts) {
      expect(card.courtPersona, isNotNull,
          reason: '${card.name} should have a court persona');
    }
  });
}
