/// Statistics — every tracked lifetime metric.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final s = player.stats;
    final level = player.levelState;
    return ScreenScaffold(
      title: 'Statistics',
      child: ListView(
        children: [
          Panel(
            child: Column(
              children: [
                StatRow(label: 'Games played', value: '${s.gamesPlayed}'),
                StatRow(label: 'Games won', value: '${s.gamesWon}'),
                StatRow(label: 'Highest combo', value: '${s.highestCombo}'),
                StatRow(label: 'Highest score', value: '${s.highestScore}'),
                StatRow(
                  label: 'Adventure completed',
                  value: '${s.adventureLevelsCompleted} / 99',
                ),
                StatRow(
                  label: 'Challenge days',
                  value: '${s.challengeDaysCompleted}',
                ),
              ],
            ),
          ),
          const SizedBox(height: BlockzySpacing.md),
          Panel(
            child: Column(
              children: [
                StatRow(label: 'Player level', value: '${level.level}'),
                StatRow(label: 'Total XP', value: '${player.progress.totalXp}'),
                StatRow(
                  label: 'Candies cleared',
                  value: '${s.totalCandiesCleared}',
                ),
                StatRow(label: 'Day streak', value: '${s.dayStreak}'),
                StatRow(
                  label: 'Ultra Blasts earned',
                  value: '${s.ultraBlastsEarned}',
                ),
                StatRow(
                  label: 'Ultra Blasts used',
                  value: '${s.ultraBlastsUsed}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
