import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../models/tarot_card.dart';
import '../../providers/deck_providers.dart';
import '../../providers/practice_providers.dart';

enum _DeckState { idle, flipping, expanding, revealed, collapsing }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _shuffleController;
  late final AnimationController _hintPulseController;
  late final AnimationController _expandController;
  late final AnimationController _sunburstController;

  _DeckState _deckState = _DeckState.idle;
  TarotCardDefinition? _drawnCard;

  // Key for measuring the deck card position on screen
  final GlobalKey _deckCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _startExpand();
        }
      });

    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _hintPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            _deckState == _DeckState.expanding) {
          setState(() => _deckState = _DeckState.revealed);
        } else if (status == AnimationStatus.dismissed &&
            _deckState == _DeckState.collapsing) {
          _finishCollapse();
        }
      });

    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shuffleController.dispose();
    _hintPulseController.dispose();
    _expandController.dispose();
    _sunburstController.dispose();
    super.dispose();
  }

  void _startExpand() {
    setState(() => _deckState = _DeckState.expanding);
    _expandController.forward(from: 0);
    _sunburstController.forward(from: 0);
  }

  void _finishCollapse() {
    setState(() {
      _deckState = _DeckState.idle;
    });
    _flipController.reset();
    _expandController.reset();
    _sunburstController.reset();
  }

  void _onDeckTap() {
    if (_deckState == _DeckState.flipping ||
        _deckState == _DeckState.expanding ||
        _deckState == _DeckState.collapsing) {
      return;
    }

    final dailyCard = ref.read(dailyDrawCardProvider);

    if (_deckState == _DeckState.idle) {
      if (dailyCard != null) {
        // Already drawn today — re-show the full-screen reveal
        HapticFeedback.lightImpact();
        setState(() {
          _drawnCard = dailyCard;
        });
        _startExpand();
        return;
      }

      // Fresh draw
      HapticFeedback.lightImpact();
      final card = ref.read(deckProvider.notifier).drawTop();
      if (card == null) return;
      setState(() {
        _drawnCard = card;
        _deckState = _DeckState.flipping;
      });
      _flipController.forward(from: 0);
    } else if (_deckState == _DeckState.revealed) {
      // Tap card in reveal → navigate to practice
      if (_drawnCard == null) return;
      _persistDailyDraw();
      ref.read(drawSessionProvider.notifier).drawSpecificCard(_drawnCard!.id);
      context.go('/practice/${_drawnCard!.id}');
      _collapseOverlay();
    }
  }

  void _onDismissReveal() {
    if (_deckState != _DeckState.revealed) return;
    _persistDailyDraw();
    _collapseOverlay();
  }

  void _collapseOverlay() {
    setState(() => _deckState = _DeckState.collapsing);
    _expandController.reverse();
    _sunburstController.reverse();
  }

  void _persistDailyDraw() {
    if (_drawnCard != null) {
      ref.read(dailyDrawProvider.notifier).setDraw(_drawnCard!.id);
      ref.read(unlockedCardsProvider.notifier).unlock(_drawnCard!.id);
    }
  }

  void _onShuffle() {
    if (_deckState == _DeckState.flipping) return;
    if (ref.read(dailyDrawProvider) != null) return;
    HapticFeedback.mediumImpact();
    _shuffleController.forward(from: 0);
    ref.read(deckProvider.notifier).shuffle();
    if (_deckState == _DeckState.revealed) {
      _resetToIdle();
    }
  }

  void _resetToIdle() {
    setState(() {
      _deckState = _DeckState.idle;
      _drawnCard = null;
    });
    _flipController.reset();
    _expandController.reset();
    _sunburstController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(deckProvider);
    final remaining = deck.length;
    final dailyCard = ref.watch(dailyDrawCardProvider);
    final hasDailyDraw = dailyCard != null;

    return Scaffold(
      body: Stack(
        children: [
          // Main content layer
          Positioned.fill(
            child: SafeArea(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Title
                  Text(
                    'Seer School',
                    style:
                        Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 40,
                              letterSpacing: 1.2,
                            ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // Deck card visual
                  _DeckCardWidget(
                    key: _deckCardKey,
                    flipController: _flipController,
                    shuffleController: _shuffleController,
                    deckState: _deckState,
                    drawnCard: _drawnCard,
                    dailyCard: dailyCard,
                    onTap: _onDeckTap,
                  ),

                  const SizedBox(height: 12),

                  // Hint text
                  if (_deckState == _DeckState.idle && !hasDailyDraw)
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.3, end: 0.8)
                          .animate(_hintPulseController),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Tap to draw',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.agedInkBlue,
                                letterSpacing: 1,
                              ),
                        ),
                      ),
                    ),
                  if (_deckState == _DeckState.idle && hasDailyDraw)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Today's card",
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedGold,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Card count & shuffle (hidden when daily draw exists)
                  if (!hasDailyDraw) ...[
                    Text(
                      '$remaining cards',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                AppColors.agedInkBlue.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _onShuffle,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: const Text('Shuffle'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.mutedGold,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  if (hasDailyDraw) const SizedBox(height: 30),

                  const Spacer(flex: 1),

                  // Attribution footer
                  Text(
                    'Illustrations by Pamela Colman Smith, 1909',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              AppColors.agedInkBlue.withValues(alpha: 0.4),
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          ),

          // Full-screen reveal overlay
          if (_deckState == _DeckState.expanding ||
              _deckState == _DeckState.revealed ||
              _deckState == _DeckState.collapsing)
            _FullScreenRevealOverlay(
              expandController: _expandController,
              sunburstController: _sunburstController,
              hintPulseController: _hintPulseController,
              deckState: _deckState,
              drawnCard: _drawnCard,
              onCardTap: _onDeckTap,
              onDismiss: _onDismissReveal,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full-screen reveal overlay
// ---------------------------------------------------------------------------

class _FullScreenRevealOverlay extends StatelessWidget {
  final AnimationController expandController;
  final AnimationController sunburstController;
  final AnimationController hintPulseController;
  final _DeckState deckState;
  final TarotCardDefinition? drawnCard;
  final VoidCallback onCardTap;
  final VoidCallback onDismiss;

  static const _deckCardWidth = 200.0;
  static const _deckCardHeight = 320.0;

  const _FullScreenRevealOverlay({
    required this.expandController,
    required this.sunburstController,
    required this.hintPulseController,
    required this.deckState,
    required this.drawnCard,
    required this.onCardTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = screenSize.height - padding.top - padding.bottom - 120; // room for text below
    final availableWidth = (screenSize.width - 80).clamp(0.0, 360.0); // max 360 wide
    const aspectRatio = _deckCardHeight / _deckCardWidth;

    // Constrain by both width and height to keep card on screen
    var maxCardWidth = availableWidth;
    var maxCardHeight = maxCardWidth * aspectRatio;
    if (maxCardHeight > availableHeight) {
      maxCardHeight = availableHeight;
      maxCardWidth = maxCardHeight / aspectRatio;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([expandController, sunburstController]),
      builder: (context, child) {
        final t = Curves.easeOut.transform(expandController.value);
        final scrimOpacity = t * 0.75;
        final cardWidth = _deckCardWidth + (maxCardWidth - _deckCardWidth) * t;
        final cardHeight = _deckCardHeight + (maxCardHeight - _deckCardHeight) * t;
        final sunburstOpacity = Curves.easeIn.transform(
          sunburstController.value.clamp(0.0, 1.0),
        );

        return Stack(
          children: [
            // Dark scrim
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: GestureDetector(
                  onTap: deckState == _DeckState.revealed ? onDismiss : null,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: scrimOpacity),
                  ),
                ),
              ),
            ),

            // Sunburst rays
            if (sunburstOpacity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: sunburstOpacity,
                    child: CustomPaint(
                      painter: _SunburstPainter(
                        rotation: sunburstController.value * 0.26, // ~15 degrees
                        color: AppColors.mutedGold,
                      ),
                    ),
                  ),
                ),
              ),

            // Card + text centered
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card
                  GestureDetector(
                    onTap: deckState == _DeckState.revealed ? onCardTap : null,
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.mutedGold,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mutedGold.withValues(alpha: 0.3 * t),
                            blurRadius: 32 * t,
                            spreadRadius: 8 * t,
                          ),
                          BoxShadow(
                            color: AppColors.darkBrown.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: drawnCard != null
                            ? Image.asset(
                                drawnCard!.assetPath,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // Card name — fades in when fully expanded
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: deckState == _DeckState.revealed ? 1.0 : t * 0.5,
                    child: Text(
                      drawnCard?.name ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.mutedGold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // "Tap to practice" hint
                  if (deckState == _DeckState.revealed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.3, end: 0.9)
                            .animate(hintPulseController),
                        child: Text(
                          'Tap card to practice',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.parchment
                                        .withValues(alpha: 0.8),
                                    letterSpacing: 1,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // X close button — top right
            if (deckState == _DeckState.revealed)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.parchment.withValues(alpha: 0.8),
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sunburst CustomPainter
// ---------------------------------------------------------------------------

class _SunburstPainter extends CustomPainter {
  final double rotation; // in radians-ish (we multiply by 2*pi)
  final Color color;

  _SunburstPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;
    const rayCount = 12;
    const rayAngle = (2 * math.pi) / rayCount;
    final rotationRad = rotation * 2 * math.pi;

    for (var i = 0; i < rayCount; i++) {
      final startAngle = rotationRad + i * rayAngle;
      final opacity = i.isEven ? 0.15 : 0.08;
      final paint = Paint()..color = color.withValues(alpha: opacity);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(startAngle) * maxRadius,
          center.dy + math.sin(startAngle) * maxRadius,
        )
        ..lineTo(
          center.dx + math.cos(startAngle + rayAngle * 0.5) * maxRadius,
          center.dy + math.sin(startAngle + rayAngle * 0.5) * maxRadius,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SunburstPainter oldDelegate) =>
      rotation != oldDelegate.rotation || color != oldDelegate.color;
}

// ---------------------------------------------------------------------------
// Deck card widget
// ---------------------------------------------------------------------------

class _DeckCardWidget extends StatelessWidget {
  final AnimationController flipController;
  final AnimationController shuffleController;
  final _DeckState deckState;
  final TarotCardDefinition? drawnCard;
  final TarotCardDefinition? dailyCard;
  final VoidCallback onTap;

  static const _cardWidth = 200.0;
  static const _cardHeight = 320.0;

  // Staggered timing windows for each card peeling from back to front.
  static const _shuffleCards = [
    (start: 0.0, end: 0.40),
    (start: 0.15, end: 0.55),
    (start: 0.30, end: 0.70),
    (start: 0.50, end: 0.90),
  ];

  const _DeckCardWidget({
    super.key,
    required this.flipController,
    required this.shuffleController,
    required this.deckState,
    required this.drawnCard,
    required this.dailyCard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([flipController, shuffleController]),
        builder: (context, child) {
          final isShuffling = shuffleController.isAnimating ||
              (shuffleController.value > 0 && shuffleController.value < 1);
          final flipValue = flipController.value;
          final angle = flipValue * math.pi;
          final showFace = flipValue >= 0.5;

          // If daily card is already drawn and we're idle, show it face-up
          final showDailyFaceUp =
              dailyCard != null && deckState == _DeckState.idle;

          return SizedBox(
            width: _cardWidth + 60,
            height: _cardHeight + 30,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Static depth cards (always visible — gives stack feel)
                Transform.translate(
                  offset: const Offset(0, 4),
                  child: SizedBox(
                    width: _cardWidth,
                    height: _cardHeight,
                    child: _buildCardBack(shadowOpacity: 0.1),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 2),
                  child: SizedBox(
                    width: _cardWidth,
                    height: _cardHeight,
                    child: _buildCardBack(shadowOpacity: 0.15),
                  ),
                ),

                // Main top card
                if (showDailyFaceUp)
                  SizedBox(
                    width: _cardWidth,
                    height: _cardHeight,
                    child: _buildCardFace(dailyCard),
                  )
                else
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: SizedBox(
                      width: _cardWidth,
                      height: _cardHeight,
                      child: showFace
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: _buildCardFace(drawnCard),
                            )
                          : _buildCardBack(),
                    ),
                  ),

                // Shuffle cards — rendered ON TOP, arcing from back to front
                if (isShuffling)
                  for (var i = 0; i < _shuffleCards.length; i++)
                    _buildShuffleLayer(i),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShuffleLayer(int index) {
    final spec = _shuffleCards[index];
    final t = shuffleController.value;

    final localT =
        ((t - spec.start) / (spec.end - spec.start)).clamp(0.0, 1.0);
    if (localT <= 0.0) return const SizedBox.shrink();

    final eased = Curves.easeInOut.transform(localT);

    final dy = localT < 1.0
        ? 8.0 * (1.0 - eased) + (-25.0 * math.sin(eased * math.pi))
        : 0.0;

    final direction = index.isEven ? 1.0 : -1.0;
    final dx = math.sin(eased * math.pi) * 35 * direction;

    final double opacity;
    if (localT < 0.15) {
      opacity = localT / 0.15;
    } else if (localT > 0.75) {
      opacity = (1.0 - localT) / 0.25;
    } else {
      opacity = 1.0;
    }

    final scale = 0.97 + 0.03 * eased;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: SizedBox(
            width: _cardWidth,
            height: _cardHeight,
            child: _buildCardBack(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack({double shadowOpacity = 0.3}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.mutedGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: shadowOpacity),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/cards/back.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCardFace(TarotCardDefinition? card) {
    if (card == null) return _buildCardBack();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.mutedGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          card.assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

