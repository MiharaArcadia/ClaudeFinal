/// The shared, pure-Dart game engine that all three modes build on.
///
/// It owns the board, the current tray, the score/combo state and the
/// candy remap, and exposes intent methods (place, ultraBlastRow) that return
/// rich results for the presentation layer to animate. It never imports
/// Flutter — rendering and timing live in the presentation layer.
library;

import '../board.dart';
import '../candy.dart';
import '../piece.dart';
import '../scoring.dart';
import '../stone_swap.dart';
import '../../core/rng.dart';

/// A snapshot of the engine outcome for a single placement, enriched with
/// meta info the UI/stats layers care about.
class MoveOutcome {
  MoveOutcome({
    required this.placement,
    required this.perfectClear,
    required this.totalScore,
    required this.bestCombo,
    required this.movesUsed,
    required this.gameOver,
  });

  final PlacementResult placement;
  final bool perfectClear;
  final int totalScore;
  final int bestCombo;
  final int movesUsed;
  final bool gameOver;
}

/// Difficulty ramp policy for endless play (Classic). Adventure/Challenge pass
/// a fixed or day-scaled difficulty instead.
typedef DifficultyPolicy = int Function(int score, int movesUsed);

class GameEngine {
  GameEngine({
    required this.rng,
    required int startingDifficulty,
    Scoring? scoring,
    CandyRemap? remap,
    this.difficultyPolicy,
    Board? board,
  })  : _difficulty = startingDifficulty,
        scoring = scoring ?? const Scoring(),
        remap = remap ?? CandyRemap(),
        board = board ?? Board.standard() {
    _generator = PieceGenerator(rng);
    _refillTray();
  }

  final SeededRng rng;
  final Scoring scoring;
  final CandyRemap remap;
  final Board board;

  /// Optional endless ramp; when null the difficulty stays fixed.
  final DifficultyPolicy? difficultyPolicy;

  late final PieceGenerator _generator;
  int _difficulty;
  List<Piece> _tray = [];
  int _score = 0;
  int _bestCombo = 0;
  int _movesUsed = 0;
  int _candiesCleared = 0;
  bool _gameOver = false;

  int get difficulty => _difficulty;
  List<Piece> get tray => List.unmodifiable(_tray);
  int get score => _score;
  int get bestCombo => _bestCombo;
  int get movesUsed => _movesUsed;

  /// Cumulative candies cleared this run (feeds stats + achievements).
  int get candiesCleared => _candiesCleared;
  bool get gameOver => _gameOver;

  /// Whether [piece] can be placed at the given board anchor.
  bool canPlace(Piece piece, int col, int row) =>
      board.canPlaceAt(piece.shape, col, row);

  /// Commits placing tray piece [trayIndex] at (col,row). Caller must ensure it
  /// is a legal placement. Returns a [MoveOutcome], or null if illegal.
  MoveOutcome? place(int trayIndex, int col, int row) {
    if (_gameOver) return null;
    if (trayIndex < 0 || trayIndex >= _tray.length) return null;
    final piece = _tray[trayIndex];
    if (!board.canPlaceAt(piece.shape, col, row)) return null;

    final result = board.place(
      piece,
      col,
      row,
      scoreFor: scoring.scoreFor,
    );

    _movesUsed++;
    _score += result.gainedScore;
    _candiesCleared += result.candiesCleared;
    if (result.combo > _bestCombo) _bestCombo = result.combo;

    // Perfect clear bonus.
    final perfect = result.anyCleared && board.filledCount == 0;
    if (perfect) _score += scoring.perfectClearBonus();

    // Remove the used piece; refill when the tray empties.
    _tray = List.of(_tray)..removeAt(trayIndex);
    if (_tray.isEmpty) {
      _rampDifficulty();
      _refillTray();
    }

    _gameOver = board.isGameOver(_tray);

    return MoveOutcome(
      placement: result,
      perfectClear: perfect,
      totalScore: _score,
      bestCombo: _bestCombo,
      movesUsed: _movesUsed,
      gameOver: _gameOver,
    );
  }

  /// Clears an entire [row] (Ultra Blast). Returns candies removed by type.
  /// Recomputes game-over afterward (a clear can re-open the board).
  Map<CandyType, int> ultraBlastRow(int row) {
    final removed = board.clearRow(row);
    _candiesCleared += removed.values.fold(0, (a, b) => a + b);
    _gameOver = board.isGameOver(_tray);
    return removed;
  }

  void _rampDifficulty() {
    final policy = difficultyPolicy;
    if (policy != null) {
      _difficulty = policy(_score, _movesUsed);
    }
  }

  void _refillTray() {
    final fresh = _generator.tray(_difficulty);
    // Apply the candy remap (Stone Swap) as pieces enter play.
    _tray = fresh
        .map((p) => Piece(p.shape, remap.resolve(p.candy)))
        .toList();
    if (_tray.isNotEmpty) {
      _gameOver = board.isGameOver(_tray);
    }
  }
}
