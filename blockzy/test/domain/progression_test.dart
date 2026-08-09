import 'package:blockzy/domain/progression/achievements.dart';
import 'package:blockzy/domain/progression/xp_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XP curve', () {
    test('xpToNext matches the documented table', () {
      expect(XpSystem.xpToNext(1), 200);
      // round(200 * 5^1.4) and 10^1.4 etc.
      expect(XpSystem.xpToNext(5), closeTo(1904, 5));
      expect(XpSystem.xpToNext(10), closeTo(5024, 10));
      expect(XpSystem.xpToNext(99), closeTo(121900, 200));
    });

    test('max level has no further requirement', () {
      expect(XpSystem.xpToNext(100), 0);
      expect(XpSystem.xpToNext(101), 0);
    });

    test('resolve maps cumulative XP to the right level', () {
      final atStart = XpSystem.resolve(0);
      expect(atStart.level, 1);
      expect(atStart.xpIntoLevel, 0);

      final afterFirst = XpSystem.resolve(200);
      expect(afterFirst.level, 2);
      expect(afterFirst.xpIntoLevel, 0);

      final partial = XpSystem.resolve(250);
      expect(partial.level, 2);
      expect(partial.xpIntoLevel, 50);
    });

    test('resolve clamps at the max level', () {
      final maxed = XpSystem.resolve(100000000);
      expect(maxed.level, 100);
      expect(maxed.isMax, isTrue);
      expect(maxed.progress, 1.0);
    });

    test('reward is at least 100 and rises with difficulty', () {
      expect(XpSystem.rewardFor(difficulty: 0), greaterThanOrEqualTo(100));
      final easy = XpSystem.rewardFor(difficulty: 0);
      final hard = XpSystem.rewardFor(difficulty: 10);
      expect(hard, greaterThan(easy));
    });
  });

  group('Achievements', () {
    test('first victory unlocks after one win', () {
      const none = AchievementStats();
      const oneWin = AchievementStats(gamesWon: 1);
      expect(Achievements.unlockedIds(none).contains('first_victory'), isFalse);
      expect(
        Achievements.unlockedIds(oneWin).contains('first_victory'),
        isTrue,
      );
    });

    test('progress is bounded 0..1', () {
      const stats = AchievementStats(totalCandiesCleared: 500);
      final collector =
          Achievements.all.firstWhere((a) => a.id == 'candy_collector');
      expect(collector.progress(stats), closeTo(0.5, 0.001));
    });
  });
}
