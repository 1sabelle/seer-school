import 'package:hive/hive.dart';

part 'card_statistic.g.dart';

@HiveType(typeId: 0)
class CardStatistic extends HiveObject {
  @HiveField(0)
  final String cardId;

  @HiveField(1)
  final String hintCategory;

  @HiveField(2)
  int correctCount;

  @HiveField(3)
  int incorrectCount;

  @HiveField(4)
  DateTime lastPracticed;

  CardStatistic({
    required this.cardId,
    required this.hintCategory,
    this.correctCount = 0,
    this.incorrectCount = 0,
    DateTime? lastPracticed,
  }) : lastPracticed = lastPracticed ?? DateTime.now();

  int get totalAttempts => correctCount + incorrectCount;

  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctCount / totalAttempts;
  }

  String get compositeKey => '${cardId}_$hintCategory';
}
