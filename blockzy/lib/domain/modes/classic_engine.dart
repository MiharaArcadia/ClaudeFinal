/// Classic Mode — endless play with a rising difficulty ramp and a high score.
library;

import '../../core/rng.dart';
import '../stone_swap.dart';
import 'game_engine.dart';

class ClassicEngine {
  ClassicEngine({int? seed, CandyRemap? remap})
      : engine = GameEngine(
          rng: SeededRng(seed ?? DateTime.now().millisecondsSinceEpoch),
          startingDifficulty: 0,
          remap: remap,
          difficultyPolicy: _classicRamp,
        );

  final GameEngine engine;

  /// Difficulty rises with score: one step per ~1,500 points, capped.
  static int _classicRamp(int score, int movesUsed) {
    final d = score ~/ 1500;
    return d.clamp(0, 10);
  }
}
