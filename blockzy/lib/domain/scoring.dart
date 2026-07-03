/// Scoring rules — one place so tuning is easy and testable.
///
/// Design goals (from the brief): every move should feel rewarding, and
/// combos/streaks should be strongly celebrated. The numbers below give a
/// gentle base reward for simply placing a piece, a solid reward per line, and
/// an escalating multiplier when several lines clear at once or back-to-back.
library;

class Scoring {
  const Scoring();

  /// Points for each candy that lands on the board (the placement itself).
  static const int perPlacedCell = 1;

  /// Base points for a single cleared line.
  static const int perLine = 10;

  /// Board dimension used to make a "full clear" bonus feel epic.
  static const int fullClearBonus = 300;

  /// Computes the score for a move.
  ///
  /// - [placedCells]: how many candies the piece added.
  /// - [lines]: rows+cols cleared this move (the "combo" count).
  /// - [candiesCleared]: candies removed (for a small volume bonus).
  ///
  /// Multi-line clears scale super-linearly: 1 line ×1, 2 lines ×2, 3 lines
  /// ×3.5, 4+ ramps further — mirroring the reference's satisfying blowups.
  int scoreFor(int placedCells, int lines, int candiesCleared) {
    final placement = placedCells * perPlacedCell;
    if (lines == 0) return placement;

    final lineBase = lines * perLine + candiesCleared;
    final multiplier = comboMultiplier(lines);
    return placement + (lineBase * multiplier).round();
  }

  /// The escalating multiplier for clearing [lines] lines in a single move.
  double comboMultiplier(int lines) {
    switch (lines) {
      case 0:
        return 0;
      case 1:
        return 1.0;
      case 2:
        return 2.0;
      case 3:
        return 3.5;
      case 4:
        return 5.0;
      default:
        // 5+ lines: keep it climbing but bounded.
        return 5.0 + (lines - 4) * 2.0;
    }
  }

  /// Extra bonus applied when the board is completely empty after a move —
  /// a rare, highly satisfying event worth celebrating loudly.
  int perfectClearBonus() => fullClearBonus;
}
