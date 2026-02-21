import '../models/card_enums.dart';
import '../models/hint_category.dart';

final List<HintOption> elementOptions = [
  HintOption(
    key: Element.fire.name,
    displayLabel: 'Fire',
    assetPath: Element.fire.symbolAssetPath,
  ),
  HintOption(
    key: Element.water.name,
    displayLabel: 'Water',
    assetPath: Element.water.symbolAssetPath,
  ),
  HintOption(
    key: Element.air.name,
    displayLabel: 'Air',
    assetPath: Element.air.symbolAssetPath,
  ),
  HintOption(
    key: Element.earth.name,
    displayLabel: 'Earth',
    assetPath: Element.earth.symbolAssetPath,
  ),
];

final List<HintOption> suitOptions = [
  HintOption(
    key: Suit.wands.name,
    displayLabel: Suit.wands.themeKeywords,
  ),
  HintOption(
    key: Suit.cups.name,
    displayLabel: Suit.cups.themeKeywords,
  ),
  HintOption(
    key: Suit.swords.name,
    displayLabel: Suit.swords.themeKeywords,
  ),
  HintOption(
    key: Suit.pentacles.name,
    displayLabel: Suit.pentacles.themeKeywords,
  ),
];

final List<HintOption> numerologyOptions = NumerologyKeyword.values
    .map((k) => HintOption(
          key: k.name,
          displayLabel: k.displayLabel,
        ))
    .toList();

final List<HintOption> courtPersonaOptions = CourtPersona.values
    .map((p) => HintOption(
          key: p.name,
          displayLabel: p.displayLabel,
        ))
    .toList();
