/// Polyomino piece definitions and generation.
///
/// Mirrors the reference feel: pieces are placed as-is (NO rotation), a tray of
/// three at a time, complexity growing with difficulty. Pure Dart.
library;

import '../core/rng.dart';
import 'candy.dart';

/// An immutable board coordinate offset (relative cell within a piece).
class Cell {
  const Cell(this.col, this.row);
  final int col;
  final int row;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.col == col && other.row == row;

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => '($col,$row)';
}

/// A shape template: a normalised set of occupied cells (top-left anchored).
class PieceShape {
  const PieceShape(this.id, this.cells, {this.difficulty = 0});

  /// Stable identifier (used for analytics/tests). Never reuse ids.
  final String id;

  /// Occupied cells, normalised so the min col and min row are both 0.
  final List<Cell> cells;

  /// Minimum difficulty tier at which this shape may appear.
  final int difficulty;

  int get width => cells.map((c) => c.col).fold(0, (a, b) => a > b ? a : b) + 1;
  int get height =>
      cells.map((c) => c.row).fold(0, (a, b) => a > b ? a : b) + 1;

  int get size => cells.length;
}

/// A concrete, colourised piece sitting in the tray, ready to be dragged.
class Piece {
  Piece(this.shape, this.candy);

  final PieceShape shape;
  final CandyType candy;

  int get size => shape.size;
}

/// The canonical shape catalogue. Kept deliberately close to the reference set:
/// singles, dominoes, trominoes, tetrominoes, small squares, and a few larger
/// awkward shapes gated behind higher difficulty.
class PieceCatalog {
  PieceCatalog._();

  static const List<PieceShape> all = [
    // 1 cell
    PieceShape('dot', [Cell(0, 0)]),
    // 2 cells
    PieceShape('h2', [Cell(0, 0), Cell(1, 0)]),
    PieceShape('v2', [Cell(0, 0), Cell(0, 1)]),
    // 3 cells — lines
    PieceShape('h3', [Cell(0, 0), Cell(1, 0), Cell(2, 0)]),
    PieceShape('v3', [Cell(0, 0), Cell(0, 1), Cell(0, 2)]),
    // 3 cells — corners
    PieceShape(
      'corner_tl',
      [Cell(0, 0), Cell(1, 0), Cell(0, 1)],
      difficulty: 1,
    ),
    PieceShape(
      'corner_tr',
      [Cell(0, 0), Cell(1, 0), Cell(1, 1)],
      difficulty: 1,
    ),
    PieceShape(
      'corner_bl',
      [Cell(0, 1), Cell(0, 0), Cell(1, 1)],
      difficulty: 1,
    ),
    PieceShape(
      'corner_br',
      [Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      difficulty: 1,
    ),
    // 4 cells — square
    PieceShape(
      'square',
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      difficulty: 1,
    ),
    // 4 cells — lines
    PieceShape(
      'h4',
      [Cell(0, 0), Cell(1, 0), Cell(2, 0), Cell(3, 0)],
      difficulty: 2,
    ),
    PieceShape(
      'v4',
      [Cell(0, 0), Cell(0, 1), Cell(0, 2), Cell(0, 3)],
      difficulty: 2,
    ),
    // 4 cells — L / J / T / S / Z (tetrominoes), each at fixed orientation.
    PieceShape(
      'l_piece',
      [Cell(0, 0), Cell(0, 1), Cell(0, 2), Cell(1, 2)],
      difficulty: 3,
    ),
    PieceShape(
      'j_piece',
      [Cell(1, 0), Cell(1, 1), Cell(1, 2), Cell(0, 2)],
      difficulty: 3,
    ),
    PieceShape(
      't_piece',
      [Cell(0, 0), Cell(1, 0), Cell(2, 0), Cell(1, 1)],
      difficulty: 3,
    ),
    PieceShape(
      's_piece',
      [Cell(1, 0), Cell(2, 0), Cell(0, 1), Cell(1, 1)],
      difficulty: 4,
    ),
    PieceShape(
      'z_piece',
      [Cell(0, 0), Cell(1, 0), Cell(1, 1), Cell(2, 1)],
      difficulty: 4,
    ),
    // 5 cells — big line + plus (late game pressure).
    PieceShape(
      'h5',
      [Cell(0, 0), Cell(1, 0), Cell(2, 0), Cell(3, 0), Cell(4, 0)],
      difficulty: 5,
    ),
    PieceShape(
      'v5',
      [Cell(0, 0), Cell(0, 1), Cell(0, 2), Cell(0, 3), Cell(0, 4)],
      difficulty: 5,
    ),
    PieceShape(
      'plus',
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      difficulty: 6,
    ),
    // 9 cells — the dreaded 3x3 block (very late game).
    PieceShape(
      'square3',
      [
        Cell(0, 0), Cell(1, 0), Cell(2, 0),
        Cell(0, 1), Cell(1, 1), Cell(2, 1),
        Cell(0, 2), Cell(1, 2), Cell(2, 2),
      ],
      difficulty: 8,
    ),
  ];

  /// Shapes eligible at [difficulty] (all with `shape.difficulty <= difficulty`).
  static List<PieceShape> eligible(int difficulty) =>
      all.where((s) => s.difficulty <= difficulty).toList(growable: false);
}

/// Generates tray pieces. Deterministic given the [SeededRng].
class PieceGenerator {
  PieceGenerator(this.rng);

  final SeededRng rng;

  /// Produces a tray of [count] pieces for the given [difficulty].
  ///
  /// Colours are drawn from the difficulty-scaled palette so early boards use
  /// fewer candy colours (easier to line up).
  List<Piece> tray(int difficulty, {int count = 3}) {
    final shapes = PieceCatalog.eligible(difficulty);
    final paletteSize = candyPaletteSize(difficulty);
    final palette = CandyType.values.take(paletteSize).toList();
    return List.generate(count, (_) {
      final shape = rng.pick(shapes);
      final candy = rng.pick(palette);
      return Piece(shape, candy);
    });
  }
}
