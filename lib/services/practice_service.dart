import 'dart:math';
import '../models/tarot_card.dart';
import '../models/card_enums.dart';
import '../models/hint_category.dart';
import '../data/hint_options.dart';
import '../data/card_data.dart';
import 'card_service.dart';

class PracticeService {
  final CardService _cardService;
  final Random _random = Random();

  PracticeService(this._cardService);

  static const _romanNumerals = {
    0: '0',
    1: 'I',
    2: 'II',
    3: 'III',
    4: 'IV',
    5: 'V',
    6: 'VI',
    7: 'VII',
    8: 'VIII',
    9: 'IX',
    10: 'X',
    11: 'XI',
    12: 'XII',
    13: 'XIII',
    14: 'XIV',
    15: 'XV',
    16: 'XVI',
    17: 'XVII',
    18: 'XVIII',
    19: 'XIX',
    20: 'XX',
    21: 'XXI',
  };

  /// Generate all hint slots for a given card.
  List<HintSlot> generateHints(TarotCardDefinition card) {
    final hints = <HintSlot>[];

    if (card.isMajor) {
      hints.add(_buildArcanaNumberHint(card));
      hints.add(_buildJourneyStageHint(card));
      hints.add(_buildKeywordsHint(card));
    } else {
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

  HintSlot _buildArcanaNumberHint(TarotCardDefinition card) {
    final index = card.majorArcanaIndex!;
    final roman = _romanNumerals[index]!;
    final accepted = {
      index.toString(),
      roman.toLowerCase(),
    };

    return HintSlot(
      category: HintCategory.arcanaNumber,
      hintType: HintType.freeText,
      correctAnswer: '$index ($roman)',
      options: const [],
      acceptedAnswers: accepted,
    );
  }

  HintSlot _buildJourneyStageHint(TarotCardDefinition card) {
    final stage = JourneyStage.fromMajorIndex(card.majorArcanaIndex!);
    final shuffled = List<HintOption>.from(journeyStageOptions)
      ..shuffle(_random);
    return HintSlot(
      category: HintCategory.journeyStage,
      correctAnswer: stage.name,
      options: shuffled,
    );
  }

  HintSlot _buildKeywordsHint(TarotCardDefinition card) {
    final correctKeywords = card.keywords.toSet();

    // Gather intruder keywords from other Major Arcana cards
    final otherMajorCards = allCards
        .where((c) => c.isMajor && c.id != card.id)
        .toList()
      ..shuffle(_random);

    final intruders = <String>[];
    for (final other in otherMajorCards) {
      for (final keyword in other.keywords) {
        if (!correctKeywords.contains(keyword) && !intruders.contains(keyword)) {
          intruders.add(keyword);
          if (intruders.length >= 3) break;
        }
      }
      if (intruders.length >= 3) break;
    }

    final allOptions = <HintOption>[
      ...card.keywords.map((k) => HintOption(key: k, displayLabel: k)),
      ...intruders.map((k) => HintOption(key: k, displayLabel: k)),
    ]..shuffle(_random);

    return HintSlot(
      category: HintCategory.keywords,
      hintType: HintType.multiSelect,
      correctAnswer: card.keywords.join(', '),
      options: allOptions,
      correctAnswers: correctKeywords,
    );
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
