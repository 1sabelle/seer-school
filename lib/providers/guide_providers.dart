import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_guide.dart';
import '../data/guides/major_arcana_guides.dart';

final _guideMap = {
  for (final guide in majorArcanaGuides) guide.cardId: guide,
};

final cardGuideProvider =
    Provider.family<CardGuide?, String>((ref, cardId) {
  return _guideMap[cardId];
});
