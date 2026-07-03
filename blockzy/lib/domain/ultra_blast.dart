/// Ultra Blast — a stored special ability that instantly clears a whole row.
///
/// Earned only from Challenge Mode (max 2 per rolling 24h). Stored in a bank
/// and spendable inside Adventure or Classic. The domain here models the
/// earning cap and the bank; the actual row clear lives on [Board.clearRow].
library;

class UltraBlastBank {
  UltraBlastBank({
    this.stored = 0,
    this.earnedToday = 0,
    this.windowStartEpochMs = 0,
  });

  /// How many Ultra Blasts are currently stored (spendable).
  int stored;

  /// How many have been earned in the current 24h window.
  int earnedToday;

  /// Epoch millis marking the start of the current 24h earning window.
  int windowStartEpochMs;

  static const int maxPerDay = 2;
  static const int _dayMs = 24 * 60 * 60 * 1000;

  /// Rolls the 24h window forward if it has elapsed relative to [nowMs].
  void _refreshWindow(int nowMs) {
    if (windowStartEpochMs == 0 ||
        nowMs - windowStartEpochMs >= _dayMs) {
      windowStartEpochMs = nowMs;
      earnedToday = 0;
    }
  }

  /// How many more can be earned right now.
  int earnableNow(int nowMs) {
    _refreshWindow(nowMs);
    return (maxPerDay - earnedToday).clamp(0, maxPerDay);
  }

  /// Attempts to earn [count] Ultra Blasts, respecting the daily cap.
  /// Returns the number actually granted.
  int earn(int count, int nowMs) {
    _refreshWindow(nowMs);
    final canEarn = (maxPerDay - earnedToday).clamp(0, maxPerDay);
    final granted = count.clamp(0, canEarn);
    earnedToday += granted;
    stored += granted;
    return granted;
  }

  /// Spends one Ultra Blast. Returns true if one was available.
  bool spend() {
    if (stored <= 0) return false;
    stored -= 1;
    return true;
  }
}
