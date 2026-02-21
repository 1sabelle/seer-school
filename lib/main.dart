import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/card_statistic.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CardStatisticAdapter());
  await Hive.openBox<CardStatistic>('card_statistics');
  await Hive.openBox('app_settings');

  runApp(
    const ProviderScope(
      child: SeerSchoolApp(),
    ),
  );
}
