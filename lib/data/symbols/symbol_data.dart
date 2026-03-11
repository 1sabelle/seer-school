import '../../models/card_symbol.dart';

final Map<String, CardSymbolData> symbolDataMap = {
  for (final data in [
    ...majorArcanaSymbols,
  ])
    data.cardId: data,
};

const majorArcanaSymbols = [
  CardSymbolData(
    cardId: 'major_02',
    symbols: [
      // Left pillar (B) — tall narrow shape
      CardSymbol(
        label: 'Pillars of B & J',
        meaning:
            'The black pillar Boaz (strength) and white pillar Jachin (establishment) '
            'represent duality — darkness and light, the known and the unknown.',
        region: [
          SymbolPoint(0.06, 0.16),
          SymbolPoint(0.18, 0.16),
          SymbolPoint(0.18, 0.58),
          SymbolPoint(0.06, 0.58),
        ],
      ),
      // Veil — draped between the pillars, upper area
      CardSymbol(
        label: 'Veil of Pomegranates',
        meaning:
            'The veil between the pillars conceals the mysteries beyond. '
            'Its pomegranate pattern represents fertility, the sacred feminine, '
            'and the abundance of hidden knowledge.',
        region: [
          SymbolPoint(0.18, 0.16),
          SymbolPoint(0.82, 0.16),
          SymbolPoint(0.82, 0.42),
          SymbolPoint(0.18, 0.42),
        ],
      ),
      // Crescent moon at her feet
      CardSymbol(
        label: 'Crescent Moon',
        meaning:
            'The crescent moon at her feet symbolises intuition, cycles, '
            'and the subconscious mind. She is the guardian of inner knowing.',
        region: [
          SymbolPoint(0.22, 0.78),
          SymbolPoint(0.55, 0.78),
          SymbolPoint(0.58, 0.84),
          SymbolPoint(0.52, 0.90),
          SymbolPoint(0.25, 0.90),
          SymbolPoint(0.19, 0.84),
        ],
      ),
      // Scroll in her lap
      CardSymbol(
        label: 'Scroll of Torah',
        meaning:
            'The partially hidden scroll labelled TORA represents divine law '
            'and esoteric wisdom — only partly revealed, the rest must be sought within.',
        region: [
          SymbolPoint(0.28, 0.52),
          SymbolPoint(0.58, 0.50),
          SymbolPoint(0.60, 0.62),
          SymbolPoint(0.30, 0.64),
        ],
      ),
      // Crown on her head
      CardSymbol(
        label: 'Crown of Isis',
        meaning:
            'Her horned crown with a lunar disc connects her to the Egyptian goddess Isis '
            '— embodying divine feminine power, magic, and the throne of wisdom.',
        region: [
          SymbolPoint(0.30, 0.04),
          SymbolPoint(0.68, 0.04),
          SymbolPoint(0.65, 0.15),
          SymbolPoint(0.33, 0.15),
        ],
      ),
      // Right pillar (J)
      CardSymbol(
        label: 'Right Pillar (J)',
        meaning:
            'The white pillar Jachin represents the active, masculine principle '
            'and establishment. Together with Boaz, they frame the threshold '
            'between the known world and hidden mysteries.',
        region: [
          SymbolPoint(0.82, 0.16),
          SymbolPoint(0.94, 0.16),
          SymbolPoint(0.94, 0.58),
          SymbolPoint(0.82, 0.58),
        ],
      ),
    ],
  ),
];
