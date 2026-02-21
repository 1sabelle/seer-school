import 'dart:math';
import '../models/tarot_card.dart';
import '../models/hint_category.dart';
import '../data/hint_options.dart';
import 'card_service.dart';

class PracticeService {
  final CardService _cardService;
  final Random _random = Random();

  PracticeService(this._cardService);

  /// Generate all hint slots for a given card.
  List<HintSlot> generateHints(TarotCardDefinition card) {
    final hints = <HintSlot>[];

    if (card.isMinor) {
      // Element hint
      hints.add(_buildElementHint(card));
      // Suit hint
      hints.add(_buildSuitHint(card));

      if (card.isNumbered) {
        // Numerology hint
        hints.add(_buildNumerologyHint(card));
      } else if (card.isCourt) {
        // Court persona hint
        hints.add(_buildCourtPersonaHint(card));
      }
    }

    // Theme hint (all cards)
    hints.add(_buildThemeHint(card));

    return hints;
  }

  HintSlot _buildElementHint(TarotCardDefinition card) {
    final shuffled = List<HintOption>.from(elementOptions)..shuffle(_random);
    return HintSlot(
      category: HintCategory.element,
      correctAnswer: card.element!.name,
      options: shuffled,
    );
  }

  HintSlot _buildSuitHint(TarotCardDefinition card) {
    final shuffled = List<HintOption>.from(suitOptions)..shuffle(_random);
    return HintSlot(
      category: HintCategory.suit,
      correctAnswer: card.suit!.name,
      options: shuffled,
    );
  }

  HintSlot _buildNumerologyHint(TarotCardDefinition card) {
    final shuffled = List<HintOption>.from(numerologyOptions)..shuffle(_random);
    return HintSlot(
      category: HintCategory.numerology,
      correctAnswer: card.numerologyKeyword!.name,
      options: shuffled,
    );
  }

  HintSlot _buildCourtPersonaHint(TarotCardDefinition card) {
    final shuffled = List<HintOption>.from(courtPersonaOptions)
      ..shuffle(_random);
    return HintSlot(
      category: HintCategory.courtPersona,
      correctAnswer: card.courtPersona!.name,
      options: shuffled,
    );
  }

  HintSlot _buildThemeHint(TarotCardDefinition card) {
    final distractors = _cardService.getDistractorThemes(card, 3);
    final options = <HintOption>[
      HintOption(key: card.theme, displayLabel: card.theme),
      ...distractors.map((t) => HintOption(key: t, displayLabel: t)),
    ]..shuffle(_random);

    return HintSlot(
      category: HintCategory.theme,
      correctAnswer: card.theme,
      options: options,
    );
  }
}
