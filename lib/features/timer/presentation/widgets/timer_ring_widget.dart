import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom animated circular progress ring with gradient and tick indicators.
class TimerRingWidget extends StatelessWidget {
  const TimerRingWidget({
    super.key,
    required this.progress,
    required this.child,
    required this.accentColor,
    this.strokeWidth = 14.0,
    this.size = 280.0,
  });

  final double progress; // 0.0 to 1.0 (or >1.0 for overflow goal celebration)
  final Widget child;
  final Color accentColor;
  final double strokeWidth;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _TimerRingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: accentColor,
              backgroundColor: accentColor.withOpacity(0.12),
              strokeWidth: strokeWidth,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Active Progress Sweep
    if (progress > 0.0) {
      final sweepAngle = 2 * math.pi * progress;
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
