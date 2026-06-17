import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carby/theme/app_theme.dart';

class CalorieRingChart extends StatelessWidget {
  final double eaten;
  final double goal;
  final double size;

  const CalorieRingChart({
    super.key,
    required this.eaten,
    required this.goal,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (eaten / goal).clamp(0.0, 1.0);
    final remaining = (goal - eaten).clamp(0.0, goal);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.33,
              sections: [
                PieChartSectionData(
                  value: eaten > 0 ? eaten : 0.001,
                  color: AppColors.orange,
                  radius: size * 0.18,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: remaining > 0 ? remaining : 0.001,
                  color: AppColors.ringEmpty,
                  radius: size * 0.18,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eaten.toInt().toString(),
                style: GoogleFonts.inter(
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              Text(
                'kcal',
                style: GoogleFonts.inter(
                  fontSize: size * 0.07,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'von ${goal.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: size * 0.06,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Gradient overlay arc effect
          Positioned.fill(
            child: CustomPaint(
              painter: _GradientArcPainter(pct, size),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double progress;
  final double size;
  _GradientArcPainter(this.progress, this.size);

  @override
  void paint(Canvas canvas, Size s) {
    if (progress <= 0) return;
    final center = Offset(s.width / 2, s.height / 2);
    final radius = size * 0.415;
    final strokeWidth = size * 0.18;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * 3.14159265 * progress;

    final gradient = SweepGradient(
      startAngle: -3.14159265 / 2,
      endAngle: -3.14159265 / 2 + 2 * 3.14159265,
      colors: AppColors.ringGradient,
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.drawArc(
      rect,
      -3.14159265 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientArcPainter old) => old.progress != progress;
}
