import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../data/card_data.dart';
import '../../models/card_enums.dart';
import '../../models/tarot_card.dart';
import '../../providers/deck_providers.dart';
import '../../providers/statistics_providers.dart';
import 'widgets/card_grid_tile.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _suitIconSize = 24.0;
  static const _suitAssets = [
    'assets/symbols/suit_wands.svg',
    'assets/symbols/suit_cups.svg',
    'assets/symbols/suit_swords.svg',
    'assets/symbols/suit_pentacles.svg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TarotCardDefinition> _getCardsForTab(int index) {
    switch (index) {
      case 0:
        return allCards.where((c) => c.arcana == Arcana.major).toList();
      case 1:
        return allCards.where((c) => c.suit == Suit.wands).toList();
      case 2:
        return allCards.where((c) => c.suit == Suit.cups).toList();
      case 3:
        return allCards.where((c) => c.suit == Suit.swords).toList();
      case 4:
        return allCards.where((c) => c.suit == Suit.pentacles).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsService = ref.watch(statisticsServiceProvider);
    final unlockedCards = ref.watch(unlockedCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepBurgundy,
          unselectedLabelColor: AppColors.agedInkBlue,
          indicatorColor: AppColors.mutedGold,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  final animValue = _tabController.animation!.value;
                  final selected = animValue.abs() < 0.5;
                  final color = selected
                      ? AppColors.deepBurgundy
                      : AppColors.agedInkBlue;
                  return ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(color, BlendMode.srcIn),
                    child: Image.asset(
                      'assets/symbols/major_laurel.png',
                      width: _suitIconSize,
                      height: _suitIconSize,
                    ),
                  );
                },
              ),
            ),
            for (final asset in _suitAssets)
              Tab(
                child: AnimatedBuilder(
                  animation: _tabController.animation!,
                  builder: (context, child) {
                    final tabIndex = _suitAssets.indexOf(asset) + 1;
                    final animValue = _tabController.animation!.value;
                    final selected = (animValue - tabIndex).abs() < 0.5;
                    final color = selected
                        ? AppColors.deepBurgundy
                        : AppColors.agedInkBlue;
                    return SvgPicture.asset(
                      asset,
                      width: _suitIconSize,
                      height: _suitIconSize,
                      colorFilter:
                          ColorFilter.mode(color, BlendMode.srcIn),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (tabIndex) {
          final cards = _getCardsForTab(tabIndex);
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final cardStats = statsService.getStatsForCard(card.id);
                double? mastery;
                if (cardStats.isNotEmpty) {
                  final total =
                      cardStats.fold(0, (sum, s) => sum + s.totalAttempts);
                  if (total > 0) {
                    final correct =
                        cardStats.fold(0, (sum, s) => sum + s.correctCount);
                    mastery = correct / total;
                  }
                }

                final isUnlocked = unlockedCards.contains(card.id);

                return CardGridTile(
                  card: card,
                  masteryScore: mastery,
                  isUnlocked: isUnlocked,
                  onTap: isUnlocked
                      ? () => context.go('/browse/${card.id}')
                      : null,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
