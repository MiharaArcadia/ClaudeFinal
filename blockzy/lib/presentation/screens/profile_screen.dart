/// Player Profile — level, XP, equipped cosmetics, and an equip picker.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../domain/progression/cosmetics.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final level = player.levelState;
    return ScreenScaffold(
      title: 'Profile',
      child: ListView(
        children: [
          Panel(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: BlockzyGradients.candyPink,
                    shape: BoxShape.circle,
                    boxShadow: BlockzyShadows.glow(BlockzyColors.accentPink),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 48, color: Colors.white),
                ),
                const SizedBox(height: BlockzySpacing.md),
                XpBar(
                  level: level.level,
                  progress: level.progress,
                  isMax: level.isMax,
                ),
                const SizedBox(height: BlockzySpacing.sm),
                Text(
                  '${player.progress.totalXp} total XP',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: BlockzySpacing.md),
          Text('Equipped', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: BlockzySpacing.sm),
          for (final kind in CosmeticKind.values)
            _EquipRow(kind: kind, player: player),
        ],
      ),
    );
  }
}

class _EquipRow extends StatelessWidget {
  const _EquipRow({required this.kind, required this.player});
  final CosmeticKind kind;
  final PlayerController player;

  String _equipped() {
    switch (kind) {
      case CosmeticKind.candySkin:
        return player.progress.equippedSkin;
      case CosmeticKind.background:
        return player.progress.equippedBackground;
      case CosmeticKind.frame:
        return player.progress.equippedFrame;
      case CosmeticKind.effect:
        return player.progress.equippedEffect;
    }
  }

  void _equip(String id) {
    switch (kind) {
      case CosmeticKind.candySkin:
        player.equip(skin: id);
      case CosmeticKind.background:
        player.equip(background: id);
      case CosmeticKind.frame:
        player.equip(frame: id);
      case CosmeticKind.effect:
        player.equip(effect: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owned = Cosmetics.ofKind(kind)
        .where((c) => c.id == 'default' || player.isUnlocked(c.id))
        .toList();
    final equipped = _equipped();
    return Padding(
      padding: const EdgeInsets.only(bottom: BlockzySpacing.sm),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label(kind),
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: owned.map((c) {
                final selected = c.id == equipped;
                return ChoiceChip(
                  label: Text(c.name),
                  selected: selected,
                  onSelected: (_) => _equip(c.id),
                  selectedColor: BlockzyColors.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _label(CosmeticKind kind) {
    switch (kind) {
      case CosmeticKind.candySkin:
        return 'Candy skin';
      case CosmeticKind.background:
        return 'Background';
      case CosmeticKind.frame:
        return 'Frame';
      case CosmeticKind.effect:
        return 'Effect';
    }
  }
}
