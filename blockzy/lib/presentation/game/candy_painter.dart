/// Draws a single candy into a cell rectangle.
///
/// If real art is available (via [CandyAssetLoader]) it is drawn; otherwise a
/// procedural candy is painted with a distinct colour AND a distinct shape per
/// type, so candies stay recognisable even for colour-blind players.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../domain/candy.dart';

class CandyPainter {
  CandyPainter._();

  /// Paints [type] filling [rect] (with a small inset). [image] is the real art
  /// when present, else null → procedural. [alpha] fades ghosts/previews.
  static void paint(
    Canvas canvas,
    Rect rect,
    CandyType type, {
    ui.Image? image,
    double alpha = 1.0,
    Color? colorOverride,
  }) {
    final inset = rect.width * 0.08;
    final cell = rect.deflate(inset);
    final color = (colorOverride ?? Color(type.defaultColorValue))
        .withValues(alpha: alpha);

    if (image != null) {
      paintImage(
        canvas: canvas,
        rect: cell,
        image: image,
        fit: BoxFit.contain,
        opacity: alpha,
        filterQuality: FilterQuality.medium,
      );
      return;
    }

    _paintProcedural(canvas, cell, type, color);
  }

  static void _paintProcedural(
    Canvas canvas,
    Rect cell,
    CandyType type,
    Color color,
  ) {
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.25)!,
          color,
          Color.lerp(color, Colors.black, 0.2)!,
        ],
      ).createShader(cell);

    final r = BlockzyRadii.md;
    switch (type.shapeId % 7) {
      case 0: // rounded square (strawberry)
        canvas.drawRRect(RRect.fromRectXY(cell, r, r), base);
      case 1: // circle (lemon)
        canvas.drawOval(cell, base);
      case 2: // diamond (blueberry)
        canvas.drawPath(_diamond(cell), base);
      case 3: // hexagon (lime)
        canvas.drawPath(_polygon(cell, 6), base);
      case 4: // triangle (grape)
        canvas.drawPath(_polygon(cell, 3), base);
      case 5: // pentagon (orange)
        canvas.drawPath(_polygon(cell, 5), base);
      default: // rounded plus (mint)
        canvas.drawPath(_plus(cell), base);
    }

    // Glossy highlight for a juicy candy look.
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final hl = Rect.fromLTWH(
      cell.left + cell.width * 0.18,
      cell.top + cell.height * 0.14,
      cell.width * 0.34,
      cell.height * 0.22,
    );
    canvas.drawOval(hl, highlight);
  }

  static Path _diamond(Rect r) => Path()
    ..moveTo(r.center.dx, r.top)
    ..lineTo(r.right, r.center.dy)
    ..lineTo(r.center.dx, r.bottom)
    ..lineTo(r.left, r.center.dy)
    ..close();

  static Path _polygon(Rect r, int sides) {
    final path = Path();
    final cx = r.center.dx;
    final cy = r.center.dy;
    final radius = r.shortestSide / 2;
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  static Path _plus(Rect r) {
    final t = r.width / 3;
    return Path()
      ..addRRect(
        RRect.fromRectXY(
          Rect.fromLTWH(r.left + t, r.top, t, r.height),
          4,
          4,
        ),
      )
      ..addRRect(
        RRect.fromRectXY(
          Rect.fromLTWH(r.left, r.top + t, r.width, t),
          4,
          4,
        ),
      );
  }
}
