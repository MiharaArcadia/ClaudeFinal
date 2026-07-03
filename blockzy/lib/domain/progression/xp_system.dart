/// Player XP & level progression.
///
/// Two independent quantities (see the design doc):
///  1. Per-game XP *reward* — the XP a completed game/level grants (min 100,
///     scaling with difficulty).
///  2. The level-up *requirement* curve — how much XP each player level costs.
///
/// Requirement curve:  xpToNext(L) = round(200 * L^1.4)  for L in [1, 99].
/// Max player level is 100.
///
/// Why this curve: it is smoothly super-linear (exponent 1.4). Early levels
/// fall in a couple of games (fast dopamine, strong onboarding), while cost
/// grows steadily without the brutal wall of a pure-exponential curve — so
/// level 100 (~4.3M cumulative XP) stays a genuine long-horizon prestige goal
/// that always feels reachable next session. The steady cadence of level-ups
/// keeps the variable-reward loop alive.
library;

import 'dart:math' as math;

class XpSystem {
  const XpSystem();

  static const int maxLevel = 100;

  /// XP required to advance FROM level [level] to [level] + 1.
  /// Returns 0 for the max level (no further progression).
  static int xpToNext(int level) {
    if (level >= maxLevel) return 0;
    if (level < 1) return 0;
    return (200 * math.pow(level, 1.4)).round();
  }

  /// Total cumulative XP needed to first reach [level] (level 1 = 0).
  static int cumulativeToReach(int level) {
    var total = 0;
    for (var l = 1; l < level; l++) {
      total += xpToNext(l);
    }
    return total;
  }

  /// Resolves a running total of lifetime XP into a level + progress within it.
  static LevelState resolve(int totalXp) {
    var level = 1;
    var remaining = totalXp;
    while (level < maxLevel) {
      final need = xpToNext(level);
      if (remaining < need) break;
      remaining -= need;
      level++;
    }
    final need = xpToNext(level);
    return LevelState(
      level: level,
      xpIntoLevel: remaining,
      xpForLevel: need,
      isMax: level >= maxLevel,
    );
  }

  /// The XP reward a completed game grants.
  ///
  /// Guarantees the brief's rule: minimum 100, and higher difficulty grants
  /// increasingly more. [difficulty] is the mode's difficulty index; [stars]
  /// (0..3) and [bestCombo] add satisfying bonuses.
  static int rewardFor({
    required int difficulty,
    int stars = 0,
    int bestCombo = 0,
  }) {
    final base = 100 + (difficulty * 12);
    final starBonus = stars * 25;
    final comboBonus = bestCombo > 1 ? (bestCombo - 1) * 15 : 0;
    return base + starBonus + comboBonus;
  }
}

/// A resolved snapshot of the player's level and progress within it.
class LevelState {
  const LevelState({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForLevel,
    required this.isMax,
  });

  final int level;
  final int xpIntoLevel;
  final int xpForLevel;
  final bool isMax;

  /// 0..1 progress toward the next level (1.0 at max level).
  double get progress =>
      isMax || xpForLevel == 0 ? 1.0 : xpIntoLevel / xpForLevel;
}
