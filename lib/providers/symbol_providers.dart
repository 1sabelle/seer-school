import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/symbols/symbol_data.dart';
import '../models/card_symbol.dart';
import '../services/symbol_discovery_service.dart';

final symbolDataProvider =
    Provider.family<CardSymbolData?, String>((ref, cardId) {
  return symbolDataMap[cardId];
});

final symbolDiscoveryServiceProvider = Provider<SymbolDiscoveryService>((ref) {
  return SymbolDiscoveryService();
});
