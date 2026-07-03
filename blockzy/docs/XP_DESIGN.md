# Blockzy — XP & Progression Design

Two independent quantities drive progression. Keeping them separate is what lets
the curve feel generous early yet prestigious late.

## 1. Per-game XP reward (how much a game grants)

```
reward = 100 + difficulty*12 + stars*25 + max(0, bestCombo-1)*15
```

- **Minimum 100** — every game always feels worth it (brief requirement).
- **Higher difficulty grants more** — Adventure passes the level's difficulty
  index; Challenge scales with its day-based difficulty; Classic derives a tier
  from the score.
- Bonuses for 3-star clears and big combos reward *skill*, not grinding.

Implemented in `XpSystem.rewardFor` (`lib/domain/progression/xp_system.dart`).

## 2. Level-up requirement curve (how much each level costs)

```
xpToNext(L) = round(200 * L^1.4)      for L in [1, 99],  max level = 100
```

| Level L | XP for next | Cumulative to reach L |
|--------:|------------:|----------------------:|
| 1 | 200 | 0 |
| 5 | ~1,904 | ~4,000 |
| 10 | ~5,024 | ~22,000 |
| 25 | ~18,300 | ~200,000 |
| 50 | ~48,400 | ~1.0M |
| 75 | ~82,800 | ~2.4M |
| 99 | ~121,900 | ~4.3M |

### Why this curve creates strong long-term motivation

- **Smoothly super-linear (exponent 1.4).** Cost rises steadily rather than
  exploding. Compared with a pure-exponential curve there is no "wall" where
  progress feels hopeless.
- **Fast onboarding dopamine.** The first several levels fall in a game or two,
  so new players level up repeatedly in their first session — the single
  strongest driver of day-1 retention.
- **A reachable prestige goal.** Level 100 (~4.3M cumulative XP) is a genuine
  long-horizon target, yet because the marginal cost grows gradually, the *next*
  level always feels attainable this session. That "always one more level" shape
  is exactly the variable-reward loop that sustains habit.
- **Steady reward cadence.** Every level-up grants coins (and milestones grant
  cosmetics), so the curve continuously feeds the reward economy.

## Reward milestones & unlock pacing

Every level → **coins** (`50 + level*10`, so payouts visibly grow).

Cosmetic unlocks (`LevelRewards._milestones`) are spaced to keep novelty coming
without flooding the player:

| Level | Unlock |
|------:|--------|
| 5  | Candy skin — Pastel Pop |
| 10 | Background — Sunset ⭐ |
| 15 | Frame — Gold |
| 20 | Candy skin — Neon Rush |
| 25 | Effect — Rainbow Trail ⭐ |
| 35 | Background — Aurora |
| 50 | Candy skin — Crystal ⭐ |
| 65 | Frame — Neon |
| 75 | Effect — Starburst ⭐ |
| 90 | Background — Galaxy |
| 100 | Frame — Legend ⭐ |

⭐ = big celebration level (10/25/50/75/100) with an amplified level-up animation.

Coins additionally buy non-milestone cosmetics in the **Shop**, giving the coin
economy a purpose and a second, player-directed unlock path — never pay-to-win,
cosmetics only.
