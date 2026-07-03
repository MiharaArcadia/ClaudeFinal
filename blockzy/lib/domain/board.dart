/// The 8×8 grid model and all placement / clearing / game-over rules.
///
/// This is the beating heart of the game and is intentionally 100% pure Dart
/// (no Flutter) so it is fast, deterministic and fully unit-testable.
library;

import 'candy.dart';
import 'piece.dart';

/// A single grid cell. `candy == null` means empty.
///
/// `locked` models an Adventure obstacle: a locked cell must be cleared (by a
/// line passing through it) before it becomes a normal empty cell; you cannot
/// place onto a locked cell. `jelly` requires being cleared twice.
class BoardCell {
  BoardCell({this.candy, this.locked = false, this.jelly = 0});

  CandyType? candy;
  bool locked;

  /// Remaining jelly layers (0 = none). Each line clear removes one layer.
  int jelly;

  bool get isEmpty => candy == null && !locked && jelly == 0;
  bool get isBlocked => locked; // cannot place here

  BoardCell copy() => BoardCell(candy: candy, locked: locked, jelly: jelly);
}

/// The result of committing a placement — everything the presentation layer
/// needs to animate, plus everything meta-systems need to score.
class PlacementResult {
  PlacementResult({
    required this.clearedRows,
    required this.clearedCols,
    required this.clearedCells,
    required this.candiesCleared,
    required this.candiesClearedByType,
    required this.combo,
    required this.gainedScore,
  });

  final List<int> clearedRows;
  final List<int> clearedCols;

  /// Flat (col,row) coordinates of every cell cleared this move (for particles).
  final List<Cell> clearedCells;

  /// Total candies removed this move.
  final int candiesCleared;

  /// Candies removed this move, broken down by type (for Adventure objectives).
  final Map<CandyType, int> candiesClearedByType;

  /// The number of lines cleared this move (1 line = combo 1, etc.).
  final int combo;

  /// Score awarded for this move (placement + line clears + combo bonus).
  final int gainedScore;

  bool get anyCleared => clearedRows.isNotEmpty || clearedCols.isNotEmpty;
}

class Board {
  Board(this.size) : cells = List.generate(
          size,
          (_) => List.generate(size, (_) => BoardCell()),
        );

  /// Standard board is 8×8, matching the reference.
  factory Board.standard() => Board(8);

  final int size;

  /// `cells[col][row]` — column-major to match the (col,row) [Cell] convention.
  final List<List<BoardCell>> cells;

  BoardCell at(int col, int row) => cells[col][row];

  bool inBounds(int col, int row) =>
      col >= 0 && col < size && row >= 0 && row < size;

  /// True if [shape] can be placed with its top-left anchor at (col,row):
  /// every target cell must be in-bounds, empty of candy, and not locked.
  bool canPlaceAt(PieceShape shape, int anchorCol, int anchorRow) {
    for (final c in shape.cells) {
      final col = anchorCol + c.col;
      final row = anchorRow + c.row;
      if (!inBounds(col, row)) return false;
      final cell = cells[col][row];
      if (cell.candy != null || cell.locked) return false;
    }
    return true;
  }

  /// True if [shape] fits anywhere on the board at all.
  bool canPlaceAnywhere(PieceShape shape) {
    for (var col = 0; col < size; col++) {
      for (var row = 0; row < size; row++) {
        if (canPlaceAt(shape, col, row)) return true;
      }
    }
    return false;
  }

  /// True if NONE of [pieces] fit anywhere — i.e. the run is over.
  bool isGameOver(List<Piece> pieces) =>
      pieces.every((p) => !canPlaceAnywhere(p.shape));

  /// Places [piece] at the anchor (caller must have checked [canPlaceAt]),
  /// then resolves any full rows/columns and returns the [PlacementResult].
  ///
  /// [scoring] converts the raw event into a score; injected so scoring rules
  /// live in one place ([Scoring]).
  PlacementResult place(
    Piece piece,
    int anchorCol,
    int anchorRow, {
    required int Function(int placedCells, int lines, int candiesCleared)
        scoreFor,
  }) {
    // 1. Stamp the candy into the target cells.
    for (final c in piece.shape.cells) {
      cells[anchorCol + c.col][anchorRow + c.row].candy = piece.candy;
    }

    // 2. Detect full rows and columns (a cell counts as filled if it has a
    //    candy; locked cells block a line from completing until cleared).
    final fullRows = <int>[];
    final fullCols = <int>[];
    for (var row = 0; row < size; row++) {
      if (_rowFull(row)) fullRows.add(row);
    }
    for (var col = 0; col < size; col++) {
      if (_colFull(col)) fullCols.add(col);
    }

    // 3. Collect the union of cleared cells (dedup where a row & col cross).
    final clearedCells = <Cell>{};
    for (final row in fullRows) {
      for (var col = 0; col < size; col++) {
        clearedCells.add(Cell(col, row));
      }
    }
    for (final col in fullCols) {
      for (var row = 0; row < size; row++) {
        clearedCells.add(Cell(col, row));
      }
    }

    // 4. Tally cleared candies by type, then wipe the cells (handling jelly).
    final byType = <CandyType, int>{};
    var candiesCleared = 0;
    for (final cell in clearedCells) {
      final bc = cells[cell.col][cell.row];
      final candy = bc.candy;
      if (candy != null) {
        byType.update(candy, (v) => v + 1, ifAbsent: () => 1);
        candiesCleared++;
      }
      _clearCell(bc);
    }

    final lines = fullRows.length + fullCols.length;
    final placedCells = piece.shape.size;
    final gained = scoreFor(placedCells, lines, candiesCleared);

    return PlacementResult(
      clearedRows: fullRows,
      clearedCols: fullCols,
      clearedCells: clearedCells.toList(growable: false),
      candiesCleared: candiesCleared,
      candiesClearedByType: byType,
      combo: lines,
      gainedScore: gained,
    );
  }

  /// Clears an entire row unconditionally (used by Ultra Blast). Returns the
  /// candies removed, by type.
  Map<CandyType, int> clearRow(int row) {
    final byType = <CandyType, int>{};
    for (var col = 0; col < size; col++) {
      final bc = cells[col][row];
      final candy = bc.candy;
      if (candy != null) {
        byType.update(candy, (v) => v + 1, ifAbsent: () => 1);
      }
      // Ultra Blast is powerful: it also strips locked/jelly obstacles.
      bc.candy = null;
      bc.locked = false;
      bc.jelly = 0;
    }
    return byType;
  }

  bool _rowFull(int row) {
    for (var col = 0; col < size; col++) {
      final bc = cells[col][row];
      if (bc.candy == null || bc.locked) return false;
    }
    return true;
  }

  bool _colFull(int col) {
    for (var row = 0; row < size; row++) {
      final bc = cells[col][row];
      if (bc.candy == null || bc.locked) return false;
    }
    return true;
  }

  void _clearCell(BoardCell bc) {
    if (bc.jelly > 0) {
      // First clear removes candy but leaves one less jelly layer behind.
      bc.jelly -= 1;
      bc.candy = null;
      return;
    }
    bc.candy = null;
    bc.locked = false;
  }

  /// Count of remaining obstacle cells (locked or jelly) — for objectives.
  int get remainingObstacles {
    var n = 0;
    for (final col in cells) {
      for (final bc in col) {
        if (bc.locked || bc.jelly > 0) n++;
      }
    }
    return n;
  }

  int get filledCount {
    var n = 0;
    for (final col in cells) {
      for (final bc in col) {
        if (bc.candy != null) n++;
      }
    }
    return n;
  }

  Board copy() {
    final b = Board(size);
    for (var col = 0; col < size; col++) {
      for (var row = 0; row < size; row++) {
        b.cells[col][row] = cells[col][row].copy();
      }
    }
    return b;
  }
}
