/// Bridges the pure-Dart game engine to the UI: routes placement intents,
/// spawns juice (particles/shake/floating scores), plays SFX/haptics, and
/// exposes everything the [GameScreen] needs to render and react.
///
/// Timing (the ticker) is owned by the screen, which calls [tick]; this keeps
/// the controller free of Flutter ticker plumbing and easy to reason about.
library;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../domain/board.dart';
import '../../domain/candy.dart';
import '../../domain/levels/level_def.dart';
import '../../domain/modes/adventure_engine.dart';
import '../../domain/modes/game_engine.dart';
import '../../domain/piece.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../effects/effects.dart';

enum GameMode { classic, adventure, challenge }

/// Board pixel geometry, set by the screen once it lays out.
class BoardGeometry {
  const BoardGeometry({required this.origin, required this.cellSize});
  final Offset origin;
  final double cellSize;

  Offset cellCenter(int col, int row) => Offset(
        origin.dx + (col + 0.5) * cellSize,
        origin.dy + (row + 0.5) * cellSize,
      );

  /// Converts a global-ish local point to a board (col,row), or null if outside.
  ({int col, int row})? hitTest(Offset p, int size) {
    final col = ((p.dx - origin.dx) / cellSize).floor();
    final row = ((p.dy - origin.dy) / cellSize).floor();
    if (col < 0 || row < 0 || col >= size || row >= size) return null;
    return (col: col, row: row);
  }
}

class GameController extends ChangeNotifier {
  GameController({
    required this.mode,
    required this.engine,
    required this.audio,
    required this.haptics,
    required this.effects,
    this.adventure,
  });

  final GameMode mode;
  final GameEngine engine;
  final AudioService audio;
  final HapticService haptics;
  final EffectsController effects;

  /// Present only in Adventure mode (objective tracking).
  final AdventureEngine? adventure;

  BoardGeometry? geometry;

  // Ultra Blast targeting.
  bool _ultraTargeting = false;
  bool get ultraTargeting => _ultraTargeting;

  LevelDef? get level => adventure?.level;

  bool get isOver => adventure?.finished ?? engine.gameOver;

  int get score => engine.score;
  List<Piece> get tray => engine.tray;

  /// A repaint signal the painters listen to (bumped every visual change/frame).
  final ValueNotifier<int> repaint = ValueNotifier<int>(0);

  void setGeometry(BoardGeometry g) => geometry = g;

  /// Whether tray piece [index] can be dropped with its anchor at (col,row).
  bool canPlaceAnchor(int index, int col, int row) {
    if (index < 0 || index >= tray.length) return false;
    return engine.canPlace(tray[index], col, row);
  }

  /// Commits a placement and fires all feedback. Returns the outcome.
  MoveOutcome? placePiece(int index, int col, int row) {
    final outcome =
        adventure != null ? adventure!.place(index, col, row) : engine.place(index, col, row);
    if (outcome == null) return null;

    _spawnPlacementJuice(outcome);
    notifyListeners();
    return outcome;
  }

  void _spawnPlacementJuice(MoveOutcome outcome) {
    final geo = geometry;
    audio.play(Sfx.candyPop);

    final placement = outcome.placement;
    if (placement.anyCleared && geo != null) {
      // Particles at each cleared cell, coloured by what was there.
      for (final cell in placement.clearedCells) {
        final center = geo.cellCenter(cell.col, cell.row);
        effects.explode(center, _colorForCell(cell.col, cell.row, placement));
      }
      // Floating total near the board centre-ish.
      final anchor = geo.cellCenter(
        engine.board.size ~/ 2,
        engine.board.size ~/ 2,
      );
      effects.addFloatingScore(
        anchor,
        placement.gainedScore,
        BlockzyColors.accentGold,
      );

      // Shake + sound scale with combo size.
      effects.shake(6.0 + outcome.bestCombo * 4.0);
      if (outcome.placement.combo >= 2) {
        audio.play(Sfx.combo);
        haptics.fire(Haptic.combo);
      } else {
        audio.play(Sfx.lineClear);
        haptics.fire(Haptic.medium);
      }

      if (outcome.perfectClear) {
        audio.play(Sfx.victory);
        haptics.fire(Haptic.success);
        effects.shake(28);
      }
    } else {
      haptics.fire(Haptic.light);
    }
  }

  Color _colorForCell(int col, int row, PlacementResult placement) {
    // The cell is already cleared; approximate its colour from the dominant
    // cleared type for a pleasing burst.
    final byType = placement.candiesClearedByType;
    if (byType.isEmpty) return BlockzyColors.primary;
    final dominant =
        byType.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return Color(dominant.defaultColorValue);
  }

  // --- Ultra Blast ----------------------------------------------------------

  void enterUltraTargeting() {
    if (isOver) return;
    _ultraTargeting = true;
    haptics.fire(Haptic.selection);
    notifyListeners();
  }

  void cancelUltraTargeting() {
    _ultraTargeting = false;
    notifyListeners();
  }

  /// Executes an Ultra Blast on [row]. Returns candies cleared (for particles).
  Map<CandyType, int> ultraBlastRow(int row) {
    final removed = engine.ultraBlastRow(row);
    final geo = geometry;
    if (geo != null) {
      for (var col = 0; col < engine.board.size; col++) {
        effects.explode(
          geo.cellCenter(col, row),
          BlockzyColors.secondary,
          count: 18,
        );
      }
      effects.shake(30);
    }
    _ultraTargeting = false;
    notifyListeners();
    return removed;
  }

  /// Advances effects; returns true if a repaint is still needed next frame.
  bool tick(double dt) {
    final alive = effects.update(dt);
    repaint.value++;
    return alive;
  }

  @override
  void dispose() {
    repaint.dispose();
    super.dispose();
  }
}
