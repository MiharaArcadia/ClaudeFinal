/// The end-of-game / end-of-level reward sheet: score, combo, XP earned, and a
/// celebratory level-up reveal when the player levelled up.
library;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../domain/progression/level_rewards.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

Future<void> showGameOverSheet(
  BuildContext context, {
  required int score,
  required int bestCombo,
  required int xpEarned,
  required LevelUpEvent levelUp,
  bool won = false,
  int stars = 0,
  bool isHighScore = false,
  required VoidCallback onRetry,
  required VoidCallback onHome,
  VoidCallback? onNext,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GameOverSheet(
      score: score,
      bestCombo: bestCombo,
      xpEarned: xpEarned,
      levelUp: levelUp,
      won: won,
      stars: stars,
      isHighScore: isHighScore,
      onRetry: onRetry,
      onHome: onHome,
      onNext: onNext,
    ),
  );
}

class _GameOverSheet extends StatelessWidget {
  const _GameOverSheet({
    required this.score,
    required this.bestCombo,
    required this.xpEarned,
    required this.levelUp,
    required this.won,
    required this.stars,
    required this.isHighScore,
    required this.onRetry,
    required this.onHome,
    this.onNext,
  });

  final int score;
  final int bestCombo;
  final int xpEarned;
  final LevelUpEvent levelUp;
  final bool won;
  final int stars;
  final bool isHighScore;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(BlockzySpacing.md),
      padding: const EdgeInsets.all(BlockzySpacing.lg),
      decoration: BoxDecoration(
        color: BlockzyColors.bgPanel,
        borderRadius: BorderRadius.circular(BlockzyRadii.xl),
        boxShadow: BlockzyShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            won ? 'Level Complete!' : (isHighScore ? 'New High Score!' : 'Game Over'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: won ? BlockzyColors.success : BlockzyColors.accentGold,
                ),
          ),
          const SizedBox(height: BlockzySpacing.md),
          if (won || stars > 0) StarRow(stars: stars, size: 36),
          const SizedBox(height: BlockzySpacing.md),
          StatRow(label: 'Score', value: '$score'),
          StatRow(label: 'Best combo', value: '$bestCombo'),
          StatRow(label: 'XP earned', value: '+$xpEarned'),
          if (levelUp.any) ...[
            const SizedBox(height: BlockzySpacing.md),
            _LevelUpBanner(levelUp: levelUp),
          ],
          const SizedBox(height: BlockzySpacing.lg),
          if (onNext != null) ...[
            GradientButton(label: 'Next level', icon: Icons.arrow_forward_rounded, onTap: onNext!),
            const SizedBox(height: BlockzySpacing.sm),
          ],
          GradientButton(
            label: 'Play again',
            icon: Icons.refresh_rounded,
            gradient: BlockzyGradients.candyPink,
            onTap: onRetry,
          ),
          const SizedBox(height: BlockzySpacing.sm),
          TextButton(onPressed: onHome, child: const Text('Home')),
        ],
      ),
    );
  }
}

class _LevelUpBanner extends StatelessWidget {
  const _LevelUpBanner({required this.levelUp});
  final LevelUpEvent levelUp;

  @override
  Widget build(BuildContext context) {
    final coins = levelUp.rewards
        .where((r) => r.kind == RewardKind.coins)
        .fold<int>(0, (a, r) => a + r.amount);
    final cosmetics = levelUp.rewards
        .where((r) => r.kind != RewardKind.coins && r.cosmeticId != null)
        .map((r) => r.cosmeticId!)
        .toList();
    return Container(
      padding: const EdgeInsets.all(BlockzySpacing.md),
      decoration: BoxDecoration(
        gradient: BlockzyGradients.gold,
        borderRadius: BorderRadius.circular(BlockzyRadii.lg),
      ),
      child: Column(
        children: [
          Text(
            'LEVEL UP!  →  ${levelUp.newLevels.last}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text('+$coins coins',
              style: const TextStyle(color: Colors.white)),
          if (cosmetics.isNotEmpty)
            Text('Unlocked: ${cosmetics.join(", ")}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
