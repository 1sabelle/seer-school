import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../constants.dart';
import 'night_sky.dart';

/// belle.fyi's twinkles twirl in with this overshoot, a little past full
/// size before settling.
const Curve twirlCurve = Cubic(0.34, 1.56, 0.64, 1);

/// belle.fyi's four-point star, [size] wide, centred on [center].
Path sparklePath(Offset center, double size) {
  final u = size / 24;
  return Path()
    ..moveTo(center.dx, center.dy - 12 * u)
    ..lineTo(center.dx + 2.6 * u, center.dy - 2.6 * u)
    ..lineTo(center.dx + 12 * u, center.dy)
    ..lineTo(center.dx + 2.6 * u, center.dy + 2.6 * u)
    ..lineTo(center.dx, center.dy + 12 * u)
    ..lineTo(center.dx - 2.6 * u, center.dy + 2.6 * u)
    ..lineTo(center.dx - 12 * u, center.dy)
    ..lineTo(center.dx - 2.6 * u, center.dy - 2.6 * u)
    ..close();
}

class Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const Sparkle({super.key, this.size = 24, this.color = AppColors.lilac});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      sparklePath(size.center(Offset.zero), size.shortestSide),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => color != oldDelegate.color;
}

/// A sparkle breathing in and out, like the two beside belle.fyi's mail
/// link. Give a pair opposite [phase]s (0 and 0.5) so they take turns.
class TwinklingSparkle extends StatefulWidget {
  final double size;
  final Color color;
  final double phase;

  const TwinklingSparkle({
    super.key,
    this.size = 12,
    this.color = AppColors.lilac,
    this.phase = 0,
  });

  @override
  State<TwinklingSparkle> createState() => _TwinklingSparkleState();
}

class _TwinklingSparkleState extends State<TwinklingSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionAllowed(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sparkle = Sparkle(size: widget.size, color: widget.color);
    if (!motionAllowed(context)) return sparkle;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + widget.phase) % 1;
        final glow = (1 - math.cos(t * 2 * math.pi)) / 2;
        return Opacity(
          opacity: 0.55 + 0.45 * glow,
          child: Transform.scale(scale: 0.7 + 0.3 * glow, child: child),
        );
      },
      child: sparkle,
    );
  }
}

/// A sparkle that twirls in when [shown] turns true and out again when it
/// turns false, like the twinkles on belle.fyi's nav.
class TwirlInSparkle extends StatefulWidget {
  final bool shown;
  final double size;
  final Color color;

  const TwirlInSparkle({
    super.key,
    required this.shown,
    this.size = 9,
    this.color = AppColors.cream,
  });

  @override
  State<TwirlInSparkle> createState() => _TwirlInSparkleState();
}

class _TwirlInSparkleState extends State<TwirlInSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: widget.shown ? 1 : 0,
  );

  @override
  void didUpdateWidget(TwirlInSparkle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shown == oldWidget.shown) return;
    if (!motionAllowed(context)) {
      _controller.value = widget.shown ? 1 : 0;
    } else if (widget.shown) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final twirl = twirlCurve.transform(t);
        // Opacity settles in 0.3s of the 0.45s twirl, as on belle.fyi.
        final opacity = (t / (300 / 450)).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: (1 - twirl) * -120 * math.pi / 180,
            child: Transform.scale(scale: 0.2 + 0.8 * twirl, child: child),
          ),
        );
      },
      child: Sparkle(size: widget.size, color: widget.color),
    );
  }
}

/// Sparkles flying out from the middle of the space it is given, growing,
/// spinning a little and fading as they go. It plays once when first built;
/// give it a new key to play it again.
class SparkleBurst extends StatefulWidget {
  final int count;
  final double fromRadius;
  final double toRadius;
  final double sparkleSize;
  final Duration duration;

  const SparkleBurst({
    super.key,
    this.count = 8,
    required this.fromRadius,
    required this.toRadius,
    this.sparkleSize = 10,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<SparkleBurst> createState() => _SparkleBurstState();
}

class _SparkleBurstState extends State<SparkleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionAllowed(context) && _controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!motionAllowed(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _SparkleBurstPainter(
          progress: _controller,
          count: widget.count,
          fromRadius: widget.fromRadius,
          toRadius: widget.toRadius,
          sparkleSize: widget.sparkleSize,
        ),
      ),
    );
  }
}

class _SparkleBurstPainter extends CustomPainter {
  final Animation<double> progress;
  final int count;
  final double fromRadius;
  final double toRadius;
  final double sparkleSize;

  _SparkleBurstPainter({
    required this.progress,
    required this.count,
    required this.fromRadius,
    required this.toRadius,
    required this.sparkleSize,
  }) : super(repaint: progress);

  static const _colors = [AppColors.cream, AppColors.lilac, AppColors.periwinkle];

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;

    final center = size.center(Offset.zero);
    final travel = Curves.easeOutCubic.transform(t);
    final grow = Curves.easeOut.transform((t / 0.3).clamp(0.0, 1.0));
    final fade = 1 - Curves.easeIn.transform(((t - 0.45) / 0.55).clamp(0.0, 1.0));
    final paint = Paint();

    for (var i = 0; i < count; i++) {
      // Spread evenly, nudged off the even spacing so the burst looks loose.
      final angle = i * 2 * math.pi / count + math.sin(i * 7.3) * 0.25;
      final reach = fromRadius +
          (toRadius - fromRadius) * travel * (0.75 + 0.25 * math.cos(i * 3.1));
      final sparkleCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * reach;
      final scale = (i.isEven ? 1.0 : 0.6) * grow * (1 - 0.4 * t);

      paint.color = _colors[i % _colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(sparkleCenter.dx, sparkleCenter.dy);
      canvas.rotate(t * math.pi / 2);
      canvas.drawPath(sparklePath(Offset.zero, sparkleSize * scale), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SparkleBurstPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      count != oldDelegate.count ||
      fromRadius != oldDelegate.fromRadius ||
      toRadius != oldDelegate.toRadius ||
      sparkleSize != oldDelegate.sparkleSize;
}
