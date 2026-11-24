import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets/sparkle.dart';
import '../../core/widgets/sparkle_text.dart';
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
  late final AnimationController _glowController;

  _DeckState _deckState = _DeckState.idle;
  TarotCardDefinition? _drawnCard;

  // Key for measuring the deck card position on screen
  final GlobalKey _deckCardKey = GlobalKey();

  /// Where the deck's top card sits on screen, so the reveal grows out of
  /// it and shrinks back into it.
  Rect? _deckCardRect;

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

    _glowController = AnimationController(
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
    _glowController.dispose();
    super.dispose();
  }

  void _startExpand() {
    setState(() {
      _deckState = _DeckState.expanding;
      _deckCardRect = _findDeckCardRect();
    });
    _expandController.forward(from: 0);
    _glowController.forward(from: 0);
  }

  void _finishCollapse() {
    setState(() {
      _deckState = _DeckState.idle;
    });
    _flipController.reset();
    _expandController.reset();
    _glowController.reset();
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
    _glowController.reverse();
    // Saving the draw can change what sits beneath the card (its name in
    // place of Shuffle), so measure again once that has been laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _deckCardRect = _findDeckCardRect());
    });
  }

  Rect? _findDeckCardRect() {
    final deckBox =
        _deckCardKey.currentContext?.findRenderObject() as RenderBox?;
    final screenBox = context.findRenderObject() as RenderBox?;
    if (deckBox == null || screenBox == null || !deckBox.attached) return null;
    final deckRect = MatrixUtils.transformRect(
      deckBox.getTransformTo(screenBox),
      Offset.zero & deckBox.size,
    );
    // The deck may be shrunk to fit, and leaves room around the card for
    // the shuffle; the card itself is centred in it.
    final scale = deckRect.width / deckBox.size.width;
    return Rect.fromCenter(
      center: deckRect.center,
      width: _DeckCardWidget._cardWidth * scale,
      height: _DeckCardWidget._cardHeight * scale,
    );
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
    _glowController.reset();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(deckProvider);
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
                  // The card and its name, centred above the footer and
                  // shrunk together on screens too short for them
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _DeckCardWidget(
                              key: _deckCardKey,
                              flipController: _flipController,
                              shuffleController: _shuffleController,
                              deckState: _deckState,
                              drawnCard: _drawnCard,
                              dailyCard: dailyCard,
                              onTap: _onDeckTap,
                            ),

                            // Card name beneath the card when drawn
                            if (hasDailyDraw && dailyCard != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TwinkleFramed(
                                  child: Text(
                                    dailyCard.name,
                                    style: AppTheme.display(fontSize: 22),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                            // Shuffle directly beneath the card
                            if (!hasDailyDraw)
                              TextButton.icon(
                                onPressed: _onShuffle,
                                icon: const Icon(
                                  Icons.shuffle_rounded,
                                  size: 18,
                                ),
                                label: const Text('Shuffle'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.lilac,
                                  textStyle: AppTheme.body(fontSize: 13)
                                      .copyWith(letterSpacing: 0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Attribution footer
                  Text(
                    'Illustrations by Pamela Colman Smith, 1909\n'
                    'Card descriptions from The Pictorial Key to the Tarot by A. E. Waite, 1911',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted.withValues(alpha: 0.7),
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
              glowController: _glowController,
              hintPulseController: _hintPulseController,
              deckState: _deckState,
              drawnCard: _drawnCard,
              deckCardRect: _deckCardRect,
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
  final AnimationController glowController;
  final AnimationController hintPulseController;
  final _DeckState deckState;
  final TarotCardDefinition? drawnCard;

  /// Where the card starts from and returns to; the middle of the screen
  /// when it couldn't be measured.
  final Rect? deckCardRect;
  final VoidCallback onCardTap;
  final VoidCallback onDismiss;

  static const _deckCardWidth = _DeckCardWidget._cardWidth;
  static const _deckCardHeight = _DeckCardWidget._cardHeight;

  const _FullScreenRevealOverlay({
    required this.expandController,
    required this.glowController,
    required this.hintPulseController,
    required this.deckState,
    required this.drawnCard,
    required this.deckCardRect,
    required this.onCardTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = screenSize.height - padding.top - padding.bottom - 160; // room for the hint above and the name below
    final availableWidth = (screenSize.width - 80).clamp(0.0, 360.0); // max 360 wide
    const aspectRatio = _deckCardHeight / _deckCardWidth;

    // Constrain by both width and height to keep card on screen
    var maxCardWidth = availableWidth;
    var maxCardHeight = maxCardWidth * aspectRatio;
    if (maxCardHeight > availableHeight) {
      maxCardHeight = availableHeight;
      maxCardWidth = maxCardHeight / aspectRatio;
    }

    final screenCentre = Offset(
      screenSize.width / 2,
      (padding.top + screenSize.height - padding.bottom) / 2,
    );
    final revealedRect = Rect.fromCenter(
      center: screenCentre,
      width: maxCardWidth,
      height: maxCardHeight,
    );
    final startRect = deckCardRect ??
        Rect.fromCenter(
          center: screenCentre,
          width: _deckCardWidth,
          height: _deckCardHeight,
        );

    return AnimatedBuilder(
      animation: Listenable.merge([expandController, glowController]),
      builder: (context, child) {
        final t = Curves.easeOut.transform(expandController.value);
        final scrimOpacity = t * 0.94;
        final cardRect = Rect.lerp(startRect, revealedRect, t)!;
        final glowOpacity = Curves.easeIn.transform(
          glowController.value.clamp(0.0, 1.0),
        );

        return Stack(
          children: [
            // Night scrim
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: GestureDetector(
                  onTap: deckState == _DeckState.revealed ? onDismiss : null,
                  child: ColoredBox(
                    color: AppColors.night.withValues(alpha: scrimOpacity),
                  ),
                ),
              ),
            ),

            // A soft lilac glow behind the card
            if (glowOpacity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: glowOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.6,
                          colors: [
                            AppColors.lilac.withValues(alpha: 0.22),
                            AppColors.periwinkle.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Sparkles flying out from the card once it has grown
            if (deckState == _DeckState.revealed)
              Positioned.fill(
                child: SparkleBurst(
                  count: 12,
                  fromRadius: maxCardWidth * 0.4,
                  toRadius: maxCardWidth * 0.9,
                  sparkleSize: 16,
                  duration: const Duration(milliseconds: 1400),
                ),
              ),

            // "Tap to practice" hint just above the card
            if (deckState == _DeckState.revealed)
              Positioned(
                left: 0,
                right: 0,
                bottom: screenSize.height - cardRect.top + 16,
                child: Center(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.3, end: 0.9)
                        .animate(hintPulseController),
                    child: TwinkleFramed(
                      sparkleSize: 9,
                      child: Text(
                        'Tap card to practice',
                        style: AppTheme.body(fontSize: 13)
                            .copyWith(letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ),

            // Card, growing out of the deck card's place
            Positioned.fromRect(
              rect: cardRect,
              child: GestureDetector(
                onTap: deckState == _DeckState.revealed ? onCardTap : null,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.lilac.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lilac.withValues(alpha: 0.35 * t),
                        blurRadius: 40 * t,
                        spreadRadius: 4 * t,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: drawnCard != null
                        ? ColoredBox(
                            color: AppColors.cardMargin,
                            child: Image.asset(
                              drawnCard!.assetPath,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

            // Card name beneath the card, fading in as it grows
            Positioned(
              left: 0,
              right: 0,
              top: cardRect.bottom + 16,
              child: Opacity(
                opacity: deckState == _DeckState.revealed ? 1.0 : t * 0.5,
                child: Text(
                  drawnCard?.name ?? '',
                  style: AppTheme.display(fontSize: 28).copyWith(
                    shadows: [
                      Shadow(
                        color: AppColors.lilac.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
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
                      color: AppColors.navy,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.text,
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
// Deck card widget
// ---------------------------------------------------------------------------

class _DeckCardWidget extends StatelessWidget {
  final AnimationController flipController;
  final AnimationController shuffleController;
  final _DeckState deckState;
  final TarotCardDefinition? drawnCard;
  final TarotCardDefinition? dailyCard;
  final VoidCallback onTap;

  static const _cardWidth = 260.0;

  /// The shape of the card images (500 by 864 pixels), so the whole card
  /// shows rather than a crop of it.
  static const _cardHeight = _cardWidth * 864 / 500;

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
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
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
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lilac.withValues(alpha: 0.2),
            blurRadius: 28,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: AppColors.cardMargin,
          child: Image.asset(
            card.assetPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
