/// Adventure Mode engine — wraps [GameEngine] with a level objective, a move
/// limit, star rating and win/lose evaluation.
library;

import '../../core/rng.dart';
import '../board.dart';
import '../candy.dart';
import '../levels/level_def.dart';
import '../stone_swap.dart';
import 'game_engine.dart';

/// Outcome of an Adventure level after it ends.
class LevelResult {
  const LevelResult({
    required this.won,
    required this.stars,
    required this.score,
    required this.movesUsed,
    required this.xpEarned,
  });

  final bool won;
  final int stars; // 0..3
  final int score;
  final int movesUsed;
  final int xpEarned;
}

class AdventureEngine {
  AdventureEngine(this.level, {CandyRemap? remap, int? seed})
      : engine = GameEngine(
          rng: SeededRng(seed ?? level.number * 7919),
          startingDifficulty: level.difficulty,
          remap: remap,
          board: _buildBoard(level),
        );

  final LevelDef level;
  final GameEngine engine;

  int _collected = 0; // candies of the target colour (collectCandy)
  int _linesCleared = 0; // total lines (clearLines)
  bool _finished = false;

  int get objectiveProgress {
    switch (level.objective.kind) {
      case ObjectiveKind.score:
        return engine.score;
      case ObjectiveKind.collectCandy:
        return _collected;
      case ObjectiveKind.clearLines:
        return _linesCleared;
      case ObjectiveKind.clearObstacles:
        return level.objective.target - engine.board.remainingObstacles;
    }
  }

  bool get objectiveMet => objectiveProgress >= level.objective.target;

  int get movesRemaining => level.moveLimit - engine.movesUsed;

  bool get finished => _finished;

  /// Places a piece and updates objective tracking. Returns the raw
  /// [MoveOutcome] plus flags via the engine getters.
  MoveOutcome? place(int trayIndex, int col, int row) {
    if (_finished) return null;
    final outcome = engine.place(trayIndex, col, row);
    if (outcome == null) return null;

    // Track objective-specific progress.
    final target = level.objective.candyType;
    if (target != null) {
      _collected += outcome.placement.candiesClearedByType[target] ?? 0;
    }
    _linesCleared += outcome.placement.combo;

    // A level ends when the objective is met (win) or the player is out of
    // moves / the board is jammed (lose, if objective not yet met).
    if (objectiveMet) {
      _finished = true;
    } else if (movesRemaining <= 0 || outcome.gameOver) {
      _finished = true;
    }
    return outcome;
  }

  /// Evaluates the final result once [finished] is true.
  LevelResult evaluate() {
    final won = objectiveMet;
    final stars = won ? _stars() : 0;
    // 3-star clears grant full XP; fewer stars grant proportionally less but
    // never below the 100 floor guaranteed by the level's xpReward math.
    final xp = won
        ? (level.xpReward * (0.6 + 0.2 * stars)).round().clamp(100, 1 << 30)
        : 0;
    return LevelResult(
      won: won,
      stars: stars,
      score: engine.score,
      movesUsed: engine.movesUsed,
      xpEarned: xp,
    );
  }

  /// Stars are earned by beating the objective with moves to spare (efficiency)
  /// or by overshooting a score/collection target.
  int _stars() {
    final o = level.objective;
    if (o.kind == ObjectiveKind.score || o.kind == ObjectiveKind.collectCandy) {
      final p = objectiveProgress;
      if (p >= level.starThresholds[2]) return 3;
      if (p >= level.starThresholds[1]) return 2;
      return 1;
    }
    // For line/obstacle goals, reward efficiency (moves left).
    final spareRatio = movesRemaining / level.moveLimit;
    if (spareRatio >= 0.4) return 3;
    if (spareRatio >= 0.2) return 2;
    return 1;
  }

  /// Builds the starting board, stamping obstacles for obstacle levels.
  static Board _buildBoard(LevelDef level) {
    final board = Board.standard();
    final seed = level.obstacleSeed;
    if (seed == null) return board;

    final rng = SeededRng(seed);
    var toPlace = level.objective.kind == ObjectiveKind.clearObstacles
        ? level.objective.target
        : (2 + level.difficulty);
    var guard = 0;
    while (toPlace > 0 && guard < 500) {
      guard++;
      final col = rng.nextInt(board.size);
      final row = rng.nextInt(board.size);
      final cell = board.at(col, row);
      if (cell.isEmpty) {
        // Alternate between locked tiles and jelly for variety.
        if (rng.nextBool2()) {
          cell.locked = true;
        } else {
          cell.jelly = 1;
        }
        toPlace--;
      }
    }
    return board;
  }
}

extension on SeededRng {
  bool nextBool2() => nextInt(2) == 0;
}
