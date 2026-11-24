import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../constants.dart';
import 'night_sky.dart';

/// Flies belle.fyi's shooting star (a glowing cream head with a lilac tail)
/// from [from] to [to], both in global coordinates, then calls [onLanded].
/// With reduced motion nothing flies and it lands at once.
void flyShootingStar(
  BuildContext context, {
  required Offset from,
  required Offset to,
  Duration duration = const Duration(milliseconds: 1200),
  required VoidCallback onLanded,
}) {
  if (!motionAllowed(context)) {
    onLanded();
    return;
  }

  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ShootingStarFlight(
      from: from,
      to: to,
      duration: duration,
      onLanded: () {
        entry.remove();
        onLanded();
      },
    ),
  );
  overlay.insert(entry);
}

class _ShootingStarFlight extends StatefulWidget {
  final Offset from;
  final Offset to;
  final Duration duration;
  final VoidCallback onLanded;

  const _ShootingStarFlight({
    required this.from,
    required this.to,
    required this.duration,
    required this.onLanded,
  });

  @override
  State<_ShootingStarFlight> createState() => _ShootingStarFlightState();
}

class _ShootingStarFlightState extends State<_ShootingStarFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onLanded();
    })
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ShootingStarPainter(
          flight: _controller,
          from: widget.from,
          to: widget.to,
        ),
      ),
    );
  }
}

class _ShootingStarPainter extends CustomPainter {
  final Animation<double> flight;
  final Offset from;
  final Offset to;

  _ShootingStarPainter({
    required this.flight,
    required this.from,
    required this.to,
  }) : super(repaint: flight);

  static const _flightCurve = Cubic(0.45, 0, 0.25, 1);
  static const _tailLength = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    final t = flight.value;
    final head = Offset.lerp(from, to, _flightCurve.transform(t))!;

    // As in ShootingStar.css: it stretches out and brightens over the first
    // 15%, flies at full length, and shrinks and fades over the last 15%.
    final double opacity;
    final double stretch;
    if (t < 0.15) {
      opacity = t / 0.15;
      stretch = 0.4 + 0.6 * t / 0.15;
    } else if (t > 0.85) {
      opacity = (1 - t) / 0.15;
      stretch = 1 - 0.7 * (t - 0.85) / 0.15;
    } else {
      opacity = 1;
      stretch = 1;
    }

    final delta = to - from;
    canvas.save();
    canvas.translate(head.dx, head.dy);
    canvas.rotate(math.atan2(delta.dy, delta.dx));

    final tail = Rect.fromLTRB(-_tailLength * stretch, -1, 0, 1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tail, const Radius.circular(1)),
      Paint()
        ..shader = ui.Gradient.linear(
          tail.centerLeft,
          tail.centerRight,
          [
            AppColors.lilac.withValues(alpha: 0),
            AppColors.lilac.withValues(alpha: opacity),
          ],
        ),
    );

    canvas.drawCircle(
      Offset.zero,
      6,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.85 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset.zero,
      3,
      Paint()..color = AppColors.cream.withValues(alpha: opacity),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShootingStarPainter oldDelegate) =>
      flight != oldDelegate.flight ||
      from != oldDelegate.from ||
      to != oldDelegate.to;
}
