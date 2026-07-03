/// Stone Swap — the reward granted after every completed Adventure level.
///
/// The player may replace one candy type with another. The mapping is applied
/// to all subsequently-generated candies. This is a pure remap table so it is
/// trivially testable and serialisable.
library;

import 'candy.dart';

class CandyRemap {
  CandyRemap([Map<CandyType, CandyType>? initial])
      : _map = {...?initial};

  final Map<CandyType, CandyType> _map;

  /// Records a swap: every future [from] candy becomes [to].
  ///
  /// Existing chained mappings are followed so swaps compose sensibly.
  void swap(CandyType from, CandyType to) {
    _map[from] = to;
  }

  /// Resolves a candy through the remap table (identity if unmapped).
  CandyType resolve(CandyType candy) => _map[candy] ?? candy;

  Map<CandyType, CandyType> get entries => Map.unmodifiable(_map);

  bool get isEmpty => _map.isEmpty;
}
