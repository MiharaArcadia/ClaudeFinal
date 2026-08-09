/// Achievements — grouped by tier with progress bars and unlock state.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../domain/progression/achievements.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final stats = player.achievementStats;
    return ScreenScaffold(
      title: 'Achievements',
      child: ListView(
        children: [
          for (final tier in AchievementTier.values) ...[
            Text(
              _tierLabel(tier),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: BlockzySpacing.sm),
            ...Achievements.all
                .where((a) => a.tier == tier)
                .map((a) => _AchievementTile(
                      achievement: a,
                      unlocked: a.isUnlocked(stats),
                      progress: a.progress(stats),
                    )),
            const SizedBox(height: BlockzySpacing.md),
          ],
        ],
      ),
    );
  }

  String _tierLabel(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.short:
        return 'Getting started';
      case AchievementTier.medium:
        return 'Rising star';
      case AchievementTier.long:
        return 'Legendary';
    }
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.unlocked,
    required this.progress,
  });

  final Achievement achievement;
  final bool unlocked;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BlockzySpacing.sm),
      child: Panel(
        child: Row(
          children: [
            Icon(
              unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              color: unlocked
                  ? BlockzyColors.accentGold
                  : BlockzyColors.textSecondary,
              size: 32,
            ),
            const SizedBox(width: BlockzySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(BlockzyRadii.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: BlockzyColors.gridEmpty,
                      color: unlocked
                          ? BlockzyColors.success
                          : BlockzyColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
