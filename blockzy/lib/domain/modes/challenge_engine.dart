/// Challenge Mode engine — a daily-seeded endless run whose starting difficulty
/// approximates Adventure level ~20 and rises slightly each day.
///
/// Completing the day's challenge grants Ultra Blasts (capped by the bank at
/// 2 per rolling 24h).
library;

import '../../core/rng.dart';
import '../stone_swap.dart';
import 'game_engine.dart';

class ChallengeEngine {
  ChallengeEngine({required DateTime day, CandyRemap? remap})
      : _day = day,
        engine = GameEngine(
          rng: SeededRng(dailySeed(day)),
          startingDifficulty: startingDifficultyFor(day),
          remap: remap,
          difficultyPolicy: (score, moves) {
            final base = startingDifficultyFor(day);
            return (base + score ~/ 2000).clamp(0, 12);
          },
        );

  final DateTime _day;
  final GameEngine engine;

  DateTime get day => _day;

  /// Starting difficulty ≈ Adventure level 20 (difficulty index ~2), plus a
  /// slow daily creep so each day is a touch harder than the last.
  ///
  /// Adventure difficulty index for L20 is (20-1)/9 = 2. We start there and add
  /// a bounded day-based increment.
  static int startingDifficultyFor(DateTime day) {
    const adventure20 = 2;
    // Days since an arbitrary epoch → gentle ramp (+1 every ~10 days), capped.
    final epoch = DateTime(2025, 1, 1);
    final daysSince = day.difference(epoch).inDays;
    final creep = (daysSince ~/ 10).clamp(0, 6);
    return (adventure20 + creep).clamp(2, 10);
  }

  /// How many Ultra Blasts this run has earned (before the bank's daily cap).
  /// Awarded by score tier: 1 at 3,000, a 2nd at 8,000.
  int ultraBlastsEarned() {
    final s = engine.score;
    if (s >= 8000) return 2;
    if (s >= 3000) return 1;
    return 0;
  }
}
