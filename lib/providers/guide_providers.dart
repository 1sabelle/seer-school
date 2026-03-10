import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_guide.dart';
import '../data/guides/major_arcana_guides.dart';
import '../data/guides/wands_guides.dart';
import '../data/guides/cups_guides.dart';
import '../data/guides/swords_guides.dart';
import '../data/guides/pentacles_guides.dart';

final _guideMap = {
  for (final guide in [
    ...majorArcanaGuides,
    ...wandsGuides,
    ...cupsGuides,
    ...swordsGuides,
    ...pentaclesGuides,
  ])
    guide.cardId: guide,
};

final cardGuideProvider =
    Provider.family<CardGuide?, String>((ref, cardId) {
  return _guideMap[cardId];
});
