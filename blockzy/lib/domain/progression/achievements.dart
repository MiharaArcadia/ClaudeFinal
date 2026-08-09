/// Achievement definitions and evaluation.
///
/// Achievements are pure data + a predicate over an [AchievementStats]
/// snapshot, so they are trivially testable and easy to extend. The presentation
/// layer watches for newly-satisfied achievements and fires a celebration toast.
library;

/// A lightweight, serialisable snapshot of everything achievements can read.
/// Populated from the persisted statistics.
class AchievementStats {
  const AchievementStats({
    this.gamesWon = 0,
    this.highestCombo = 0,
    this.highestScore = 0,
    this.totalCandiesCleared = 0,
    this.adventureLevelsCompleted = 0,
    this.challengeDaysCompleted = 0,
    this.playerLevel = 1,
    this.perfectLevels = 0,
    this.dayStreak = 0,
  });

  final int gamesWon;
  final int highestCombo;
  final int highestScore;
  final int totalCandiesCleared;
  final int adventureLevelsCompleted;
  final int challengeDaysCompleted;
  final int playerLevel;
  final int perfectLevels;
  final int dayStreak;
}

/// How urgent/long-term an achievement feels (for grouping in the UI).
enum AchievementTier { short, medium, long }

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.isUnlocked,
    required this.progress,
  });

  final String id;
  final String title;
  final String description;
  final AchievementTier tier;

  /// Whether [stats] satisfies this achievement.
  final bool Function(AchievementStats stats) isUnlocked;

  /// 0..1 progress toward the achievement (for progress bars).
  final double Function(AchievementStats stats) progress;
}

double _ratio(num value, num target) =>
    target <= 0 ? 1 : (value / target).clamp(0, 1).toDouble();

/// The full achievement catalogue — short, medium and long-term goals.
class Achievements {
  Achievements._();

  static final List<Achievement> all = [
    Achievement(
      id: 'first_victory',
      title: 'First Victory',
      description: 'Win your first game.',
      tier: AchievementTier.short,
      isUnlocked: (s) => s.gamesWon >= 1,
      progress: (s) => _ratio(s.gamesWon, 1),
    ),
    Achievement(
      id: 'combo_master',
      title: 'Combo Master',
      description: 'Clear 4 lines in a single move.',
      tier: AchievementTier.medium,
      isUnlocked: (s) => s.highestCombo >= 4,
      progress: (s) => _ratio(s.highestCombo, 4),
    ),
    Achievement(
      id: 'candy_collector',
      title: 'Candy Collector',
      description: 'Clear 1,000 candies in total.',
      tier: AchievementTier.medium,
      isUnlocked: (s) => s.totalCandiesCleared >= 1000,
      progress: (s) => _ratio(s.totalCandiesCleared, 1000),
    ),
    Achievement(
      id: 'candies_10k',
      title: '10,000 Candies',
      description: 'Clear 10,000 candies in total.',
      tier: AchievementTier.long,
      isUnlocked: (s) => s.totalCandiesCleared >= 10000,
      progress: (s) => _ratio(s.totalCandiesCleared, 10000),
    ),
    Achievement(
      id: 'candies_100k',
      title: '100,000 Candies',
      description: 'Clear 100,000 candies in total.',
      tier: AchievementTier.long,
      isUnlocked: (s) => s.totalCandiesCleared >= 100000,
      progress: (s) => _ratio(s.totalCandiesCleared, 100000),
    ),
    Achievement(
      id: 'adventure_hero',
      title: 'Adventure Hero',
      description: 'Complete 50 Adventure levels.',
      tier: AchievementTier.long,
      isUnlocked: (s) => s.adventureLevelsCompleted >= 50,
      progress: (s) => _ratio(s.adventureLevelsCompleted, 50),
    ),
    Achievement(
      id: 'challenge_champion',
      title: 'Challenge Champion',
      description: 'Complete 10 daily Challenges.',
      tier: AchievementTier.long,
      isUnlocked: (s) => s.challengeDaysCompleted >= 10,
      progress: (s) => _ratio(s.challengeDaysCompleted, 10),
    ),
    Achievement(
      id: 'level_100',
      title: 'Level 100',
      description: 'Reach the maximum player level.',
      tier: AchievementTier.long,
      isUnlocked: (s) => s.playerLevel >= 100,
      progress: (s) => _ratio(s.playerLevel, 100),
    ),
    Achievement(
      id: 'perfect_level',
      title: 'Perfect Level',
      description: 'Finish an Adventure level with 3 stars.',
      tier: AchievementTier.medium,
      isUnlocked: (s) => s.perfectLevels >= 1,
      progress: (s) => _ratio(s.perfectLevels, 1),
    ),
    Achievement(
      id: 'five_day_streak',
      title: 'Five Day Streak',
      description: 'Play on 5 consecutive days.',
      tier: AchievementTier.medium,
      isUnlocked: (s) => s.dayStreak >= 5,
      progress: (s) => _ratio(s.dayStreak, 5),
    ),
    Achievement(
      id: 'high_scorer',
      title: 'High Scorer',
      description: 'Score 5,000 in a single game.',
      tier: AchievementTier.medium,
      isUnlocked: (s) => s.highestScore >= 5000,
      progress: (s) => _ratio(s.highestScore, 5000),
    ),
  ];

  /// Returns the ids of achievements satisfied by [stats].
  static Set<String> unlockedIds(AchievementStats stats) =>
      all.where((a) => a.isUnlocked(stats)).map((a) => a.id).toSet();
}
