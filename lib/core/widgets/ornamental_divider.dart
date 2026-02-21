import 'package:flutter/material.dart';

/// A decorative horizontal divider with a centered diamond motif and flanking
/// dots, styled after the section separators found in illuminated manuscripts.
class OrnamentalDivider extends StatelessWidget {
  final Color color;
  final double height;

  const OrnamentalDivider({
    super.key,
    required this.color,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _OrnamentalDividerPainter(color: color),
    );
  }
}

class _OrnamentalDividerPainter extends CustomPainter {
  final Color color;

  _OrnamentalDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final centerX = size.width / 2;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Left line
    canvas.drawLine(
      Offset(0, y),
      Offset(centerX - 14, y),
      linePaint,
    );

    // Right line
    canvas.drawLine(
      Offset(centerX + 14, y),
      Offset(size.width, y),
      linePaint,
    );

    // Center diamond
    const ds = 3.5; // diamond half-size
    final diamond = Path()
      ..moveTo(centerX, y - ds)
      ..lineTo(centerX + ds, y)
      ..lineTo(centerX, y + ds)
      ..lineTo(centerX - ds, y)
      ..close();
    canvas.drawPath(diamond, fillPaint);

    // Flanking dots
    canvas.drawCircle(Offset(centerX - 9, y), 1.0, fillPaint);
    canvas.drawCircle(Offset(centerX + 9, y), 1.0, fillPaint);
  }

  @override
  bool shouldRepaint(_OrnamentalDividerPainter oldDelegate) =>
      color != oldDelegate.color;
}
