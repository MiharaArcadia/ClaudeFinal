import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeRing extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final String timeString; // 'HH:MM:SS'
  final Color color;
  final double size;
  final Color? textColor;

  const TimeRing({
    super.key,
    required this.progress,
    required this.timeString,
    this.color = const Color(0xFFFF6B35),
    this.size = 280,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTextColor = textColor ?? (isDark ? Colors.white : const Color(0xFF1A1A1A));
    final trackColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          trackColor: trackColor,
        ),
        child: Center(
          child: Text(
            timeString,
            style: GoogleFonts.bebasNeue(
              fontSize: 72,
              color: resolvedTextColor,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  const _RingPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 12.0;
    const startAngle = -math.pi / 2; // Start at 12 o'clock

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Glow effect at progress tip
      if (progress < 1.0) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        final tipAngle = startAngle + 2 * math.pi * progress;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          tipAngle - 0.05,
          0.05,
          false,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.trackColor != trackColor;
}
