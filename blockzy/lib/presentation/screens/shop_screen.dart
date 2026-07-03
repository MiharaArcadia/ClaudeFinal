/// Shop — spend coins on cosmetics only. No real money, no pay-to-win.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../domain/progression/cosmetics.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return ScreenScaffold(
      title: 'Shop',
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: BlockzyColors.accentGold, size: 20),
                const SizedBox(width: 4),
                Text('${player.progress.coins}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
      child: ListView(
        children: [
          for (final kind in CosmeticKind.values) ...[
            Text(_kindLabel(kind),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: BlockzySpacing.sm),
            ...Cosmetics.ofKind(kind)
                .where((c) => c.id != 'default')
                .map((c) => _CosmeticTile(cosmetic: c, player: player)),
            const SizedBox(height: BlockzySpacing.md),
          ],
        ],
      ),
    );
  }

  String _kindLabel(CosmeticKind kind) {
    switch (kind) {
      case CosmeticKind.candySkin:
        return 'Candy skins';
      case CosmeticKind.background:
        return 'Backgrounds';
      case CosmeticKind.frame:
        return 'Frames';
      case CosmeticKind.effect:
        return 'Special effects';
    }
  }
}

class _CosmeticTile extends StatelessWidget {
  const _CosmeticTile({required this.cosmetic, required this.player});
  final Cosmetic cosmetic;
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final owned = player.isUnlocked(cosmetic.id);
    final canAfford = player.progress.coins >= cosmetic.coinCost;
    return Padding(
      padding: const EdgeInsets.only(bottom: BlockzySpacing.sm),
      child: Panel(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: BlockzyGradients.primary,
                borderRadius: BorderRadius.circular(BlockzyRadii.md),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white),
            ),
            const SizedBox(width: BlockzySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cosmetic.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  if (cosmetic.milestoneOnly && !owned)
                    Text('Level milestone reward',
                        style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            if (owned)
              const Icon(Icons.check_circle_rounded,
                  color: BlockzyColors.success)
            else if (cosmetic.milestoneOnly)
              const Icon(Icons.lock_rounded,
                  color: BlockzyColors.textSecondary)
            else
              TextButton(
                onPressed: canAfford
                    ? () async {
                        final ok = await player.buyCosmetic(
                            cosmetic.id, cosmetic.coinCost);
                        if (context.mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unlocked ${cosmetic.name}!')),
                          );
                        }
                      }
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: BlockzyColors.accentGold, size: 18),
                    const SizedBox(width: 4),
                    Text('${cosmetic.coinCost}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
