/// Adventure level definition — pure data describing one of the 99 levels.
library;

import '../candy.dart';

/// The kind of objective a level asks of the player.
enum ObjectiveKind {
  /// Reach a target score.
  score,

  /// Clear a target number of candies of a specific [Objective.candyType].
  collectCandy,

  /// Clear a target number of lines (rows+cols).
  clearLines,

  /// Clear all obstacle cells (locked/jelly) on the starting board.
  clearObstacles,
}

class Objective {
  const Objective({
    required this.kind,
    required this.target,
    this.candyType,
  });

  final ObjectiveKind kind;

  /// The numeric goal (score, candies, lines, or obstacle count).
  final int target;

  /// Only set for [ObjectiveKind.collectCandy].
  final CandyType? candyType;
}

/// Full definition of an Adventure level.
class LevelDef {
  const LevelDef({
    required this.number,
    required this.objective,
    required this.moveLimit,
    required this.difficulty,
    required this.starThresholds,
    required this.xpReward,
    this.obstacleSeed,
    this.introducesMechanic,
  });

  /// 1-based level number (1..99).
  final int number;

  final Objective objective;

  /// Maximum number of pieces the player may place.
  final int moveLimit;

  /// Difficulty index driving piece complexity and candy palette size.
  final int difficulty;

  /// Score (or objective-progress) thresholds for 1/2/3 stars, ascending.
  /// For non-score objectives, stars are based on moves-to-spare instead
  /// (see AdventureEngine); these three values then represent progress
  /// milestones used by the reward screen.
  final List<int> starThresholds;

  /// XP granted on completion (min 100). Higher levels grant more.
  final int xpReward;

  /// Optional seed used to stamp starting obstacles for this level.
  final int? obstacleSeed;

  /// A short human label naming a mechanic first introduced at this level
  /// (shown in a pre-level tip). Null when nothing new is introduced.
  final String? introducesMechanic;

  bool get hasObstacles =>
      objective.kind == ObjectiveKind.clearObstacles || obstacleSeed != null;
}
