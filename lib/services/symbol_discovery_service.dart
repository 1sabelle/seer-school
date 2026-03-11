import 'package:hive/hive.dart';

class SymbolDiscoveryService {
  static const String _boxName = 'symbol_discoveries';

  Box<List<dynamic>> get _box => Hive.box<List<dynamic>>(_boxName);

  Set<int> getDiscoveredIndices(String cardId) {
    final stored = _box.get(cardId);
    if (stored == null) return {};
    return stored.cast<int>().toSet();
  }

  void markDiscovered(String cardId, int symbolIndex) {
    final current = getDiscoveredIndices(cardId);
    current.add(symbolIndex);
    _box.put(cardId, current.toList());
  }

  int getDiscoveredCount(String cardId) {
    return getDiscoveredIndices(cardId).length;
  }

  void resetCard(String cardId) {
    _box.delete(cardId);
  }
}
