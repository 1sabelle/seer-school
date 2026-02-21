import 'package:hive/hive.dart';
import '../models/card_statistic.dart';
import '../models/hint_category.dart';

class StatisticsService {
  static const String _boxName = 'card_statistics';

  Box<CardStatistic> get _box => Hive.box<CardStatistic>(_boxName);

  void recordAttempt(String cardId, HintCategory category, bool correct) {
    final key = '${cardId}_${category.name}';
    final stat = _box.get(key) ??
        CardStatistic(cardId: cardId, hintCategory: category.name);

    if (correct) {
      stat.correctCount++;
    } else {
      stat.incorrectCount++;
    }
    stat.lastPracticed = DateTime.now();
    _box.put(key, stat);
  }

  CardStatistic? getStatForCardHint(String cardId, HintCategory category) {
    return _box.get('${cardId}_${category.name}');
  }

  List<CardStatistic> getStatsForCard(String cardId) {
    return _box.values.where((s) => s.cardId == cardId).toList();
  }

  List<CardStatistic> getAllStats() {
    return _box.values.toList();
  }

  double getOverallAccuracy() {
    final stats = getAllStats();
    if (stats.isEmpty) return 0.0;
    final total = stats.fold(0, (sum, s) => sum + s.totalAttempts);
    if (total == 0) return 0.0;
    final correct = stats.fold(0, (sum, s) => sum + s.correctCount);
    return correct / total;
  }

  int getTotalAttempts() {
    return getAllStats().fold(0, (sum, s) => sum + s.totalAttempts);
  }

  int getCardsStudied() {
    return getAllStats().map((s) => s.cardId).toSet().length;
  }

  Map<String, double> getAccuracyByCategory() {
    final byCategory = <String, List<CardStatistic>>{};
    for (final stat in getAllStats()) {
      byCategory.putIfAbsent(stat.hintCategory, () => []).add(stat);
    }
    return byCategory.map((cat, stats) {
      final total = stats.fold(0, (sum, s) => sum + s.totalAttempts);
      if (total == 0) return MapEntry(cat, 0.0);
      final correct = stats.fold(0, (sum, s) => sum + s.correctCount);
      return MapEntry(cat, correct / total);
    });
  }

  /// Get cards sorted by worst accuracy (for "Practice Weakest" mode).
  List<String> getWeakestCards({int limit = 10}) {
    final cardAccuracy = <String, double>{};
    final byCard = <String, List<CardStatistic>>{};

    for (final stat in getAllStats()) {
      byCard.putIfAbsent(stat.cardId, () => []).add(stat);
    }

    for (final entry in byCard.entries) {
      final total = entry.value.fold(0, (sum, s) => sum + s.totalAttempts);
      if (total == 0) continue;
      final correct = entry.value.fold(0, (sum, s) => sum + s.correctCount);
      cardAccuracy[entry.key] = correct / total;
    }

    final sorted = cardAccuracy.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }
}
