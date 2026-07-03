/// What the player earns when their account level goes up.
///
/// Every level grants coins; milestone levels also unlock cosmetics. Big
/// celebration levels (10/25/50/75/100) unlock the most exciting rewards.
library;

/// The kind of reward a level-up can grant.
enum RewardKind { coins, candySkin, background, frame, effect }

/// A single reward payload.
class LevelReward {
  const LevelReward({
    required this.kind,
    required this.amount,
    this.cosmeticId,
    this.isMilestone = false,
  });

  final RewardKind kind;

  /// For [RewardKind.coins] the coin amount; otherwise 1.
  final int amount;

  /// Cosmetic identifier when the reward unlocks a cosmetic.
  final String? cosmeticId;

  /// True for the celebratory milestone levels (bigger animation).
  final bool isMilestone;
}

class LevelRewards {
  const LevelRewards();

  /// Coins granted on reaching [level] — grows with level for a rising sense
  /// of payoff.
  static int coinsFor(int level) => 50 + level * 10;

  /// Cosmetic milestones keyed by level. Values are cosmetic ids that the
  /// presentation/cosmetics catalogue resolves to actual art.
  static const Map<int, LevelReward> _milestones = {
    5: LevelReward(
      kind: RewardKind.candySkin,
      amount: 1,
      cosmeticId: 'skin_pastel',
    ),
    10: LevelReward(
      kind: RewardKind.background,
      amount: 1,
      cosmeticId: 'bg_sunset',
      isMilestone: true,
    ),
    15: LevelReward(kind: RewardKind.frame, amount: 1, cosmeticId: 'frame_gold'),
    20: LevelReward(
      kind: RewardKind.candySkin,
      amount: 1,
      cosmeticId: 'skin_neon',
    ),
    25: LevelReward(
      kind: RewardKind.effect,
      amount: 1,
      cosmeticId: 'fx_rainbow_trail',
      isMilestone: true,
    ),
    35: LevelReward(
      kind: RewardKind.background,
      amount: 1,
      cosmeticId: 'bg_aurora',
    ),
    50: LevelReward(
      kind: RewardKind.candySkin,
      amount: 1,
      cosmeticId: 'skin_crystal',
      isMilestone: true,
    ),
    65: LevelReward(kind: RewardKind.frame, amount: 1, cosmeticId: 'frame_neon'),
    75: LevelReward(
      kind: RewardKind.effect,
      amount: 1,
      cosmeticId: 'fx_starburst',
      isMilestone: true,
    ),
    90: LevelReward(
      kind: RewardKind.background,
      amount: 1,
      cosmeticId: 'bg_galaxy',
    ),
    100: LevelReward(
      kind: RewardKind.frame,
      amount: 1,
      cosmeticId: 'frame_legend',
      isMilestone: true,
    ),
  };

  /// All rewards granted for reaching [level] (always coins, plus any milestone).
  List<LevelReward> forLevel(int level) {
    final rewards = <LevelReward>[
      LevelReward(kind: RewardKind.coins, amount: coinsFor(level)),
    ];
    final milestone = _milestones[level];
    if (milestone != null) rewards.add(milestone);
    return rewards;
  }

  /// True if [level] is one of the big celebration milestones.
  bool isBigMilestone(int level) =>
      const {10, 25, 50, 75, 100}.contains(level);
}
