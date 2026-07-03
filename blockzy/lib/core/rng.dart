/// Deterministic, seedable pseudo-random generator.
///
/// The engine must be reproducible so Challenge Mode produces an identical
/// board for every player on a given calendar day. Dart's built-in [Random]
/// is seedable too, but wrapping it here keeps a single choke-point and lets
/// us expose game-friendly helpers.
library;

import 'dart:math' as math;

class SeededRng {
  SeededRng(this.seed) : _random = math.Random(seed);

  final int seed;
  final math.Random _random;

  /// Uniform integer in `[0, max)`.
  int nextInt(int max) => _random.nextInt(max);

  /// Uniform double in `[0, 1)`.
  double nextDouble() => _random.nextDouble();

  /// Uniformly picks one element from a non-empty list.
  T pick<T>(List<T> items) {
    assert(items.isNotEmpty, 'Cannot pick from an empty list');
    return items[_random.nextInt(items.length)];
  }

  /// Fisher–Yates shuffle (in place) using this generator.
  void shuffle<T>(List<T> items) {
    for (var i = items.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = items[i];
      items[i] = items[j];
      items[j] = tmp;
    }
  }
}

/// Builds a stable daily seed from a date (used by Challenge Mode).
int dailySeed(DateTime date) {
  // Local calendar day -> YYYYMMDD integer. Stable regardless of time of day.
  return date.year * 10000 + date.month * 100 + date.day;
}
