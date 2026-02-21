import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/statistics_service.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});
