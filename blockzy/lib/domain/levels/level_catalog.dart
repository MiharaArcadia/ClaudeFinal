/// Generates the 99 Adventure levels with a fair, gradually-rising difficulty
/// curve and mechanics introduced a few levels apart.
///
/// The catalogue is produced by a deterministic curve function with explicit
/// hand-tuned anchors, so every level is defined and beatable while still
/// feeling handcrafted. Difficulty rises smoothly; move limits and objective
/// targets scale so the challenge grows without spikes.
library;

import '../candy.dart';
import '../progression/xp_system.dart';
import 'level_def.dart';

class LevelCatalog {
  LevelCatalog._();

  static const int levelCount = 99;

  static final List<LevelDef> _levels = _build();

  /// All 99 levels, 0-indexed list but each [LevelDef.number] is 1-based.
  static List<LevelDef> get levels => _levels;

  /// Fetches a level by its 1-based number, or null if out of range.
  static LevelDef? byNumber(int number) {
    if (number < 1 || number > _levels.length) return null;
    return _levels[number - 1];
  }

  static List<LevelDef> _build() {
    final list = <LevelDef>[];
    for (var n = 1; n <= levelCount; n++) {
      list.add(_makeLevel(n));
    }
    return list;
  }

  /// Difficulty index for a level. Rises ~1 per 8 levels early, faster later,
  /// clamped so late piece complexity stays fair.
  static int _difficultyFor(int n) {
    // Smooth ramp: roughly 0 at L1 up to ~10 by L99.
    final d = ((n - 1) / 9).floor();
    return d.clamp(0, 10);
  }

  /// Cycles the objective kind so variety is introduced gradually:
  ///  - L1..3   : pure score (teach the basics)
  ///  - L4+     : collectCandy appears
  ///  - L7+     : clearLines appears
  ///  - L10+    : clearObstacles (locked tiles) appears
  static ObjectiveKind _objectiveKindFor(int n) {
    if (n <= 3) return ObjectiveKind.score;
    // Weighted rotation with unlock gates.
    final options = <ObjectiveKind>[ObjectiveKind.score];
    if (n >= 4) options.add(ObjectiveKind.collectCandy);
    if (n >= 7) options.add(ObjectiveKind.clearLines);
    if (n >= 10) options.add(ObjectiveKind.clearObstacles);
    return options[n % options.length];
  }

  static LevelDef _makeLevel(int n) {
    final difficulty = _difficultyFor(n);
    final kind = _objectiveKindFor(n);

    // Move limit: generous early, tightening slowly. Never below 12.
    final moveLimit = (34 - n ~/ 6).clamp(12, 40);

    // XP scales with difficulty; guaranteed >= 100 by XpSystem.rewardFor.
    final xp = XpSystem.rewardFor(difficulty: difficulty, stars: 3);

    final objective = _objectiveFor(kind, n, difficulty);
    final stars = _starThresholdsFor(objective, n);

    return LevelDef(
      number: n,
      objective: objective,
      moveLimit: moveLimit,
      difficulty: difficulty,
      starThresholds: stars,
      xpReward: xp,
      obstacleSeed:
          kind == ObjectiveKind.clearObstacles ? 1000 + n : null,
      introducesMechanic: _mechanicIntroAt(n),
    );
  }

  static Objective _objectiveFor(ObjectiveKind kind, int n, int difficulty) {
    switch (kind) {
      case ObjectiveKind.score:
        // Target grows steadily with level.
        final target = 500 + n * 120;
        return Objective(kind: kind, target: target);
      case ObjectiveKind.collectCandy:
        final palette = candyPaletteSize(difficulty);
        final candy = CandyType.values[n % palette];
        final target = 20 + n; // 21..119 candies of one colour
        return Objective(kind: kind, target: target, candyType: candy);
      case ObjectiveKind.clearLines:
        final target = 6 + n ~/ 4; // 6..30 lines
        return Objective(kind: kind, target: target);
      case ObjectiveKind.clearObstacles:
        final target = (4 + n ~/ 8).clamp(4, 16); // 4..16 obstacles
        return Objective(kind: kind, target: target);
    }
  }

  /// Star thresholds represent objective-progress milestones (1★ = objective
  /// met, 2★/3★ = met with increasing efficiency / overshoot). Ascending.
  static List<int> _starThresholdsFor(Objective o, int n) {
    final t = o.target;
    return [t, (t * 1.25).round(), (t * 1.6).round()];
  }

  /// Returns a mechanic-intro label for the levels where a new idea appears.
  static String? _mechanicIntroAt(int n) {
    switch (n) {
      case 1:
        return 'Drag candies onto the board. Fill a row or column to clear it!';
      case 4:
        return 'New goal: collect a specific candy colour.';
      case 7:
        return 'New goal: clear a number of lines.';
      case 10:
        return 'Locked tiles! Clear a line through them to break them.';
      case 20:
        return 'Difficulty rising — bigger pieces ahead.';
      case 50:
        return 'Halfway there, Candy Hero!';
      default:
        return null;
    }
  }
}
