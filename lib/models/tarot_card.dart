import 'card_enums.dart';

class TarotCardDefinition {
  final String id;
  final String name;
  final Arcana arcana;
  final Suit? suit;
  final Element? element;
  final CardNumber? number;
  final CourtRank? courtRank;
  final int? majorArcanaIndex;
  final NumerologyKeyword? numerologyKeyword;
  final CourtPersona? courtPersona;
  final String theme;
  final List<String> keywords;
  final String assetPath;

  const TarotCardDefinition({
    required this.id,
    required this.name,
    required this.arcana,
    this.suit,
    this.element,
    this.number,
    this.courtRank,
    this.majorArcanaIndex,
    this.numerologyKeyword,
    this.courtPersona,
    required this.theme,
    required this.keywords,
    required this.assetPath,
  });

  bool get isMajor => arcana == Arcana.major;
  bool get isMinor => arcana == Arcana.minor;
  bool get isCourt => courtRank != null;
  bool get isNumbered => number != null && !isCourt;
}
