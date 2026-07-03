/// Adventure map — a scrollable grid of all 99 levels showing lock state and
/// earned stars. Tapping an unlocked level launches it.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../domain/levels/level_catalog.dart';
import '../player_controller.dart';
import '../widgets/common.dart';
import 'adventure_play_screen.dart';

class AdventureMapScreen extends StatelessWidget {
  const AdventureMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return ScreenScaffold(
      title: 'Adventure',
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: LevelCatalog.levelCount,
        itemBuilder: (context, index) {
          final number = index + 1;
          final unlocked = player.isAdventureLevelUnlocked(number);
          final stars = player.adventureStars(number);
          return _LevelTile(
            number: number,
            unlocked: unlocked,
            stars: stars,
            onTap: unlocked
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdventurePlayScreen(levelNumber: number),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.number,
    required this.unlocked,
    required this.stars,
    required this.onTap,
  });

  final int number;
  final bool unlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: unlocked ? BlockzyGradients.primary : null,
          color: unlocked ? null : BlockzyColors.bgPanelSoft,
          borderRadius: BorderRadius.circular(BlockzyRadii.md),
          boxShadow: unlocked ? BlockzyShadows.soft : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              const Icon(Icons.lock_rounded, color: BlockzyColors.textSecondary)
            else
              Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            const SizedBox(height: 4),
            if (unlocked)
              StarRow(stars: stars, size: 12),
          ],
        ),
      ),
    );
  }
}
