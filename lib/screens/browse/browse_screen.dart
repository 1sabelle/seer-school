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
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  static const _suitIconSize = 24.0;
  static const _tabIconOpacity = 0.55;
  static const _suitTabs = [
    ('assets/symbols/suit_wands.svg', 'Wands'),
    ('assets/symbols/suit_cups.svg', 'Cups'),
    ('assets/symbols/suit_swords.svg', 'Swords'),
    ('assets/symbols/suit_pentacles.svg', 'Pentacles'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  List<TarotCardDefinition> _getFilteredCards() {
    final query = _searchQuery.toLowerCase();
    return allCards.where((c) => c.name.toLowerCase().contains(query)).toList();
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darkBrown,
                    ),
                decoration: InputDecoration(
                  hintText: 'Search cards...',
                  hintStyle: TextStyle(
                    color: AppColors.agedInkBlue.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.agedInkBlue,
                    onPressed: _closeSearch,
                  ),
                ),
                cursorColor: AppColors.deepBurgundy,
              )
            : const Text('Deck'),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search, size: 22),
                  color: AppColors.agedInkBlue,
                  onPressed: _openSearch,
                ),
              ],
        bottom: _isSearching
            ? null
            : TabBar(
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
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: 0.55,
                        child: SvgPicture.asset(
                          'assets/symbols/major_laurel.svg',
                          width: _suitIconSize,
                          height: _suitIconSize,
                          colorFilter:
                              ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Major',
                        style: TextStyle(fontSize: 10, color: color),
                      ),
                    ],
                  );
                },
              ),
            ),
            for (final (asset, label) in _suitTabs)
              Tab(
                child: AnimatedBuilder(
                  animation: _tabController.animation!,
                  builder: (context, child) {
                    final tabIndex = _suitTabs.indexWhere((t) => t.$1 == asset) + 1;
                    final animValue = _tabController.animation!.value;
                    final selected = (animValue - tabIndex).abs() < 0.5;
                    final color = selected
                        ? AppColors.deepBurgundy
                        : AppColors.agedInkBlue;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          asset,
                          width: _suitIconSize,
                          height: _suitIconSize,
                          colorFilter:
                              ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(fontSize: 10, color: color),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      body: _isSearching
          ? _buildSearchResults(statsService, unlockedCards)
          : TabBarView(
              controller: _tabController,
              children: List.generate(5, (tabIndex) {
                final cards = _getCardsForTab(tabIndex);
                return _buildCardGrid(cards, statsService, unlockedCards);
              }),
            ),
    );
  }

  Widget _buildSearchResults(dynamic statsService, Set<String> unlockedCards) {
    final cards = _getFilteredCards();
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.agedInkBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No cards found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.agedInkBlue.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }
    return _buildCardGrid(cards, statsService, unlockedCards);
  }

  Widget _buildCardGrid(
    List<TarotCardDefinition> cards,
    dynamic statsService,
    Set<String> unlockedCards,
  ) {
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
  }
}
