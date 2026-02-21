import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/card_service.dart';
import '../data/card_data.dart' as data;
import '../models/tarot_card.dart';

final cardServiceProvider = Provider<CardService>((ref) {
  return CardService();
});

final allCardsProvider = Provider<List<TarotCardDefinition>>((ref) {
  return data.allCards;
});
