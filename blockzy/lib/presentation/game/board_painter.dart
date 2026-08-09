/// Renders the 8×8 board: grid cells, placed candies, obstacles, the drag
/// preview (ghost), and Ultra Blast row highlighting.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../domain/board.dart';
import '../../domain/candy.dart';
import '../../domain/piece.dart';
import 'candy_painter.dart';

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.images,
    required this.repaint,
    this.previewCells = const [],
    this.previewCandy,
    this.previewValid = true,
    this.ultraTargetRow,
  }) : super(repaint: repaint);

  final Board board;
  final Map<CandyType, ui.Image?> images;
  final Listenable repaint;

  /// Ghost preview: the absolute (col,row) cells the dragged piece would fill.
  final List<Cell> previewCells;
  final CandyType? previewCandy;
  final bool previewValid;

  /// When Ultra Blast targeting, the row currently under the finger.
  final int? ultraTargetRow;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / board.size;
    final gridPaint = Paint()..color = BlockzyColors.gridEmpty;
    final radius = Radius.circular(cell * 0.18);

    // 1. Empty grid cells (soft rounded wells).
    for (var col = 0; col < board.size; col++) {
      for (var row = 0; row < board.size; row++) {
        final rect = _cellRect(col, row, cell);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(cell * 0.04), radius),
          gridPaint,
        );
      }
    }

    // 2. Ultra Blast row highlight.
    if (ultraTargetRow != null) {
      final hi = Paint()
        ..color = BlockzyColors.secondary.withValues(alpha: 0.28);
      final rect = Rect.fromLTWH(0, ultraTargetRow! * cell, size.width, cell);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), hi);
    }

    // 3. Placed candies + obstacles.
    for (var col = 0; col < board.size; col++) {
      for (var row = 0; row < board.size; row++) {
        final bc = board.at(col, row);
        final rect = _cellRect(col, row, cell);
        if (bc.locked) {
          _paintLocked(canvas, rect, radius);
        } else if (bc.jelly > 0 && bc.candy == null) {
          _paintJelly(canvas, rect, radius);
        }
        final candy = bc.candy;
        if (candy != null) {
          CandyPainter.paint(canvas, rect, candy, image: images[candy]);
        }
      }
    }

    // 4. Drag ghost preview.
    final candy = previewCandy;
    if (candy != null && previewCells.isNotEmpty) {
      for (final c in previewCells) {
        if (c.col < 0 ||
            c.row < 0 ||
            c.col >= board.size ||
            c.row >= board.size) {
          continue;
        }
        final rect = _cellRect(c.col, c.row, cell);
        CandyPainter.paint(
          canvas,
          rect,
          candy,
          image: images[candy],
          alpha: previewValid ? 0.55 : 0.25,
          colorOverride: previewValid ? null : BlockzyColors.danger,
        );
      }
    }
  }

  Rect _cellRect(int col, int row, double cell) =>
      Rect.fromLTWH(col * cell, row * cell, cell, cell);

  void _paintLocked(Canvas canvas, Rect rect, Radius radius) {
    final p = Paint()..color = const Color(0xFF4A3B78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(rect.width * 0.06), radius),
      p,
    );
    // A simple lock glyph line.
    final bar = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = rect.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(rect.center.dx - rect.width * 0.15, rect.center.dy),
      Offset(rect.center.dx + rect.width * 0.15, rect.center.dy),
      bar,
    );
  }

  void _paintJelly(Canvas canvas, Rect rect, Radius radius) {
    final p = Paint()
      ..color = BlockzyColors.secondary.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(rect.width * 0.1), radius),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
