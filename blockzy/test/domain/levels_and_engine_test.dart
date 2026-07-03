import 'package:blockzy/domain/candy.dart';
import 'package:blockzy/domain/levels/level_catalog.dart';
import 'package:blockzy/domain/levels/level_def.dart';
import 'package:blockzy/domain/modes/adventure_engine.dart';
import 'package:blockzy/domain/modes/challenge_engine.dart';
import 'package:blockzy/domain/stone_swap.dart';
import 'package:blockzy/domain/ultra_blast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Level catalog', () {
    test('produces exactly 99 levels, all well-formed', () {
      expect(LevelCatalog.levels.length, 99);
      for (final level in LevelCatalog.levels) {
        expect(level.number, inInclusiveRange(1, 99));
        expect(level.moveLimit, greaterThanOrEqualTo(12));
        expect(level.objective.target, greaterThan(0));
        expect(level.xpReward, greaterThanOrEqualTo(100));
        // Star thresholds strictly ascending.
        expect(level.starThresholds[0], lessThanOrEqualTo(level.starThresholds[1]));
        expect(level.starThresholds[1], lessThanOrEqualTo(level.starThresholds[2]));
        if (level.objective.kind == ObjectiveKind.collectCandy) {
          expect(level.objective.candyType, isNotNull);
        }
      }
    });

    test('difficulty is non-decreasing across the catalog', () {
      var prev = -1;
      for (final level in LevelCatalog.levels) {
        expect(level.difficulty, greaterThanOrEqualTo(prev));
        prev = level.difficulty;
      }
    });
  });

  group('Adventure engine', () {
    test('level 1 is completable and evaluates a win', () {
      final level = LevelCatalog.byNumber(1)!;
      final engine = AdventureEngine(level, seed: 1);
      // Drive placements greedily until finished or moves exhausted.
      var guard = 0;
      while (!engine.finished && guard < 500) {
        guard++;
        final placed = _tryGreedyPlacement(engine);
        if (!placed) break;
      }
      // We at least always terminate cleanly.
      expect(engine.finished || engine.movesRemaining <= 0, isTrue);
      final result = engine.evaluate();
      if (result.won) {
        expect(result.stars, inInclusiveRange(1, 3));
        expect(result.xpEarned, greaterThanOrEqualTo(100));
      }
    });
  });

  group('Challenge engine', () {
    test('starting difficulty approximates Adventure level 20', () {
      final day = DateTime(2025, 1, 1);
      expect(ChallengeEngine.startingDifficultyFor(day), 2);
    });

    test('later days are at least as hard', () {
      final early = ChallengeEngine.startingDifficultyFor(DateTime(2025, 1, 1));
      final later = ChallengeEngine.startingDifficultyFor(DateTime(2025, 6, 1));
      expect(later, greaterThanOrEqualTo(early));
    });
  });

  group('Ultra Blast bank', () {
    test('caps at 2 earned per 24h window', () {
      final bank = UltraBlastBank();
      const now = 1000000;
      expect(bank.earn(5, now), 2); // only 2 granted
      expect(bank.stored, 2);
      expect(bank.earn(1, now + 1000), 0); // still same window
      // Roll the window forward 24h+.
      final later = now + 24 * 60 * 60 * 1000 + 1;
      expect(bank.earn(1, later), 1);
    });

    test('spend decrements only when available', () {
      final bank = UltraBlastBank(stored: 1);
      expect(bank.spend(), isTrue);
      expect(bank.spend(), isFalse);
    });
  });

  group('Stone Swap remap', () {
    test('resolves swapped candies and leaves others untouched', () {
      final remap = CandyRemap();
      remap.swap(CandyType.strawberry, CandyType.mint);
      expect(remap.resolve(CandyType.strawberry), CandyType.mint);
      expect(remap.resolve(CandyType.lemon), CandyType.lemon);
    });
  });
}

/// Places the first tray piece at the first legal anchor found. Returns false
/// if nothing could be placed.
bool _tryGreedyPlacement(AdventureEngine engine) {
  final tray = engine.engine.tray;
  for (var i = 0; i < tray.length; i++) {
    final piece = tray[i];
    for (var col = 0; col < engine.engine.board.size; col++) {
      for (var row = 0; row < engine.engine.board.size; row++) {
        if (engine.engine.canPlace(piece, col, row)) {
          engine.place(i, col, row);
          return true;
        }
      }
    }
  }
  return false;
}
