import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular progress ring showing a 0-100 percentile score.
/// Pure rendering — no data fetching, no state. Shared across any
/// screen that needs a percentile/score ring (home, results, ...).
class PercentileRing extends StatelessWidget {
  const PercentileRing({
    super.key,
    required this.percentile,
    this.diameter = 200,
    this.strokeWidth = 14,
  });

  final int percentile;
  final double diameter;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = percentile.clamp(0, 100);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          progress: clamped / 100,
          trackColor: theme.colorScheme.outline,
          progressColor: theme.colorScheme.secondary,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$clamped', style: theme.textTheme.displayLarge),
              Text('Percentile', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.trackColor != trackColor;
}
