import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/card_symbol.dart';
import '../../providers/card_providers.dart';
import '../../providers/symbol_providers.dart';

class SymbolExplorerScreen extends ConsumerStatefulWidget {
  final String cardId;

  const SymbolExplorerScreen({super.key, required this.cardId});

  @override
  ConsumerState<SymbolExplorerScreen> createState() =>
      _SymbolExplorerScreenState();
}

class _SymbolExplorerScreenState extends ConsumerState<SymbolExplorerScreen>
    with SingleTickerProviderStateMixin {
  late Set<int> _discovered;
  int? _activeIndex;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    final service = ref.read(symbolDiscoveryServiceProvider);
    _discovered = service.getDiscoveredIndices(widget.cardId);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSymbolTapped(int index) {
    final service = ref.read(symbolDiscoveryServiceProvider);
    service.markDiscovered(widget.cardId, index);
    setState(() {
      _discovered.add(index);
      _activeIndex = index;
    });
  }

  void _dismissDetail() {
    setState(() {
      _activeIndex = null;
    });
  }

  void _resetExploration() {
    final service = ref.read(symbolDiscoveryServiceProvider);
    service.resetCard(widget.cardId);
    setState(() {
      _discovered = {};
      _activeIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(allCardsProvider);
    final card = cards.where((c) => c.id == widget.cardId).firstOrNull;
    final symbolData = ref.watch(symbolDataProvider(widget.cardId));

    if (card == null || symbolData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Symbol Explorer')),
        body: const Center(child: Text('No symbol data available')),
      );
    }

    final symbols = symbolData.symbols;
    final allFound = _discovered.length == symbols.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          if (_discovered.isNotEmpty)
            IconButton(
              onPressed: _resetExploration,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset exploration',
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  allFound
                      ? Icons.check_circle_rounded
                      : Icons.search_rounded,
                  color: allFound
                      ? AppColors.sageGreen
                      : AppColors.mutedGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  allFound
                      ? 'All symbols discovered!'
                      : 'Tap the card to discover symbols',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.agedInkBlue,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_discovered.length} / ${symbols.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: allFound
                            ? AppColors.sageGreen
                            : AppColors.mutedGold,
                      ),
                ),
              ],
            ),
          ),

          // Card image with tap regions
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _CardWithSymbols(
                      assetPath: card.assetPath,
                      cardName: card.name,
                      symbols: symbols,
                      discovered: _discovered,
                      activeIndex: _activeIndex,
                      pulseAnimation: _pulseController,
                      onSymbolTapped: _onSymbolTapped,
                      onBackgroundTap: _activeIndex != null
                          ? _dismissDetail
                          : null,
                      maxHeight: constraints.maxHeight - 16,
                    );
                  },
                ),
              ),
            ),
          ),

          // Detail panel
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _activeIndex != null
                ? _SymbolDetailPanel(
                    symbol: symbols[_activeIndex!],
                    onDismiss: _dismissDetail,
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _CardWithSymbols extends StatelessWidget {
  final String assetPath;
  final String cardName;
  final List<CardSymbol> symbols;
  final Set<int> discovered;
  final int? activeIndex;
  final AnimationController pulseAnimation;
  final ValueChanged<int> onSymbolTapped;
  final VoidCallback? onBackgroundTap;
  final double maxHeight;

  const _CardWithSymbols({
    required this.assetPath,
    required this.cardName,
    required this.symbols,
    required this.discovered,
    required this.activeIndex,
    required this.pulseAnimation,
    required this.onSymbolTapped,
    required this.onBackgroundTap,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stackTrace) => Container(
                  width: 220,
                  height: 360,
                  color: AppColors.agedInkBlue,
                  child: Center(
                    child: Text(
                      cardName,
                      style: const TextStyle(color: AppColors.parchment),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _SymbolOverlay(
                      imageWidth: constraints.maxWidth,
                      imageHeight: constraints.maxHeight,
                      symbols: symbols,
                      discovered: discovered,
                      activeIndex: activeIndex,
                      pulseAnimation: pulseAnimation,
                      onSymbolTapped: onSymbolTapped,
                      onBackgroundTap: onBackgroundTap,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymbolOverlay extends AnimatedWidget {
  final double imageWidth;
  final double imageHeight;
  final List<CardSymbol> symbols;
  final Set<int> discovered;
  final int? activeIndex;
  final ValueChanged<int> onSymbolTapped;
  final VoidCallback? onBackgroundTap;

  const _SymbolOverlay({
    required this.imageWidth,
    required this.imageHeight,
    required this.symbols,
    required this.discovered,
    required this.activeIndex,
    required AnimationController pulseAnimation,
    required this.onSymbolTapped,
    required this.onBackgroundTap,
  }) : super(listenable: pulseAnimation);

  Path _buildPolygonPath(CardSymbol symbol) {
    final points = symbol.region;
    final path = Path();
    path.moveTo(points[0].x * imageWidth, points[0].y * imageHeight);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x * imageWidth, points[i].y * imageHeight);
    }
    path.close();
    return path;
  }

  int? _hitTest(Offset position) {
    for (int i = 0; i < symbols.length; i++) {
      final path = _buildPolygonPath(symbols[i]);
      if (path.contains(position)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final animation = listenable as AnimationController;

    return GestureDetector(
      onTapDown: (details) {
        final hit = _hitTest(details.localPosition);
        if (hit != null) {
          onSymbolTapped(hit);
        } else {
          onBackgroundTap?.call();
        }
      },
      child: CustomPaint(
        painter: _PolygonOverlayPainter(
          symbols: symbols,
          discovered: discovered,
          activeIndex: activeIndex,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          pulseValue: animation.value,
        ),
        size: Size(imageWidth, imageHeight),
      ),
    );
  }
}

class _PolygonOverlayPainter extends CustomPainter {
  final List<CardSymbol> symbols;
  final Set<int> discovered;
  final int? activeIndex;
  final double imageWidth;
  final double imageHeight;
  final double pulseValue;

  _PolygonOverlayPainter({
    required this.symbols,
    required this.discovered,
    required this.activeIndex,
    required this.imageWidth,
    required this.imageHeight,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < symbols.length; i++) {
      final symbol = symbols[i];
      final isActive = i == activeIndex;

      final opacity = isActive
          ? 1.0
          : ui.lerpDouble(0.4, 0.9, pulseValue)!;

      final strokeWidth = isActive ? 3.5 : 2.5;

      final paint = Paint()
        ..color = AppColors.mutedGold.withValues(alpha: opacity)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      final points = symbol.region;
      final path = Path();
      path.moveTo(points[0].x * imageWidth, points[0].y * imageHeight);
      for (int j = 1; j < points.length; j++) {
        path.lineTo(points[j].x * imageWidth, points[j].y * imageHeight);
      }
      path.close();

      // Draw dashed
      final metrics = path.computeMetrics();
      const dashLength = 6.0;
      const gapLength = 4.0;

      for (final metric in metrics) {
        double distance = 0;
        while (distance < metric.length) {
          final end = (distance + dashLength).clamp(0.0, metric.length);
          final segment = metric.extractPath(distance, end);
          canvas.drawPath(segment, paint);
          distance += dashLength + gapLength;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PolygonOverlayPainter oldDelegate) => true;
}

class _SymbolDetailPanel extends StatelessWidget {
  final CardSymbol symbol;
  final VoidCallback onDismiss;

  const _SymbolDetailPanel({
    required this.symbol,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightParchment,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mutedGold.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppColors.mutedGold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  symbol.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBurgundy,
                      ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.agedInkBlue.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            symbol.meaning,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
