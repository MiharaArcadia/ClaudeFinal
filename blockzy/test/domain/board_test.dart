import 'package:blockzy/domain/board.dart';
import 'package:blockzy/domain/candy.dart';
import 'package:blockzy/domain/piece.dart';
import 'package:blockzy/domain/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

int _score(int placed, int lines, int candies) =>
    const Scoring().scoreFor(placed, lines, candies);

void main() {
  group('Board placement', () {
    test('canPlaceAt respects bounds and occupancy', () {
      final board = Board.standard();
      const dot = PieceShape('dot', [Cell(0, 0)]);
      expect(board.canPlaceAt(dot, 0, 0), isTrue);
      expect(board.canPlaceAt(dot, 8, 0), isFalse); // out of bounds
      board.at(0, 0).candy = CandyType.lemon;
      expect(board.canPlaceAt(dot, 0, 0), isFalse); // occupied
    });

    test('cannot place onto a locked cell', () {
      final board = Board.standard();
      board.at(1, 1).locked = true;
      const square = PieceShape('square', [
        Cell(0, 0),
        Cell(1, 0),
        Cell(0, 1),
        Cell(1, 1),
      ]);
      expect(board.canPlaceAt(square, 0, 0), isFalse);
    });
  });

  group('Line clearing', () {
    test('completing a row clears it and reports candies', () {
      final board = Board.standard();
      // Fill row 0 except the last column.
      for (var col = 0; col < 7; col++) {
        board.at(col, 0).candy = CandyType.strawberry;
      }
      final piece = Piece(const PieceShape('dot', [Cell(0, 0)]), CandyType.lime);
      final result = board.place(piece, 7, 0, scoreFor: _score);

      expect(result.clearedRows, [0]);
      expect(result.clearedCols, isEmpty);
      expect(result.candiesCleared, 8);
      // Row is empty again.
      for (var col = 0; col < 8; col++) {
        expect(board.at(col, 0).candy, isNull);
      }
    });

    test('completing a column clears it', () {
      final board = Board.standard();
      for (var row = 0; row < 7; row++) {
        board.at(3, row).candy = CandyType.grape;
      }
      final piece = Piece(const PieceShape('dot', [Cell(0, 0)]), CandyType.mint);
      final result = board.place(piece, 3, 7, scoreFor: _score);
      expect(result.clearedCols, [3]);
      expect(result.combo, 1);
    });

    test('simultaneous row+col counts as combo 2 with dedup at crossing', () {
      final board = Board.standard();
      // Fill row 0 (cols 0..6) and column 0 (rows 1..6). Placing at (7,0) then
      // we still need column 0 completion. Set up a shared-corner scenario:
      for (var col = 1; col < 8; col++) {
        board.at(col, 0).candy = CandyType.lemon; // row 0 missing (0,0)
      }
      for (var row = 1; row < 8; row++) {
        board.at(0, row).candy = CandyType.lemon; // col 0 missing (0,0)
      }
      final piece = Piece(const PieceShape('dot', [Cell(0, 0)]), CandyType.lemon);
      final result = board.place(piece, 0, 0, scoreFor: _score);
      expect(result.clearedRows, contains(0));
      expect(result.clearedCols, contains(0));
      expect(result.combo, 2);
      // 8 + 8 - 1 shared crossing = 15 candies.
      expect(result.candiesCleared, 15);
    });
  });

  group('Game over', () {
    test('reports game over only when no piece fits', () {
      final board = Board.standard();
      // Completely fill the board.
      for (var col = 0; col < 8; col++) {
        for (var row = 0; row < 8; row++) {
          board.at(col, row).candy = CandyType.orange;
        }
      }
      final dot =
          Piece(const PieceShape('dot', [Cell(0, 0)]), CandyType.orange);
      expect(board.isGameOver([dot]), isTrue);

      board.at(4, 4).candy = null; // open one cell
      expect(board.isGameOver([dot]), isFalse);
    });
  });

  group('Ultra Blast', () {
    test('clearRow removes an entire row including obstacles', () {
      final board = Board.standard();
      for (var col = 0; col < 8; col++) {
        board.at(col, 2).candy = CandyType.blueberry;
      }
      board.at(3, 2).locked = true;
      final removed = board.clearRow(2);
      expect(removed[CandyType.blueberry], greaterThan(0));
      for (var col = 0; col < 8; col++) {
        expect(board.at(col, 2).candy, isNull);
        expect(board.at(col, 2).locked, isFalse);
      }
    });
  });
}
