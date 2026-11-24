import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../constants.dart';

/// Whether to animate at all: never when the device asks for reduced motion.
bool motionAllowed(BuildContext context) =>
    !MediaQuery.disableAnimationsOf(context);

/// belle.fyi's starfield: faint cream stars twinkling on navy.
///
/// Every page paints its own sky, but all skies share the same stars and the
/// same clock, so moving between pages never moves a star.
class NightSky extends StatefulWidget {
  final Widget child;

  const NightSky({super.key, required this.child});

  @override
  State<NightSky> createState() => _NightSkyState();
}

class _NightSkyState extends State<NightSky>
    with SingleTickerProviderStateMixin {
  static final Stopwatch _clock = Stopwatch()..start();

  /// Mid-twinkle, where every star sits when motion is reduced.
  static const _stillSeconds = 3.0;

  final ValueNotifier<double> _seconds = ValueNotifier(_stillSeconds);
  late final Ticker _ticker = createTicker(
    (_) => _seconds.value = _clock.elapsedMicroseconds / 1e6,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionAllowed(context)) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
      _seconds.value = _stillSeconds;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.night,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _StarfieldPainter(_seconds)),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Star {
  final double left;
  final double top;
  final double diameter;
  final double opacity;
  final double delaySeconds;
  final double periodSeconds;

  const _Star({
    required this.left,
    required this.top,
    required this.diameter,
    required this.opacity,
    required this.delaySeconds,
    required this.periodSeconds,
  });
}

/// The same 80 stars as belle.fyi: 1-3px wide, 0.2-0.7 bright, twinkling
/// every 4-8 seconds. Seeded so every sky has them in the same places.
final List<_Star> _stars = () {
  final random = math.Random(1909);
  return List.generate(80, (_) {
    return _Star(
      left: random.nextDouble(),
      top: random.nextDouble(),
      diameter: random.nextDouble() * 2 + 1,
      opacity: random.nextDouble() * 0.5 + 0.2,
      delaySeconds: random.nextDouble() * 6,
      periodSeconds: random.nextDouble() * 4 + 4,
    );
  });
}();

class _StarfieldPainter extends CustomPainter {
  final ValueListenable<double> seconds;

  _StarfieldPainter(this.seconds) : super(repaint: seconds);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      // Dim and small at the ends of each period, full at its middle, eased
      // in and out like the CSS twinkle.
      final phase =
          ((seconds.value + star.delaySeconds) / star.periodSeconds) % 1;
      final glow = (1 - math.cos(phase * 2 * math.pi)) / 2;
      paint.color = AppColors.cream
          .withValues(alpha: star.opacity * (0.3 + 0.7 * glow));
      canvas.drawCircle(
        Offset(star.left * size.width, star.top * size.height),
        star.diameter / 2 * (0.8 + 0.2 * glow),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) =>
      seconds != oldDelegate.seconds;
}

/// Pages rise into view the way belle.fyi's hero does (fading in while
/// moving up a little), each over its own copy of the sky.
class NightSkyPageTransitionsBuilder extends PageTransitionsBuilder {
  const NightSkyPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final rise = CurvedAnimation(parent: animation, curve: Curves.ease);
    return FadeTransition(
      opacity: rise,
      child: NightSky(
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(rise),
          child: child,
        ),
      ),
    );
  }
}
