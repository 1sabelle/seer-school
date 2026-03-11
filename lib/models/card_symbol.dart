class SymbolPoint {
  final double x;
  final double y;

  const SymbolPoint(this.x, this.y);
}

class CardSymbol {
  final String label;
  final String meaning;

  /// Polygon vertices as percentage of image dimensions (0.0–1.0).
  final List<SymbolPoint> region;

  const CardSymbol({
    required this.label,
    required this.meaning,
    required this.region,
  });
}

class CardSymbolData {
  final String cardId;
  final List<CardSymbol> symbols;

  const CardSymbolData({
    required this.cardId,
    required this.symbols,
  });
}
