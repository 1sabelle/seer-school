import 'package:flutter/material.dart';

/// A [CustomPainter] that draws manuscript-style corner brackets with dot
/// terminals inside a container, evoking the ruled margins of illuminated
/// manuscripts and scholarly parchments.
///
/// Use as the `painter` of a [CustomPaint] widget wrapping your content.
class ManuscriptFramePainter extends CustomPainter {
  final Color color;
  final double inset;
  final double bracketLength;

  ManuscriptFramePainter({
    required this.color,
    this.inset = 6.0,
    this.bracketLength = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Don't draw brackets if the container is too small
    if (size.width < bracketLength * 3 || size.height < bracketLength * 3) {
      return;
    }

    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    const dotRadius = 1.5;
    final bl = bracketLength;

    // Top-left: curve flows from horizontal arm down to vertical arm
    final topLeft = Path()
      ..moveTo(rect.left + bl, rect.top)
      ..quadraticBezierTo(rect.left, rect.top, rect.left, rect.top + bl);
    canvas.drawPath(topLeft, linePaint);
    canvas.drawCircle(Offset(rect.left + bl, rect.top), dotRadius, dotPaint);
    canvas.drawCircle(Offset(rect.left, rect.top + bl), dotRadius, dotPaint);

    // Top-right: curve flows from horizontal arm down to vertical arm
    final topRight = Path()
      ..moveTo(rect.right - bl, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + bl);
    canvas.drawPath(topRight, linePaint);
    canvas.drawCircle(Offset(rect.right - bl, rect.top), dotRadius, dotPaint);
    canvas.drawCircle(Offset(rect.right, rect.top + bl), dotRadius, dotPaint);

    // Bottom-left: curve flows from vertical arm across to horizontal arm
    final bottomLeft = Path()
      ..moveTo(rect.left, rect.bottom - bl)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left + bl, rect.bottom);
    canvas.drawPath(bottomLeft, linePaint);
    canvas.drawCircle(Offset(rect.left, rect.bottom - bl), dotRadius, dotPaint);
    canvas.drawCircle(Offset(rect.left + bl, rect.bottom), dotRadius, dotPaint);

    // Bottom-right: curve flows from vertical arm across to horizontal arm
    final bottomRight = Path()
      ..moveTo(rect.right, rect.bottom - bl)
      ..quadraticBezierTo(
          rect.right, rect.bottom, rect.right - bl, rect.bottom);
    canvas.drawPath(bottomRight, linePaint);
    canvas.drawCircle(
        Offset(rect.right, rect.bottom - bl), dotRadius, dotPaint);
    canvas.drawCircle(
        Offset(rect.right - bl, rect.bottom), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(ManuscriptFramePainter oldDelegate) =>
      color != oldDelegate.color ||
      inset != oldDelegate.inset ||
      bracketLength != oldDelegate.bracketLength;
}
